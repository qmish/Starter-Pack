# Зависимости: SDK и OTLP exporter

В каждом стеке в каталоге `stacks/<stack>/` добавлены файлы зависимостей с реальными пакетами OpenTelemetry SDK и OTLP exporter. Версии заданы с возможностью обновления (диапазоны или отдельные переменные).

## Файлы по стекам

| Стек   | Файл зависимостей      | Менеджер пакетов |
|--------|------------------------|------------------|
| Node.js | `stacks/node/package.json` | npm / yarn / pnpm |
| Python | `stacks/python/requirements.txt` | pip |
| Go     | `stacks/go/go.mod`     | go get |
| .NET   | `stacks/dotnet/SignozStarter.csproj` | dotnet add package |
| Java   | `stacks/java/pom.xml`  | Maven |
| PHP    | `stacks/php/composer.json` | Composer |

## Как обновить зависимости

### Node.js

```bash
cd stacks/node
npm update
# или обновить только OTel пакеты:
npm update @opentelemetry/sdk-node @opentelemetry/exporter-trace-otlp-grpc @opentelemetry/exporter-metrics-otlp-grpc @opentelemetry/auto-instrumentations-node
npm outdated
```

### Python

```bash
cd stacks/python
pip install -U -r requirements.txt
pip list --outdated
```

### Go

```bash
cd stacks/go
go get -u go.opentelemetry.io/otel go.opentelemetry.io/otel/sdk go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc
go mod tidy
```

### .NET

```bash
cd stacks/dotnet
dotnet list package --outdated
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol
dotnet add package OpenTelemetry.Extensions.Hosting
# и т.д. для нужных пакетов
```

### Java (Maven)

В `pom.xml` обновите свойство `opentelemetry.version` (и при необходимости `opentelemetry-javaagent`), затем:

```bash
cd stacks/java
mvn versions:display-dependency-updates
mvn clean install
```

### PHP

```bash
cd stacks/php
composer update
composer outdated
```

## Рекомендуемая периодичность

- Следить за [релизами OpenTelemetry](https://github.com/open-telemetry/opentelemetry-spec/releases) и обновлять пакеты раз в 1–2 квартала.
- После обновления проверять [Instrumentation docs SigNoz](https://signoz.io/docs/instrumentation/) на совместимость.
