# Go + SigNoz

Демо: HTTP-сервер с трейсами в OTLP.

1. Зависимости: `go mod tidy`
2. Переменные из `env.example` (минимум: `OTEL_EXPORTER_OTLP_ENDPOINT=localhost:4317`, `OTEL_SERVICE_NAME=go-demo`).
3. Запуск: `go run .` — сервер на http://localhost:8080. Сделайте запросы и проверьте трейсы в SigNoz.

Подробнее: [SigNoz — Golang](https://signoz.io/docs/instrumentation/golang/).
