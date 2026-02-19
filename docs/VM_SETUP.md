# Установка коллектора на виртуальной машине (VM)

На VM (Linux/Windows) коллектор можно запустить как **бинарник** (otelcol-contrib) или в **Docker**. Ниже — кратко по бинарнику на Linux.

## Linux: бинарник OpenTelemetry Collector Contrib

### 1. Установка

Следуйте официальной инструкции SigNoz для VM:

- [OpenTelemetry Binary in Virtual Machine](https://signoz.io/docs/tutorial/opentelemetry-binary-usage-in-virtual-machine/)

Обычно:

- Скачивается архив с [releases](https://github.com/open-telemetry/opentelemetry-collector-releases/releases) (distribution `otelcol-contrib`).
- Распаковка в `/usr/local` или отдельный каталог.
- Создание unit-файла systemd для службы `otelcol-contrib`.

### 2. Конфигурация

- Используйте конфиг из стартерпака: **config.vm.yaml** (или **config.full.yaml** без Docker-части, если не нужны логи контейнеров).
- Скопируйте его в каталог, указанный в unit-файле (часто `/etc/otelcol-contrib/config.yaml`).
- Замените в конфиге:
  - `<SIGNOZ_ENDPOINT>` — адрес SigNoz (Cloud: `ingest.<REGION>.signoz.cloud:443`, self-hosted: `<host>:4317`).
  - `<INGESTION_KEY>` — ключ Cloud или удалите блок `headers` для self-hosted.
- При необходимости отредактируйте `filelog/host.include` под пути к логам на этой VM.

### 3. Запуск

```bash
sudo systemctl daemon-reload
sudo systemctl enable otelcol-contrib
sudo systemctl start otelcol-contrib
sudo systemctl status otelcol-contrib
```

Логи: `journalctl -u otelcol-contrib -f`.

### 4. Порты

- 4317 — gRPC OTLP (traces, metrics, logs от приложений).
- 4318 — HTTP OTLP (если нужен).
- 13133 — health_check (опционально).

Откройте их в firewall для приложений на этой VM и (при необходимости) для SigNoz.

## Windows

- Установка бинарника: см. [документацию OpenTelemetry Collector](https://opentelemetry.io/docs/collector/installation/) для Windows.
- Конфиг — тот же `config.vm.yaml` (или аналог без Linux-специфичных путей); пути к логам укажите в формате Windows (`C:\\Logs\\*.log` и т.д.).

## Docker на VM

Если на VM установлен Docker, можно запускать коллектор из стартерпака через [docker-compose.collector.yml](../docker-compose.collector.yml), подставив нужный конфиг (например, скопировать `config.vm.yaml` в `config.yaml` и указать его в volume). Для host metrics в контейнере может понадобиться монтирование `/proc`, `/sys` — см. [Host metrics (SigNoz)](https://signoz.io/docs/infrastructure-monitoring/hostmetrics/).

## Развёртывание в системах виртуализации

Подробные рекомендации по развёртыванию в **VMware (vSphere/ESXi)**, Hyper-V, KVM и облаках (сеть, ресурсы ВМ, шаблоны, OVF) см. в [DEPLOYMENT_VIRTUALIZATION.md](DEPLOYMENT_VIRTUALIZATION.md).
