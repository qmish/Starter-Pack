# PHP + SigNoz

Инструментация PHP (Laravel, Symfony, WordPress, Slim и др.) через OpenTelemetry: трейсы, метрики и логи в SigNoz.

## Что есть в демо

- **bootstrap.php** — инициализация TracerProvider, MeterProvider, LoggerProvider с OTLP (traces, metrics, logs), graceful shutdown.
- **Health** — `GET /health` возвращает `{"status":"ok","service":"..."}`.
- Переменные: `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_SERVICE_NAME`, `OTEL_RESOURCE_ATTRIBUTES`, `OTEL_EXPORTER_OTLP_HEADERS` (SigNoz Cloud).

## Требования

- PHP 8.0+
- [Composer](https://getcomposer.org/)
- [PECL](https://pecl.php.net/) (для расширения OpenTelemetry)

## Шаги

### 1. Установка расширения OpenTelemetry (PECL)

```bash
# Сборка (Linux)
sudo apt-get install gcc make autoconf
pecl install opentelemetry
```

В `php.ini` (путь: `php --ini`):

```ini
extension=opentelemetry.so
```

Проверка: `php --ri opentelemetry`

### 2. Composer-зависимости

```bash
composer config allow-plugins.php-http/discovery false
composer require \
  open-telemetry/sdk \
  open-telemetry/exporter-otlp \
  php-http/guzzle7-adapter
```

**Опционально: автоинструментация.** Включите `OTEL_PHP_AUTOLOAD_ENABLED=true` и установите пакет под фреймворк:

- **Laravel:** `open-telemetry/opentelemetry-auto-laravel`
- **Slim:** `open-telemetry/opentelemetry-auto-slim`
- **Symfony:** см. [supported libraries](https://packagist.org/search/?query=open-telemetry&tags=instrumentation)

### 3. Переменные окружения

Скопируйте переменные из `env.example` в окружение веб-сервера или задайте перед запуском PHP.

Для отправки через **локальный коллектор** используйте:

- `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318` (HTTP OTLP)
- `OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf`

### 4. Запуск демо

Задайте переменные из `env.example` (для коллектора: `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318`, `OTEL_SERVICE_NAME=php-demo`). Затем:

```bash
php -S localhost:8080
```

Откройте http://localhost:8080 в браузере и проверьте трейсы в SigNoz.

## Проверка

- **Traces / Metrics / Logs** в SigNoz — появление данных после запросов к приложению.
- Health: `curl http://localhost:8080/health`.
- При проблемах: `OTEL_TRACES_EXPORTER=console php -S ...` — вывод спанов в консоль.

Подробнее: [SigNoz — PHP](https://signoz.io/docs/instrumentation/opentelemetry-php/).
