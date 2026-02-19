package io.signoz.starter;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporter;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class App {

    public static void main(String[] args) throws IOException {
        String endpoint = System.getenv().getOrDefault("OTEL_EXPORTER_OTLP_ENDPOINT", "localhost:4317");
        if (endpoint.startsWith("http://")) endpoint = endpoint.substring(7);
        if (endpoint.startsWith("https://")) endpoint = endpoint.substring(8);

        String serviceName = System.getenv().getOrDefault("OTEL_SERVICE_NAME", "java-demo");
        SdkTracerProvider tracerProvider = SdkTracerProvider.builder()
                .addSpanProcessor(BatchSpanProcessor.builder(
                        OtlpGrpcSpanExporter.builder().setEndpoint(endpoint).setUseTls(false).build()).build())
                .build();
        OpenTelemetrySdk.initializeGlobal(OpenTelemetrySdk.builder().setTracerProvider(tracerProvider).build());

        Tracer tracer = GlobalOpenTelemetry.getTracer("java-demo", "1.0.0");
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));

        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", new HttpHandler() {
            @Override
            public void handle(HttpExchange exchange) throws IOException {
                Span span = tracer.spanBuilder("handle_request").startSpan();
                try {
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
}
