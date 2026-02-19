# .NET + SigNoz

1. Добавьте NuGet-пакеты OpenTelemetry (например `OpenTelemetry.Exporter.OpenTelemetryProtocol`, инструментация для ASP.NET Core и т.д.).

2. В коде настройте TracerProvider/MeterProvider с OTLP exporter; используйте переменные из `env.example`.

3. Запустите приложение. Трейсы и метрики появятся в SigNoz.

Подробнее: [SigNoz — .NET](https://signoz.io/docs/instrumentation/dotnet/).
