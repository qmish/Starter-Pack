output "container_name" {
  value = docker_container.collector.name
}

output "otlp_grpc_port" {
  value = 4317
}

output "otlp_http_port" {
  value = 4318
}
