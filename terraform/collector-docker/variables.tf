variable "signoz_endpoint" {
  description = "SigNoz OTLP endpoint (e.g. ingest.us.signoz.cloud:443 or host:4317)"
  type        = string
}

variable "signoz_ingestion_key" {
  description = "SigNoz Cloud ingestion key (empty for self-hosted)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "collector_image" {
  description = "OpenTelemetry Collector Docker image"
  type        = string
  default     = "otel/opentelemetry-collector-contrib:0.130.1"
}

variable "container_name" {
  description = "Docker container name for the collector"
  type        = string
  default     = "signoz-otel-collector"
}
