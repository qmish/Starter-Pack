# Python + SigNoz

1. Установите пакеты, например:
   - `opentelemetry-api`, `opentelemetry-sdk`
   - `opentelemetry-exporter-otlp`
   - Или авто-инструментация: `opentelemetry-distro`, `opentelemetry-instrumentation-*`

2. Используйте переменные из `env.example`.

3. Запуск с авто-инструментацией (пример):
   ```bash
   opentelemetry-instrument python app.py
   ```

Подробнее: [SigNoz — Python](https://signoz.io/docs/instrumentation/python/).
