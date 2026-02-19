# Go + SigNoz

1. Подключите OpenTelemetry SDK и OTLP exporter в коде (например `go.opentelemetry.io/otel`, `otel export/otlp`).

2. Задайте переменные из `env.example`.

3. Соберите и запустите приложение. Трейсы/метрики уйдут в коллектор.

Подробнее: [SigNoz — Golang](https://signoz.io/docs/instrumentation/golang/).
