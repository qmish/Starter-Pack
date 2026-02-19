# PHP + SigNoz

Инструментация PHP (Laravel, Symfony, WordPress, Slim и др.) через OpenTelemetry и отправка трейсов в SigNoz.

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

Для авто-инструментации по фреймворку добавьте один из пакетов:

- **Laravel:** `open-telemetry/opentelemetry-auto-laravel`
- **Slim:** `open-telemetry/opentelemetry-auto-slim`
- **Symfony:** см. [supported libraries](https://packagist.org/search/?query=open-telemetry&tags=instrumentation)

### 3. Переменные окружения

Скопируйте переменные из `env.example` в окружение веб-сервера или задайте перед запуском PHP.

Для отправки через **локальный коллектор** используйте:

- `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318` (HTTP OTLP)
- `OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf`

### 4. Запуск

```bash
# Встроенный сервер
php -S localhost:8080 app.php

# Laravel
php artisan serve
```

В Apache/Nginx задайте те же переменные через `SetEnv` (Apache) или `fastcgi_param` / env-файл (PHP-FPM).

## Проверка

- Вкладка **Traces** в SigNoz — появление трейсов после запросов к приложению.
- При проблемах: `OTEL_TRACES_EXPORTER=console php -S ...` — вывод спанов в консоль.

Подробнее: [SigNoz — PHP](https://signoz.io/docs/instrumentation/opentelemetry-php/).
