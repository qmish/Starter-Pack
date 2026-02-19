# SigNoz Monitoring Starter Pack

Универсальный стартерпак для подключения любой системы (разные стеки) к мониторингу **SigNoz**: трейсы, метрики, логи хоста и сервисов, инфраструктура, алертинг.

## Что внутри

| Компонент | Описание |
|-----------|----------|
| **OpenTelemetry Collector** | Единая точка приёма телеметрии: OTLP (traces/metrics/logs), host metrics, file logs, Docker logs, syslog |
| **Стеки приложений** | Готовые переменные окружения и реальные SDK/OTLP (package.json, requirements.txt, go.mod, pom.xml, composer.json, .csproj) для Node.js, Python, Java, Go, .NET, PHP |
| **Алертинг** | Примеры настройки Alertmanager (SMTP, внешний URL) |
| **Логи хоста** | Конфигурация сбора логов из файлов и системных логов |

Поддерживаются **SigNoz Cloud** и **Self-Hosted** SigNoz.

## Быстрый старт

### 1. SigNoz

- **Cloud:** [signoz.io/teams](https://signoz.io/teams) → создайте инстанс, возьмите Ingestion Key и регион.
- **Self-Hosted:** [Установка SigNoz](https://signoz.io/docs/install/self-host/) (Docker/K8s). Endpoint: `http://<host>:4317` (gRPC) или `:4318` (HTTP).

### 2. Переменные окружения

```bash
cp .env.example .env
# Отредактируйте .env: SIGNOZ_OTEL_ENDPOINT и при необходимости SIGNOZ_INGESTION_KEY (для Cloud)
```

### 3. Запуск коллектора

**Docker (на хосте с приложениями в Docker):**

```bash
# Подставить endpoint и ключ из .env в конфиг (опционально):
# Linux/Mac:  ./scripts/prepare-config.sh full
# Windows:    .\scripts\prepare-config.ps1 -Preset full

# Скопировать конфиг и вручную отредактировать endpoint/key, если не использовали скрипт:
# copy collector\config.full.yaml collector\config.yaml

docker compose -f docker-compose.collector.yml up -d
```

Для сбора логов контейнеров раскомментируйте в `docker-compose.collector.yml` volumes и опции для доступа к `/var/lib/docker/containers`.

**Kubernetes (Helm):** установка SigNoz и сбор логов подов/метрик — [docs/KUBERNETES_HELM.md](docs/KUBERNETES_HELM.md). Примеры values в [kubernetes/helm/](kubernetes/helm/).

**VM / виртуализация:** см. [docs/VM_SETUP.md](docs/VM_SETUP.md). Развёртывание в VMware, Hyper-V, KVM — [docs/DEPLOYMENT_VIRTUALIZATION.md](docs/DEPLOYMENT_VIRTUALIZATION.md).

**Terraform (Docker) и Ansible (VM):** развёртывание коллектора через IaC — [docs/TERRAFORM_ANSIBLE.md](docs/TERRAFORM_ANSIBLE.md) ([terraform/](terraform/), [ansible/](ansible/)).

### 4. Подключение приложения

Выберите стек в `stacks/` и задайте переменные окружения (или используйте `stacks/<stack>/env.example`):

```bash
# Пример для Node.js
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_SERVICE_NAME=my-node-app
```

Перезапустите приложение. Трейсы/метрики/логи появятся в SigNoz.

### Чеклист первого запуска

1. **SigNoz** — Cloud или self-hosted; записать endpoint и при необходимости Ingestion Key.
2. **`.env`** — скопировать из `.env.example`, указать `SIGNOZ_OTEL_ENDPOINT` и `SIGNOZ_INGESTION_KEY` (для Cloud).
3. **Конфиг коллектора** — выполнить `.\scripts\prepare-config.ps1 -Preset full` (Windows) или `./scripts/prepare-config.sh full` (Linux/macOS), либо вручную скопировать `collector/config.full.yaml` в `collector/config.yaml` и подставить endpoint/key.
4. **Коллектор** — `docker compose -f docker-compose.collector.yml up -d`.
5. **Демо по стеку** — в каталоге `stacks/<stack>` установить зависимости и запустить приложение (см. [docs/RUNBOOK.md](docs/RUNBOOK.md) и `stacks/<stack>/README.md`).

Полный пошаговый чеклист и команды по стекам — [docs/RUNBOOK.md](docs/RUNBOOK.md).

## Структура репозитория

```
.
├── .env.example                 # Шаблон переменных (endpoint, ключ, алерты)
├── collector/
│   ├── config.full.yaml         # Полный конфиг: OTLP + host + file + docker logs
│   ├── config.docker.yaml       # Только OTLP + логи контейнеров Docker
│   ├── config.vm.yaml           # VM: OTLP + host metrics + логи из файлов
│   └── config.k8s.yaml         # Kubernetes: OTLP + логи подов
├── docker-compose.collector.yml # Запуск коллектора (Docker)
├── kubernetes/helm/            # Примеры values для Helm (SigNoz, k8s-infra)
├── stacks/                      # Примеры env под разные стеки
│   ├── node/
│   ├── python/
│   ├── java/
│   ├── go/
│   ├── dotnet/
│   └── php/
├── alerts/                      # Алертинг (Alertmanager, примеры правил)
├── terraform/                   # Terraform: коллектор в Docker (collector-docker)
├── ansible/                     # Ansible: роль установки коллектора на VM
└── docs/                        # Документация
    ├── HOST_LOGS.md
    ├── ALERTING.md
    ├── INFRASTRUCTURE.md
    ├── VM_SETUP.md
    ├── DEPLOYMENT_VIRTUALIZATION.md   # VMware, Hyper-V, KVM
    ├── KUBERNETES_HELM.md             # Kubernetes, Helm (SigNoz + k8s-infra)
    ├── LOGGING_DOCKER_K8S.md          # Логи Docker-контейнеров и подов K8s
    ├── LOGGING_FILTERING.md           # Фильтрация логов по уровням и кодам ошибок
    ├── TRACING_SETUP.md               # Трассировка по стекам и системам
    ├── TERRAFORM_ANSIBLE.md           # Развёртывание коллектора: Terraform, Ansible
    └── RUNBOOK.md                     # Чеклист первого запуска, демо по стекам
```

## Выбор конфигурации коллектора

| Сценарий | Конфиг | Использование |
|----------|--------|----------------|
| Docker-хост (приложения в контейнерах) | `config.full.yaml` или `config.docker.yaml` | Логи контейнеров + OTLP + опционально host metrics |
| Kubernetes (логи подов, свой DaemonSet) | `config.k8s.yaml` или чарт **k8s-infra** | Логи подов + OTLP; предпочтительно [k8s-infra Helm](docs/KUBERNETES_HELM.md) |
| Виртуальная машина / bare metal | `config.vm.yaml` или `config.full.yaml` | Метрики хоста + логи из файлов + OTLP |
| Только приложения (без логов хоста) | `config.docker.yaml` (без filelog) | Минимальный вариант |

Подробнее: [docs/INFRASTRUCTURE.md](docs/INFRASTRUCTURE.md), [docs/HOST_LOGS.md](docs/HOST_LOGS.md), [docs/LOGGING_DOCKER_K8S.md](docs/LOGGING_DOCKER_K8S.md) (Docker и логи подов K8s).

## Алертинг

- В SigNoz: создание алертов по метрикам и логам через UI (Alerts).
- У Self-Hosted SigNoz настройка доставки (email и др.) — через Alertmanager (env-переменные). Примеры: [alerts/README.md](alerts/README.md), [docs/ALERTING.md](docs/ALERTING.md).

## Документация

- [HOST_LOGS.md](docs/HOST_LOGS.md) — логи хоста и сервисов (filelog, syslog, Docker).
- [ALERTING.md](docs/ALERTING.md) — настройка алертинга (SMTP, внешний URL).
- [INFRASTRUCTURE.md](docs/INFRASTRUCTURE.md) — мониторинг инфраструктуры (host metrics).
- [VM_SETUP.md](docs/VM_SETUP.md) — установка коллектора на VM (бинарник/systemd).
- [DEPLOYMENT_VIRTUALIZATION.md](docs/DEPLOYMENT_VIRTUALIZATION.md) — развёртывание в VMware (vSphere/ESXi), Hyper-V, KVM, облака.
- [KUBERNETES_HELM.md](docs/KUBERNETES_HELM.md) — развёртывание в Kubernetes (Helm: SigNoz, k8s-infra), логи подов и метрики кластера.
- [LOGGING_DOCKER_K8S.md](docs/LOGGING_DOCKER_K8S.md) — логирование Docker-контейнеров и подов Kubernetes.
- [LOGGING_FILTERING.md](docs/LOGGING_FILTERING.md) — фильтрация логов по уровням (severity) и кодам ошибок, по стекам и системам.
- [TRACING_SETUP.md](docs/TRACING_SETUP.md) — сбор и настройка трассировки по стекам и системам (sampling, атрибуты, распространение контекста).
- [TERRAFORM_ANSIBLE.md](docs/TERRAFORM_ANSIBLE.md) — развёртывание коллектора через Terraform (Docker) и Ansible (VM).
- [RUNBOOK.md](docs/RUNBOOK.md) — чеклист первого запуска и запуск демо-приложений по стекам.

## Зависимости и обновление SDK

В каждом стеке в `stacks/<stack>/` подключены реальные пакеты OpenTelemetry SDK и OTLP exporter (с возможностью обновления). Как обновлять — см. [DEPENDENCIES.md](DEPENDENCIES.md).

## Ссылки

- [SigNoz Docs](https://signoz.io/docs/)
- [OpenTelemetry Collector (SigNoz)](https://signoz.io/docs/opentelemetry-collection-agents/get-started/)
- [Instrumentation по языкам](https://signoz.io/docs/instrumentation/)
