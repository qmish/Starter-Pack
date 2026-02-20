package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

func main() {
	ctx := context.Background()
	endpoint := getEnv("OTEL_EXPORTER_OTLP_ENDPOINT", "localhost:4317")
	endpoint = strings.TrimPrefix(strings.TrimPrefix(endpoint, "http://"), "https://")

	headers := parseHeaders(getEnv("OTEL_EXPORTER_OTLP_HEADERS", ""))

	traceOpts := []otlptracegrpc.Option{
		otlptracegrpc.WithEndpoint(endpoint),
		otlptracegrpc.WithInsecure(),
	}
	if len(headers) > 0 {
		traceOpts = append(traceOpts, otlptracegrpc.WithHeaders(headers))
	}
	traceExp, err := otlptracegrpc.New(ctx, traceOpts...)
	if err != nil {
		log.Fatal(err)
	}

	metricOpts := []otlpmetricgrpc.Option{
		otlpmetricgrpc.WithEndpoint(endpoint),
		otlpmetricgrpc.WithInsecure(),
	}
	if len(headers) > 0 {
		metricOpts = append(metricOpts, otlpmetricgrpc.WithHeaders(headers))
	}
	metricExp, err := otlpmetricgrpc.New(ctx, metricOpts...)
	if err != nil {
		log.Fatal(err)
	}

	res := buildResource()
	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(traceExp),
		sdktrace.WithResource(res),
	)
	mp := sdkmetric.NewMeterProvider(
		sdkmetric.WithReader(sdkmetric.NewPeriodicReader(metricExp)),
		sdkmetric.WithResource(res),
	)
	otel.SetTracerProvider(tp)
	otel.SetMeterProvider(mp)
	tracer := otel.Tracer("go-demo")
	meter := otel.Meter("go-demo")
	requestCounter, _ := meter.Int64Counter("demo_requests_total")

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGTERM, syscall.SIGINT)
	go func() {
		<-sigCh
		_ = tp.Shutdown(ctx)
		_ = mp.Shutdown(ctx)
		os.Exit(0)
	}()

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "ok", "service": getEnv("OTEL_SERVICE_NAME", "go-demo")})
	})
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		_, span := tracer.Start(r.Context(), "handle_request")
		defer span.End()
		requestCounter.Add(r.Context(), 1)
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"message": "SigNoz Go demo",
			"service": getEnv("OTEL_SERVICE_NAME", "go-demo"),
			"path":    r.URL.Path,
		})
	})
	port := getEnv("PORT", "8080")
	log.Printf("Server listening on http://localhost:%s", port)
	log.Print("Send requests to see traces in SigNoz (OTLP to localhost:4317).")
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func getEnv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func parseHeaders(raw string) map[string]string {
	m := make(map[string]string)
	for _, pair := range strings.Split(raw, ",") {
		kv := strings.SplitN(strings.TrimSpace(pair), "=", 2)
		if len(kv) == 2 {
			m[strings.TrimSpace(kv[0])] = strings.TrimSpace(kv[1])
		}
	}
	return m
}

func buildResource() *resource.Resource {
	attrs := []attribute.KeyValue{
		attribute.String("service.name", getEnv("OTEL_SERVICE_NAME", "go-demo")),
	}
	raw := getEnv("OTEL_RESOURCE_ATTRIBUTES", "")
	for _, pair := range strings.Split(raw, ",") {
		kv := strings.SplitN(strings.TrimSpace(pair), "=", 2)
		if len(kv) == 2 {
			attrs = append(attrs, attribute.String(strings.TrimSpace(kv[0]), strings.TrimSpace(kv[1])))
		}
	}
	res, _ := resource.New(context.Background(), resource.WithAttributes(attrs...))
	return res
}
