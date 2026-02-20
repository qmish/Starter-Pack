# Чек-лист доработок стеков приложений

Проверка и фиксация выполненных доработок по стекам (Node, Python, Go, .NET, Java, PHP).

---

## 1. Health endpoint (`GET /health`)

- [x] Node.js
- [x] Python
- [x] Go
- [x] .NET
- [x] Java
- [x] PHP

---

## 2. PHP bootstrap (инициализация TracerProvider)

- [x] PHP: bootstrap-файл с созданием TracerProvider и OTLP exporter

---

## 3. Метрики OTLP

- [x] Python: MeterProvider + OTLP metrics exporter
- [x] Go: OTLP metric exporter
- [x] .NET: AddMetrics() + AddOtlpExporter
- [x] Java: OTLP metrics exporter

---

## 4. Graceful shutdown (корректное завершение экспортеров)

- [x] Node.js
- [x] Python
- [x] Go
- [x] .NET (через IHostApplicationLifetime в OTel)
- [x] Java

---

## 5. Resource attributes из env (`OTEL_RESOURCE_ATTRIBUTES`)

- [x] Python
- [x] Go
- [x] Java

---

## 6. SigNoz Cloud: заголовки (`OTEL_EXPORTER_OTLP_HEADERS`)

- [x] Python
- [x] Go
- [x] Java

---

## 7. Логи OTLP

- [x] Python: LoggerProvider + OTLPLogExporter + LoggingHandler (bridge stdlib logging)
- [x] .NET: WithLogging() + AddOtlpExporter
- [x] Go: otlplog/otlploggrpc + sdk/log (beta)
- [x] Java: SdkLoggerProvider + OtlpGrpcLogExporter + getLogsBridge()

---

## 8. Автоинструментация

- [x] Node.js — `@opentelemetry/auto-instrumentations-node` (--require при запуске)
- [x] Python — `opentelemetry-instrumentation-wsgi` + OpenTelemetryMiddleware (WSGI)
- [x] Go — `go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp`
- [x] .NET — `AddAspNetCoreInstrumentation`, `AddHttpClientInstrumentation`
- [x] Java — `-Pagent` для запуска с `-javaagent:opentelemetry-javaagent.jar`
- [ ] PHP — опционально `OTEL_PHP_AUTOLOAD_ENABLED` + auto-пакеты под фреймворк (Laravel и др.)

---

## Итог

| Стек   | Health | Bootstrap | Метрики | Логи  | Shutdown | Resource attrs | Cloud headers | Автоинструментация |
|--------|--------|-----------|---------|-------|----------|----------------|---------------|--------------------|
| Node   | [x]    | —         | auto    | auto  | [x]      | auto           | auto          | [x]                |
| Python | [x]    | —         | [x]     | [x]   | [x]      | [x]            | [x]           | [x]                |
| Go     | [x]    | —         | [x]     | [x]   | [x]      | [x]            | [x]           | [x]                |
| .NET   | [x]    | —         | [x]     | [x]   | [x]      | auto           | auto          | [x]                |
| Java   | [x]    | —         | [x]     | [x]   | [x]      | [x]            | [x]           | [x]                |
| PHP    | [x]    | [x]       | —       | —     | —        | —              | —             | опц.               |

---

*Обновляйте отметки по мере выполнения: `[ ]` → `[x]`.*
