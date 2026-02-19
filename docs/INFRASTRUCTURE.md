# Мониторинг инфраструктуры в SigNoz

SigNoz отображает метрики хостов в разделе **Infrastructure** (Hosts). Для этого коллектор должен отправлять **host metrics** в SigNoz.

## Как включить

В конфигах стартерпака метрики хоста уже добавлены там, где это уместно:

- **config.full.yaml** — полный конфиг: OTLP + hostmetrics + filelog (Docker + host).
- **config.vm.yaml** — VM: OTLP + hostmetrics + filelog (без Docker logs).

Receiver `hostmetrics` собирает:

- CPU, memory, load, filesystem, disk, network, paging, process/processes, system.

Процессор `resourcedetection` (detectors: `env`, `system`, при необходимости `docker`) добавляет к метрикам атрибуты хоста (`host.name` и др.), чтобы в SigNoz отображалось имя машины.

## Где смотреть в SigNoz

- **Infrastructure** → **Hosts** — список хостов с CPU, памятью, диском, сетью и статусом.
- Клик по хосту — детали: вкладки Metrics, Traces, Logs с фильтрацией по этому хосту.

## Требования к коллектору

- Коллектор должен работать на том же хосте (или иметь доступ к его метрикам). На VM обычно ставят бинарник или контейнер с примонтированными `/proc`, `/sys` при необходимости.
- В Docker: для полного сбора host metrics контейнеру часто монтируют `/proc`, `/sys` и т.д. (см. [Collect Host Metrics](https://signoz.io/docs/infrastructure-monitoring/hostmetrics/)). В минимальном варианте (только OTLP + Docker logs) hostmetrics можно не использовать — тогда конфиг `config.docker.yaml` без hostmetrics подойдёт.

## Алерты по инфраструктуре

В UI SigNoz (Alerts) можно создать алерты по метрикам хоста (например, CPU > 80%, свободное место на диске ниже порога). Источник метрик — те же host metrics, что отображаются в Infrastructure → Hosts.

Подробнее: [Infrastructure Monitoring](https://signoz.io/docs/infrastructure-monitoring/overview/), [Host metrics](https://signoz.io/docs/infrastructure-monitoring/hostmetrics/).
