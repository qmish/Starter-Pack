# Сбор и настройка трассировки по стекам и системам

Единые настройки трассировки (sampling, атрибуты ресурса, распространение контекста) по стекам и системам для отправки в SigNoz.

---

## 1. Общие переменные окружения для трассировки

Эти переменные применимы ко всем стекам при отправке OTLP в коллектор или SigNoz.

| Переменная | Описание | Пример |
|------------|----------|--------|
| `OTEL_SERVICE_NAME` | Имя сервиса в SigNoz (обязательно) | `my-api`, `payment-service` |
| `OTEL_RESOURCE_ATTRIBUTES` | Атрибуты ресурса (сервис, окружение, версия) | `service.name=my-api,deployment.environment=production` |
| `OTEL_TRACES_SAMPLER` | Семплер трейсов | `parentbased_traceidratio`, `always_on` |
| `OTEL_TRACES_SAMPLER_ARG` | Аргумент семплера (например доля) | `0.1` (10%) |
| `OTEL_PROPAGATORS` | Распространение контекста между сервисами | `tracecontext,baggage` |
| `OTEL_TRACES_EXPORTER` | Экспорт трейсов | `otlp` |

Рекомендация: задавать **единую схему имён** сервисов (`OTEL_SERVICE_NAME` или через `OTEL_RESOURCE_ATTRIBUTES`) и **окружение** (`deployment.environment`), чтобы в SigNoz фильтровать и группировать по стекам/системам.

---

## 2. Семплирование (sampling)

| Семплер | Значение | Когда использовать |
|---------|----------|---------------------|
| `always_on` | Все трейсы | Dev, отладка, низкая нагрузка |
| `always_off` | Ничего не отправлять | Отключить трассировку без смены кода |
| `parentbased_always_on` | Следовать решению родителя; иначе on | Распределённые трейсы, по умолчанию всё включено |
| `parentbased_always_off` | Следовать родителю; иначе off | Снижение объёма при сохранении связности |
| `parentbased_traceidratio` | Следовать родителю; иначе по доле trace_id | Production: отправлять долю корневых трейсов |
| `traceidratio` | Доля по trace_id | То же, без учёта родителя |

Пример для production (10% корневых трейсов, дочерние по контексту родителя):

```bash
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1
```

Для staging можно увеличить долю или использовать `always_on`.

---

## 3. Атрибуты ресурса (стек / система / окружение)

Чтобы в SigNoz различать сервисы по стеку, системе и окружению, задайте единый набор атрибутов:

```bash
OTEL_RESOURCE_ATTRIBUTES="service.name=my-api,deployment.environment=production,service.version=1.2.0"
```

Рекомендуемые атрибуты:

| Атрибут | Назначение |
|---------|------------|
| `service.name` | Имя сервиса (дублирует OTEL_SERVICE_NAME при задании здесь). |
| `deployment.environment` | Окружение: `development`, `staging`, `production`. |
| `service.version` | Версия образа/билда (опционально). |
| `service.namespace` | Логическая группа/система (опционально). |

Пример по системам:

- Система «Платежи»: `service.namespace=payments,service.name=payment-api`
- Система «Каталог»: `service.namespace=catalog,service.name=catalog-service`

В SigNoz фильтрация по стеку/системе делается по этим полям в Traces и в дашбордах.

---

## 4. Настройка по стекам

### Node.js

```bash
OTEL_SERVICE_NAME=my-node-service
OTEL_TRACES_EXPORTER=otlp
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production,service.version=1.0.0
OTEL_PROPAGATORS=tracecontext,baggage
```

В коде при использовании SDK можно переопределить service name и атрибуты через `Resource`.

### Python

```bash
OTEL_SERVICE_NAME=my-python-service
OTEL_TRACES_EXPORTER=otlp
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production,service.version=1.0.0
OTEL_PROPAGATORS=tracecontext,baggage
```

При инициализации TracerProvider можно задать Resource с теми же атрибутами.

### Java / JVM

```bash
OTEL_SERVICE_NAME=my-java-service
OTEL_TRACES_EXPORTER=otlp
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production,service.version=1.0.0
OTEL_PROPAGATORS=tracecontext,baggage
```

Или JVM-опции: `-Dotel.resource.attributes=deployment.environment=production`, `-Dotel.traces.sampler=parentbased_traceidratio`, `-Dotel.traces.sampler.arg=0.1`.

### Go

```bash
OTEL_SERVICE_NAME=my-go-service
OTEL_TRACES_EXPORTER=otlp
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production,service.version=1.0.0
OTEL_PROPAGATORS=tracecontext,baggage
```

В коде: `resource.NewWithAttributes()` с теми же атрибутами при создании TracerProvider.

### .NET

```bash
OTEL_SERVICE_NAME=my-dotnet-service
OTEL_TRACES_EXPORTER=otlp
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production,service.version=1.0.0
OTEL_PROPAGATORS=tracecontext,baggage
```

В коде при настройке OpenTelemetry можно задать Resource с теми же атрибутами.

### PHP

```bash
OTEL_SERVICE_NAME=my-php-service
OTEL_TRACES_EXPORTER=otlp
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production,service.version=1.0.0
OTEL_PROPAGATORS=tracecontext,baggage
```

Семплирование в PHP SDK может отличаться; при наличии задайте `OTEL_TRACES_SAMPLER` и `OTEL_TRACES_SAMPLER_ARG` по документации провайдера.

---

## 5. Разные системы в одном кластере/хосте

- **Имена сервисов:** у каждой системы свой префикс или namespace, например `payments-api`, `catalog-service`, `auth-gateway`.
- **Окружение:** один и тот же `deployment.environment` для всех сервисов одного окружения (staging/production).
- **Семплирование:** можно задать одну долю для всего кластера через общие env или разнести по деплойментам (разные значения `OTEL_TRACES_SAMPLER_ARG` для критичных и фоновых сервисов).

В SigNoz фильтрация по системе делается по `service.name` или по `service.namespace` / `deployment.environment`.

---

## 6. Проверка

1. Сделать запрос через несколько сервисов (один вызывает другой).
2. В SigNoz в **Traces** найти трейс по имени сервиса или по операции.
3. Убедиться, что цепочка спанов от фронта до бэкенда видна и что у ресурсов заданы `service.name`, `deployment.environment` (и при необходимости `service.version`).

Готовые примеры env по стекам — в каталогах `stacks/<stack>/env.example` с учётом трассировки и атрибутов из этого документа.
