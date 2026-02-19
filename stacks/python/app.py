#!/usr/bin/env python3
"""Minimal HTTP server with OpenTelemetry tracing to SigNoz (OTLP)."""

import os
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.resources import Resource
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

resource = Resource.create({"service.name": os.getenv("OTEL_SERVICE_NAME", "python-demo")})
provider = TracerProvider(resource=resource)
endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "localhost:4317")
if endpoint.startswith("http://"):
    endpoint = endpoint.replace("http://", "", 1)
elif endpoint.startswith("https://"):
    endpoint = endpoint.replace("https://", "", 1)
provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(endpoint=endpoint, insecure=True)))
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__, "1.0.0")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        with tracer.start_as_current_span("handle_request") as span:
            span.set_attribute("http.url", self.path)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            body = json.dumps({
                "message": "SigNoz Python demo",
                "service": os.getenv("OTEL_SERVICE_NAME", "python-demo"),
                "path": self.path,
            }).encode()
            self.wfile.write(body)

    def log_message(self, format, *args):
        pass


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    server = HTTPServer(("", port), Handler)
    print(f"Server listening on http://localhost:{port}")
    print("Send requests to see traces in SigNoz (OTLP to localhost:4317).")
    server.serve_forever()
