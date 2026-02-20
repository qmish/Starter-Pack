# RUNBOOK: первый запуск и подготовка

Пошаговый чеклист для запуска коллектора и демо-приложений по стекам с отправкой телеметрии в SigNoz.

---

## Чеклист первого запуска

Выполняйте по порядку. После шагов 1–4 коллектор будет отправлять данные в SigNoz; после шага 5 телеметрия от выбранного стека появится в UI.

| # | Шаг | Действие |
|---|-----|----------|
| **1** | SigNoz | Завести [SigNoz Cloud](https://signoz.io/teams) или поднять [self-hosted](https://signoz.io/docs/install/self-host/). Записать **endpoint** (например `ingest.us.signoz.cloud:443`) и при необходимости **Ingestion Key**. |
| **2** | `.env` | В корне репозитория: `cp .env.example .env`. В `.env` указать `SIGNOZ_OTEL_ENDPOINT` и для Cloud — `SIGNOZ_INGESTION_KEY`. |
| **3** | Конфиг коллектора | Создать `collector/config.yaml` из шаблона с подставленным endpoint и ключом. **Вариант A:** запустить скрипт (читает `.env`):<br>• Windows: `.\scripts\prepare-config.ps1 -Preset full`<br>• Linux/macOS: `./scripts/prepare-config.sh full`<br>**Вариант B:** вручную скопировать `collector/config.full.yaml` в `collector/config.yaml` и заменить в нём `<SIGNOZ_ENDPOINT>` и `<INGESTION_KEY>`. |
| **4** | Коллектор | Запустить: `docker compose -f docker-compose.collector.yml up -d`. Проверить: `docker compose -f docker-compose.collector.yml ps` — контейнер в состоянии running. |
| **5** | Демо по стеку | Перейти в каталог нужного стека, установить зависимости и запустить демо-приложение (см. таблицу ниже). Сделать несколько запросов к локальному URL. В SigNoz открыть **Traces**, **Metrics**, **Logs** и убедиться, что телеметрия появилась. |

---

## Запуск демо-приложения по стекам

В каждом стеке в репозитории есть готовый файл для запуска без написания кода. Коллектор должен быть запущен (шаг 4) и слушать OTLP на `localhost:4317` (gRPC) или `4318` (HTTP).

| Стек | Каталог | Установка зависимостей | Запуск | URL для запросов |
|------|---------|------------------------|--------|-------------------|
| **Node.js** | `stacks/node` | `npm install` | `npm start` | http://localhost:8080 |
| **Python** | `stacks/python` | `pip install -r requirements.txt` | `python app.py` | http://localhost:8080 |
| **Go** | `stacks/go` | `go mod tidy` | `go run .` | http://localhost:8080 |
| **.NET** | `stacks/dotnet` | `dotnet restore` | `dotnet run` | http://localhost:8080 |
| **Java** | `stacks/java` | `mvn compile` | `mvn exec:java` или `mvn exec:java -Pagent` (с автоинструментацией) | http://localhost:8080 |
| **PHP** | `stacks/php` | `composer install` | `php -S localhost:8080` | http://localhost:8080 |

Во всех стеках доступен **GET /health** для проверки живости сервиса.

Перед запуском задайте переменные окружения из `env.example` в каталоге стека (или экспортируйте в shell). Минимум: `OTEL_EXPORTER_OTLP_ENDPOINT` (gRPC: `http://localhost:4317`, HTTP: `http://localhost:4318`), `OTEL_SERVICE_NAME=<имя-сервиса>`. Для PHP по умолчанию используется HTTP (порт 4318).

---

## Важно

- **`collector/config.yaml`** в репозиторий не входит (в .gitignore). Он создаётся на шаге 3. Без него контейнер коллектора не стартует (нет файла для монтирования).
- **`.env`** тоже не в репозитории; создаётся из `.env.example` на шаге 2.
- Для **сбора логов Docker-контейнеров** раскомментируйте в `docker-compose.collector.yml` секцию volumes и опции доступа к `/var/lib/docker/containers` (актуально для Linux).

Подробнее по конфигурации коллектора и стекам — в [README](../README.md) и в `stacks/<stack>/README.md`.
