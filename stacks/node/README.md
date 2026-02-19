# Node.js + SigNoz

1. Установите OpenTelemetry SDK и экспортер OTLP, например:
   - `@opentelemetry/sdk-node`
   - `@opentelemetry/exporter-trace-otlp-grpc` / `exporter-metrics-otlp-grpc`
   - Или авто-инструментация: `@opentelemetry/auto-instrumentations-node`

2. Скопируйте переменные из `env.example` в окружение или `.env`.

3. Запустите приложение. Трейсы и метрики появятся в SigNoz.

Подробнее: [SigNoz — Node.js](https://signoz.io/docs/instrumentation/nodejs/).
