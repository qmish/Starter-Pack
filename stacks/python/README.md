# Python + SigNoz

Демо: минимальный HTTP-сервер с трейсами в OTLP.

1. Установите зависимости: `pip install -r requirements.txt`
2. Задайте переменные из `env.example` (минимум: `OTEL_EXPORTER_OTLP_ENDPOINT=localhost:4317`, `OTEL_SERVICE_NAME=python-demo`).
3. Запуск: `python app.py` — сервер на http://localhost:8080. Сделайте запросы и проверьте трейсы в SigNoz.

Подробнее: [SigNoz — Python](https://signoz.io/docs/instrumentation/python/).
