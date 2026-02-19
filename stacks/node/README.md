# Node.js + SigNoz

Демо: HTTP-сервер с авто-инструментацией (трейсы уходят в OTLP).

1. Установите зависимости: `npm install`
2. Задайте переменные из `env.example` (минимум: `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317`, `OTEL_SERVICE_NAME=node-demo`).
3. Запуск: `npm start` — сервер на http://localhost:8080. Сделайте несколько запросов и проверьте трейсы в SigNoz.

Подробнее: [SigNoz — Node.js](https://signoz.io/docs/instrumentation/nodejs/).
