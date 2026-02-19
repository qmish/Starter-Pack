# .NET + SigNoz

Демо: минимальное ASP.NET Core API с трейсами в OTLP.

1. Восстановление пакетов: `dotnet restore`
2. Переменные из `env.example` (минимум: `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317`, `OTEL_SERVICE_NAME=dotnet-demo`).
3. Запуск: `dotnet run` — приложение на http://localhost:8080. Сделайте запросы и проверьте трейсы в SigNoz.

Подробнее: [SigNoz — .NET](https://signoz.io/docs/instrumentation/dotnet/).
