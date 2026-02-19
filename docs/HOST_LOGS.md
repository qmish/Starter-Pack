# Логи хоста и сервисов в SigNoz

Стартерпак позволяет собирать:

1. **Логи приложений по OTLP** — приложение шлёт логи в коллектор (по стеку см. `stacks/`).
2. **Логи Docker-контейнеров** — через `filelog` и путь `/var/lib/docker/containers/*/*-json.log` (конфиги `config.full.yaml`, `config.docker.yaml`).
3. **Логи из файлов на хосте** — через receiver `filelog` в конфиге коллектора.
4. **Syslog** — через receiver `syslog` и перенаправление rsyslog в коллектор (опционально).

## Логи из файлов (filelog)

В `config.full.yaml` и `config.vm.yaml` уже есть секция `filelog/host`. Настройте `include` под свою ОС и приложения.

### Linux

```yaml
filelog/host:
  include:
    - /var/log/syslog
    - /var/log/myapp/*.log
    - /var/log/nginx/access.log
  poll_interval: 500ms
  start_at: end
  include_file_name: true
```

### Windows

Если коллектор запущен на Windows и имеет доступ к диску:

```yaml
filelog/host:
  include:
    - C:\\Logs\\*.log
    - C:\\MyApp\\logs\\*.log
  poll_interval: 500ms
  start_at: end
```

Пути задаются в конфиге коллектора; переменная `HOST_LOG_PATHS` в `.env` используется только как подсказка — в YAML нужно прописать пути вручную или подставлять их при генерации конфига.

## Логи Docker-контейнеров

- Включены в `config.full.yaml` и `config.docker.yaml`.
- Коллектор должен иметь доступ к каталогу `/var/lib/docker/containers` (при запуске в Docker — volume `-v /var/lib/docker/containers:/var/lib/docker/containers:ro`).
- Подробнее: [Collect Docker logs (SigNoz)](https://signoz.io/docs/userguide/collect_docker_logs/).

## Syslog (Linux)

1. В конфиг коллектора добавьте receiver `syslog` (TCP, например порт 54527).
2. В `service.pipelines.logs.receivers` добавьте `syslog`.
3. Настройте rsyslog на хосте: пересылать логи на `localhost:54527` в формате RFC3164.

Пример receiver:

```yaml
receivers:
  syslog:
    tcp:
      listen_address: '0.0.0.0:54527'
    protocol: rfc3164
    location: UTC
    operators:
      - type: move
        from: attributes.message
        to: body
```

Подробнее: [Collecting Syslogs (SigNoz)](https://signoz.io/docs/userguide/collecting_syslogs/).

## Обогащение логов (host name и др.)

Процессор `resourcedetection` с детекторами `env`, `system` (и при необходимости `docker`) добавляет к логам атрибуты ресурса, в том числе `host.name`. Он уже включён в конфиги стартерпака в секции `processors` и в пайплайнах `logs`.

После настройки перезапустите коллектор и проверьте вкладку **Logs** в SigNoz.
