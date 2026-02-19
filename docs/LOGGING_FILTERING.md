# Фильтрация логов: по уровням и кодам ошибок

Настройка сбора и отображения логов с учётом **уровня (severity)** и **кода ошибки** — в коллекторе (на источнике) и в SigNoz (при запросах и алертах).

---

## 1. Уровни логов (severity)

### Шкала OpenTelemetry

| Уровень | severity_number | Примеры в приложениях |
|---------|-----------------|------------------------|
| TRACE   | 1–4             | trace, verbose        |
| DEBUG   | 5–8             | debug                 |
| INFO    | 9–12            | info                  |
| WARN    | 13–16           | warn, warning         |
| ERROR   | 17–20           | error                 |
| FATAL   | 21–24           | fatal, critical       |

### Фильтрация в коллекторе (уменьшение объёма)

Чтобы **не отправлять** в SigNoz часть логов по уровню (например, отбрасывать DEBUG в production), добавьте в конфиг коллектора процессор **filter** и подключите его в пайплайн `logs` **перед** `batch`:

```yaml
processors:
  filter/drop-debug:
    logs:
      log_record:
        # Отбросить записи с уровнем ниже INFO (TRACE и DEBUG)
        - 'severity_number < SEVERITY_NUMBER_INFO'
    error_mode: ignore

  # существующие процессоры
  batch: {}
  resourcedetection: ...
```

В `service.pipelines.logs` укажите процессор по необходимости:

```yaml
service:
  pipelines:
    logs:
      receivers: [otlp, filelog/docker, filelog/host]
      processors: [resourcedetection, filter/drop-debug, batch]
      exporters: [otlp]
```

Варианты условий по уровню:

| Цель                     | Условие (OTTL) |
|--------------------------|----------------|
| Отбросить TRACE и DEBUG  | `severity_number < SEVERITY_NUMBER_INFO` |
| Оставить только WARN и выше | `severity_number < SEVERITY_NUMBER_WARN` |
| Оставить только ERROR и выше | `severity_number < SEVERITY_NUMBER_ERROR` |

Готовый фрагмент с разными пресетами — в [collector/processors.log-filtering.yaml](../collector/processors.log-filtering.yaml).

### Разные правила по стеку/системе

Если один коллектор принимает логи от нескольких сервисов и нужны **разные пороги по уровню**:

1. **Вариант A:** несколько пайплайнов логов с разными receiver и filter (например, по `resource["service.name"]` через OTTL).
2. **Вариант B:** один пайплайн, в filter — составное условие по `resource["service.name"]` и `severity_number` (оставить только нужные комбинации).
3. **Вариант C:** не отбрасывать в коллекторе, а фильтровать только в SigNoz при просмотре и в алертах (см. ниже).

Пример условия «отбросить DEBUG только у сервиса A» (OTTL):

```yaml
filter/drop-debug-service-a:
  logs:
    log_record:
      - 'resource["service.name"] == "service-a" and severity_number < SEVERITY_NUMBER_INFO'
  error_mode: ignore
```

### Фильтрация в SigNoz (без отбрасывания в коллекторе)

В UI SigNoz (вкладка **Logs**) можно в запросе отфильтровать логи по полю **Severity** (или по атрибуту уровня). Алерты по логам (log-based alerts) тоже задаются по уровню и другим полям. Так можно оставить в коллекторе все уровни и настраивать отбор только в SigNoz.

---

## 2. Коды ошибок (error code)

### Как сделать коды ошибок доступными для фильтрации

Чтобы фильтровать логи по коду ошибки:

1. **В приложении** — писать код ошибки в структурированный лог как отдельное поле (например `error.code`, `err_code`, `code`) и по возможности выставлять уровень ERROR/WARN.
2. **В коллекторе** — при необходимости вынести это поле в атрибут ресурса или лога (через **attributes** или **transform** processor), чтобы в SigNoz по нему строить запросы и алерты.

Если логи приходят в SigNoz по OTLP уже с атрибутом `error.code` (или `code`) — дополнительная настройка в коллекторе не обязательна.

### Извлечение кода ошибки из тела лога (JSON)

Когда логи приходят как JSON в теле записи (например, из filelog), можно вынести поле кода в атрибут в коллекторе. Пример для **transform** processor (OTTL), если код в body под ключом `error_code`:

```yaml
processors:
  transform/extract-error-code:
    log_statements:
      - context: log
        statements:
          - set(attributes["error.code"], body["error_code"]) where body["error_code"] != nil
```

После этого в SigNoz можно фильтровать и строить алерты по `error.code`.

### По стекам: где задавать уровень и код ошибки

| Стек    | Уровень лога (severity) | Код ошибки в логах |
|---------|-------------------------|---------------------|
| Node.js | Уровень из logger (pino, winston и т.д.) маппится в severity при экспорте OTLP. | Добавлять поле в структурированный лог (например `err.code`) и при экспорте в OTLP — в attributes. |
| Python  | logging level (DEBUG, INFO, WARNING, ERROR) маппится в severity. | В LogRecord добавлять attribute `error.code` или поле в record. |
| Java    | Уровень из SLF4J/Logback маппится в severity. | MDC или структурированный формат (JSON) с полем code/errorCode. |
| Go      | Уровень при создании LogRecord в SDK. | Добавлять attribute при вызове Logger (например `Attributes: []attribute.KeyValue{attribute.String("error.code", code)}`). |
| .NET    | LogLevel маппится в severity. | В scope или свойствах лога задать свойство с кодом ошибки. |
| PHP     | Уровень из моноинструментации или при создании span/лога. | Добавлять в атрибуты или в тело лога (JSON). |

Рекомендация: в каждом стеке использовать **единое имя атрибута** (например `error.code`) и при необходимости маппить в него поля из своего формата (err_code, code, errorCode) в коллекторе или в приложении.

### Фильтрация по коду ошибки в SigNoz

- В **Logs** в запросе добавить условие по атрибуту: `error.code = "E001"` или `error.code IN ["E001","E002"]`.
- В **Log-based alerts** задать условие по тому же атрибуту (например, срабатывание при появлении логов с `error.code = "E500"`).

### Фильтрация по коду ошибки в коллекторе

Чтобы **не отправлять** в SigNoz логи с определёнными кодами (или наоборот, оставлять только их), используйте в коллекторе **filter** processor с условием по атрибуту:

```yaml
processors:
  filter/drop-ignorable-errors:
    logs:
      log_record:
        # Отбросить логи с кодами, которые не нужны в SigNoz
        - 'attributes["error.code"] == "E_IGNORE"'
    error_mode: ignore
```

Или оставлять только критические коды:

```yaml
filter/keep-only-critical-codes:
  logs:
    log_record:
      - 'attributes["error.code"] != "E500" and attributes["error.code"] != "E503"'
  error_mode: ignore
```

(Условие «drop when not in list» зависит от возможностей OTTL; при необходимости используйте обратную логику или несколько условий.)

---

## 3. Пресеты по окружению и системам

Рекомендуемые варианты:

| Окружение / цель | Уровень в коллекторе | Коды ошибок |
|------------------|------------------------|-------------|
| Production       | Отбрасывать TRACE и DEBUG (`severity_number < SEVERITY_NUMBER_INFO`) | Собирать все; фильтрация и алерты по `error.code` в SigNoz. |
| Staging          | Можно оставить DEBUG для части сервисов (разные пайплайны или условие по service.name). | Аналогично production. |
| Разные системы   | Один общий порог по уровню; при необходимости — отдельные условия по `resource["service.name"]`. | Единый атрибут `error.code`; при разных форматах — извлечение в коллекторе (transform) в `error.code`. |

Итог: настройки по стекам и системам сводятся к (1) единому маппингу уровня в severity и при необходимости фильтру по уровню в коллекторе, (2) единому атрибуту `error.code` в логах и при необходимости его извлечению в коллекторе, (3) фильтрации и алертам по уровню и `error.code` в SigNoz.

Конфигурационные фрагменты коллектора — в [collector/processors.log-filtering.yaml](../collector/processors.log-filtering.yaml).
