#!/usr/bin/env python3
"""Minimal HTTP server with OpenTelemetry tracing and metrics to SigNoz (OTLP)."""

import os
import json
import signal
from http.server import HTTPServer, BaseHTTPRequestHandler

from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import Resource
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter


def parse_resource_attributes():
    attrs = {"service.name": os.getenv("OTEL_SERVICE_NAME", "python-demo")}
    raw = os.getenv("OTEL_RESOURCE_ATTRIBUTES", "")
    for pair in raw.split(","):
        if "=" in pair:
            k, v = pair.split("=", 1)
            attrs[k.strip()] = v.strip()
    return attrs


def parse_headers():
    headers = {}
    raw = os.getenv("OTEL_EXPORTER_OTLP_HEADERS", "")
    for pair in raw.split(","):
        if "=" in pair:
            k, v = pair.split("=", 1)
            headers[k.strip()] = v.strip()
    return headers if headers else None


def get_endpoint():
    ep = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "localhost:4317")
    for p in ("http://", "https://"):
        if ep.startswith(p):
            ep = ep[len(p):]
            break
    return ep


resource = Resource.create(parse_resource_attributes())
endpoint = get_endpoint()
headers = parse_headers()

tracer_provider = TracerProvider(resource=resource)
trace_exp = OTLPSpanExporter(endpoint=endpoint, insecure=True, headers=headers)
tracer_provider.add_span_processor(BatchSpanProcessor(trace_exp))
trace.set_tracer_provider(tracer_provider)
tracer = trace.get_tracer(__name__, "1.0.0")

metric_exp = OTLPMetricExporter(endpoint=endpoint, insecure=True, headers=headers)
reader = PeriodicExportingMetricReader(metric_exp, export_interval_millis=30000)
meter_provider = MeterProvider(resource=resource, metric_readers=[reader])
metrics.set_meter_provider(meter_provider)
meter = metrics.get_meter(__name__, "1.0.0")
request_counter = meter.create_counter("demo_requests_total", description="Total requests")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok", "service": os.getenv("OTEL_SERVICE_NAME", "python-demo")}).encode())
            return
        with tracer.start_as_current_span("handle_request") as span:
            span.set_attribute("http.url", self.path)
            request_counter.add(1)
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


def shutdown(signum=None, frame=None):
    tracer_provider.shutdown()
    meter_provider.shutdown()


if __name__ == "__main__":
    signal.signal(signal.SIGTERM, shutdown)
    port = int(os.getenv("PORT", "8080"))
    server = HTTPServer(("", port), Handler)
    print(f"Server listening on http://localhost:{port}")
    print("Send requests to see traces in SigNoz (OTLP to localhost:4317).")
    try:
        server.serve_forever()
    finally:
        shutdown()
