# Конфигурации OpenTelemetry Collector

| Файл | Назначение |
|------|------------|
| **config.full.yaml** | OTLP + host metrics + логи Docker + логи из файлов хоста. Для Docker-хоста. |
| **config.docker.yaml** | OTLP + только логи Docker-контейнеров. Минимальный вариант для Docker. |
| **config.vm.yaml** | OTLP + host metrics + логи из файлов. Для VM без Docker. |
| **config.k8s.yaml** | OTLP + логи подов Kubernetes (/var/log/pods). Для DaemonSet вручную; предпочтительно чарт [k8s-infra](../docs/KUBERNETES_HELM.md). |
| **config.selfhosted.example.yaml** | Пример блока exporters для self-hosted SigNoz (без ingestion key). |
| **processors.log-filtering.yaml** | Фрагмент процессоров для фильтрации логов по уровню (severity) и коду ошибки. См. [LOGGING_FILTERING](../docs/LOGGING_FILTERING.md). |

## Перед использованием

1. Скопируйте нужный конфиг в `config.yaml` (или укажите его в docker-compose/скрипте):
   ```bash
   cp config.full.yaml config.yaml
   ```
2. Откройте `config.yaml` и замените:
   - **&lt;SIGNOZ_ENDPOINT&gt;** — для Cloud: `ingest.<REGION>.signoz.cloud:443`, для self-hosted: `signoz:4317` или `localhost:4317`.
   - **&lt;INGESTION_KEY&gt;** — ключ SigNoz Cloud. Для self-hosted удалите весь блок `headers` и задайте `tls.insecure: true` при необходимости.
3. При необходимости отредактируйте пути в `filelog/host.include` под свои логи.

Для генерации `config.yaml` из шаблона и `.env` можно использовать скрипты в `scripts/` (см. корневой README).
