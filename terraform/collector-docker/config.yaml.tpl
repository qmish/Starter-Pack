receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
  hostmetrics:
    collection_interval: 60s
    scrapers:
      cpu: {}
      memory: {}
      disk: {}
      network: {}
processors:
  batch: {}
  resourcedetection:
    detectors: [env, system]
    timeout: 5s
exporters:
  otlp:
    endpoint: "${signoz_endpoint}"
    tls:
      insecure: false
    headers:
      "signoz-ingestion-key": "${signoz_ingestion_key}"
  debug:
    verbosity: normal
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [resourcedetection, batch]
      exporters: [otlp]
    metrics:
      receivers: [otlp, hostmetrics]
      processors: [resourcedetection, batch]
      exporters: [otlp]
    logs:
      receivers: [otlp]
      processors: [resourcedetection, batch]
      exporters: [otlp]
