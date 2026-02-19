# Terraform: OpenTelemetry Collector (Docker)

Запуск OpenTelemetry Collector в Docker через Terraform с подстановкой endpoint и ключа SigNoz.

## Требования

- [Terraform](https://www.terraform.io/downloads) 1.x
- Docker (демон запущен)
- [Docker provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest) (подтягивается автоматически)

## Использование

```bash
cd terraform/collector-docker
terraform init
terraform plan -var="signoz_endpoint=ingest.us.signoz.cloud:443" -var="signoz_ingestion_key=YOUR_KEY"
terraform apply -var="signoz_endpoint=ingest.us.signoz.cloud:443" -var="signoz_ingestion_key=YOUR_KEY"
```

Или создайте `terraform.tfvars` (не коммитить):

```hcl
signoz_endpoint     = "ingest.us.signoz.cloud:443"
signoz_ingestion_key = "your-ingestion-key"
```

Для self-hosted: `signoz_endpoint = "signoz-host:4317"`, `signoz_ingestion_key = ""`. При необходимости измените в `config.yaml.tpl` блок `exporters.otlp` (tls.insecure: true, без headers).

## Удаление

```bash
terraform destroy
```
