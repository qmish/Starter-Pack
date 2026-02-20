package io.signoz.starter;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.metrics.LongCounter;
import io.opentelemetry.api.metrics.Meter;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.exporter.otlp.metrics.OtlpGrpcMetricExporter;
import io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporter;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.metrics.SdkMeterProvider;
import io.opentelemetry.sdk.metrics.export.PeriodicMetricReader;
import io.opentelemetry.api.common.AttributeKey;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class App {

    public static void main(String[] args) throws IOException {
        String endpoint = System.getenv().getOrDefault("OTEL_EXPORTER_OTLP_ENDPOINT", "localhost:4317");
        if (endpoint.startsWith("http://")) endpoint = endpoint.substring(7);
        if (endpoint.startsWith("https://")) endpoint = endpoint.substring(8);

        String serviceName = System.getenv().getOrDefault("OTEL_SERVICE_NAME", "java-demo");
        Resource resource = buildResource(serviceName);

        Map<String, String> headers = parseHeaders(System.getenv().getOrDefault("OTEL_EXPORTER_OTLP_HEADERS", ""));

        var traceExpBuilder = OtlpGrpcSpanExporter.builder().setEndpoint(endpoint).setUseTls(false);
        headers.forEach(traceExpBuilder::addHeader);
        var traceExp = traceExpBuilder.build();

        var metricExpBuilder = OtlpGrpcMetricExporter.builder().setEndpoint(endpoint).setUseTls(false);
        headers.forEach(metricExpBuilder::addHeader);
        var metricExp = metricExpBuilder.build();

        SdkTracerProvider tracerProvider = SdkTracerProvider.builder()
                .setResource(resource)
                .addSpanProcessor(BatchSpanProcessor.builder(traceExp).build())
                .build();
        SdkMeterProvider meterProvider = SdkMeterProvider.builder()
                .setResource(resource)
                .registerMetricReader(PeriodicMetricReader.builder(metricExp).setInterval(java.time.Duration.ofSeconds(30)).build())
                .build();

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            tracerProvider.close();
            meterProvider.close();
        }));

        OpenTelemetrySdk.initializeGlobal(OpenTelemetrySdk.builder()
                .setTracerProvider(tracerProvider)
                .setMeterProvider(meterProvider)
                .build());

        Tracer tracer = GlobalOpenTelemetry.getTracer("java-demo", "1.0.0");
        Meter meter = GlobalOpenTelemetry.getMeter("java-demo", "1.0.0");
        LongCounter requestCounter = meter.counterBuilder("demo_requests_total").setDescription("Total requests").build();

        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/health", exchange -> {
            String body = "{\"status\":\"ok\",\"service\":\"" + serviceName + "\"}";
            exchange.getResponseHeaders().set("Content-Type", "application/json");
            exchange.sendResponseHeaders(200, body.getBytes(StandardCharsets.UTF_8).length);
            exchange.getResponseBody().write(body.getBytes(StandardCharsets.UTF_8));
        });
        server.createContext("/", new HttpHandler() {
            @Override
            public void handle(HttpExchange exchange) throws IOException {
                Span span = tracer.spanBuilder("handle_request").startSpan();
                try {
                    requestCounter.add(1);
                    String path = exchange.getRequestURI().getPath();
                    String body = "{\"message\":\"SigNoz Java demo\",\"service\":\"" + serviceName + "\",\"path\":\"" + path + "\"}";
                    exchange.getResponseHeaders().set("Content-Type", "application/json");
                    exchange.sendResponseHeaders(200, body.getBytes(StandardCharsets.UTF_8).length);
                    try (OutputStream os = exchange.getResponseBody()) {
                        os.write(body.getBytes(StandardCharsets.UTF_8));
                    }
                } finally {
                    span.end();
                }
            }
        });
        server.setExecutor(null);
        server.start();
        System.out.println("Server listening on http://localhost:" + port);
        System.out.println("Send requests to see traces in SigNoz (OTLP to localhost:4317).");
    }

    private static Resource buildResource(String serviceName) {
        Resource.Builder builder = Resource.builder().put(AttributeKey.stringKey("service.name"), serviceName);
        String raw = System.getenv().getOrDefault("OTEL_RESOURCE_ATTRIBUTES", "");
        for (String pair : raw.split(",")) {
            int eq = pair.indexOf('=');
            if (eq > 0) {
                builder.put(AttributeKey.stringKey(pair.substring(0, eq).trim()), pair.substring(eq + 1).trim());
            }
        }
        return builder.build();
    }

    private static Map<String, String> parseHeaders(String raw) {
        Map<String, String> m = new HashMap<>();
        for (String pair : raw.split(",")) {
            int eq = pair.indexOf('=');
            if (eq > 0) {
                m.put(pair.substring(0, eq).trim(), pair.substring(eq + 1).trim());
            }
        }
        return m;
    }
}
