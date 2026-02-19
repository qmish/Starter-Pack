terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "collector" {
  name = var.collector_image
}

resource "local_file" "config" {
  content = templatefile("${path.module}/config.yaml.tpl", {
    signoz_endpoint     = var.signoz_endpoint
    signoz_ingestion_key = var.signoz_ingestion_key
  })
  filename             = "${path.module}/config.generated.yaml"
  file_permission      = "0644"
}

resource "docker_container" "collector" {
  name  = var.container_name
  image = docker_image.collector.image_id

  ports {
    internal = 4317
    external = 4317
  }
  ports {
    internal = 4318
    external = 4318
  }

  volumes {
    host_path      = abspath(local_file.config.filename)
    container_path = "/etc/otelcol-contrib/config.yaml"
    read_only      = true
  }

  command = ["--config=/etc/otelcol-contrib/config.yaml"]
  restart = "unless-stopped"
}
