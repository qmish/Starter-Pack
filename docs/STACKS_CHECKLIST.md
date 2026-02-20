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

## 7. Автоинструментация

- [x] Node.js — `@opentelemetry/auto-instrumentations-node` (--require при запуске)
- [ ] Python — `opentelemetry-instrumentation` в deps; демо — ручные spans
- [ ] Go — нет (ручная инструментация)
- [x] .NET — `AddAspNetCoreInstrumentation`, `AddHttpClientInstrumentation`
- [ ] Java — опционально `-javaagent:opentelemetry-javaagent.jar` (закомментировано в pom)
- [ ] PHP — опционально `OTEL_PHP_AUTOLOAD_ENABLED` + auto-пакеты под фреймворк

---

## Итог

| Стек   | Health | Bootstrap | Метрики | Shutdown | Resource attrs | Cloud headers | Автоинструментация |
|--------|--------|-----------|---------|----------|----------------|---------------|--------------------|
| Node   | [x]    | —         | auto    | [x]      | auto           | auto          | [x]                |
| Python | [x]    | —         | [x]     | [x]      | [x]            | [x]           | опц.               |
| Go     | [x]    | —         | [x]     | [x]      | [x]            | [x]           | —                  |
| .NET   | [x]    | —         | [x]     | [x]      | auto           | auto          | [x]                |
| Java   | [x]    | —         | [x]     | [x]      | [x]            | [x]           | опц.               |
| PHP    | [x]    | [x]       | —       | —        | —              | —             | опц.               |

---

*Обновляйте отметки по мере выполнения: `[ ]` → `[x]`.*
