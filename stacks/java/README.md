# Java / JVM + SigNoz

Демо: HTTP-сервер с трейсами в OTLP.

1. Сборка: `mvn compile`
2. Переменные из `env.example` (минимум: `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317`, `OTEL_SERVICE_NAME=java-demo`).
3. Запуск: `mvn exec:java` — сервер на http://localhost:8080. Сделайте запросы и проверьте трейсы в SigNoz.

Подробнее: [SigNoz — Java](https://signoz.io/docs/instrumentation/java/).
