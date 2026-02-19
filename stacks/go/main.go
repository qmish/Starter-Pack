package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/attribute"
)

func main() {
	ctx := context.Background()
	endpoint := os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
	if endpoint == "" {
		endpoint = "localhost:4317"
	}
	// strip http:// if present
	if strings.HasPrefix(endpoint, "http://") {
		endpoint = strings.TrimPrefix(endpoint, "http://")
	}

	exporter, err := otlptracegrpc.New(ctx,
		otlptracegrpc.WithEndpoint(endpoint),
		otlptracegrpc.WithInsecure(),
	)
	if err != nil {
		log.Fatal(err)
	}
	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(resource.NewWithAttributes(
			"",
			attribute.String("service.name", getEnv("OTEL_SERVICE_NAME", "go-demo")),
		)),
	)
	defer tp.Shutdown(ctx)
	otel.SetTracerProvider(tp)
	tracer := otel.Tracer("go-demo", "1.0.0")

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		_, span := tracer.Start(r.Context(), "handle_request")
		defer span.End()
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
