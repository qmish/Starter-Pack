# Развёртывание в Kubernetes с Helm

Два основных варианта:

1. **SigNoz self-hosted в кластере** — Helm-чарт SigNoz (backend + встроенный коллектор).
2. **Сбор телеметрии из кластера** — чарт **k8s-infra**: DaemonSet с OpenTelemetry Collector на каждой ноде (логи подов, метрики нод/kubelet, OTLP от приложений) и опционально Deployment для метрик кластера и событий.

Ниже — установка через Helm и настройка сбора логов подов и метрик.

---

## Требования

- Kubernetes 1.22+
- Helm 3.8+
- `kubectl` с доступом к кластеру
- Для SigNoz self-hosted: минимум 8 GB RAM, 4 CPU, 30 GB storage (рекомендуется 16 GB / 8 cores / 80 GB)

---

## Вариант A: SigNoz self-hosted в Kubernetes

### 1. Добавить репозиторий и установить SigNoz

```bash
helm repo add signoz https://charts.signoz.io
helm repo update
```

Создайте `values.yaml` (укажите свою StorageClass):

```yaml
global:
  storageClass: <your-storage-class>

clickhouse:
  installCustomStorageClass: true
```

Установка:

```bash
helm install signoz signoz/signoz \
  --namespace signoz --create-namespace \
  --wait --timeout 1h \
  -f values.yaml
```

Полный список параметров: [SigNoz Helm chart](https://github.com/SigNoz/charts/tree/main/charts/signoz#configuration).

### 2. Проверка

```bash
kubectl port-forward -n signoz svc/signoz 8080:8080
curl http://localhost:8080/api/v1/health
# Ожидается: {"status":"ok"}
```

Приложения в кластере могут слать OTLP на сервис `signoz-otel-collector.signoz.svc.cluster.local:4317`. Чтобы дополнительно собирать **логи подов** и **метрики нод/кластера**, установите чарт **k8s-infra** (Вариант B), настроив его на отправку в этот же SigNoz.

---

## Вариант B: Сбор телеметрии из кластера (k8s-infra)

Чарт **k8s-infra** разворачивает:

- **OTelAgent DaemonSet** — на каждой ноде: приём OTLP, сбор логов подов (filelog по `/var/log/pods`), host metrics, kubelet metrics, обогащение метаданными Kubernetes.
- **OtelDeployment** (опционально) — метрики уровня кластера, события K8s.

Подходит и для **SigNoz Cloud**, и для **self-hosted** SigNoz (в том числе установленного по Варианту A).

### 1. Подключить репозиторий

```bash
helm repo add signoz https://charts.signoz.io
helm repo update
```

### 2. Конфигурация для SigNoz Cloud

Создайте `k8s-infra-values.yaml`:

```yaml
global:
  cloud: others
  clusterName: my-cluster
  deploymentEnvironment: production

# Endpoint SigNoz Cloud (подставьте регион: us, in, eu)
otelCollectorEndpoint: ingest.us.signoz.cloud:443
otelInsecure: false
signozApiKey: <your-ingestion-key>

presets:
  otlpExporter:
    enabled: true
  logsCollection:
    enabled: true
    startAt: end
    blacklist:
      enabled: true
      signozLogs: true
      namespaces:
        - kube-system
  hostMetrics:
    enabled: true
    collectionInterval: 30s
  kubeletMetrics:
    enabled: true
  kubernetesAttributes:
    enabled: true
  clusterMetrics:
    enabled: true
  k8sEvents:
    enabled: true
```

### 3. Конфигурация для self-hosted SigNoz (в том же кластере)

Если SigNoz установлен в namespace `signoz`:

```yaml
global:
  cloud: others
  clusterName: my-cluster
  deploymentEnvironment: production

# Адрес коллектора SigNoz внутри кластера
otelCollectorEndpoint: signoz-otel-collector.signoz.svc.cluster.local:4317
otelInsecure: true
# Ключ для self-hosted не нужен
signozApiKey: ""

presets:
  otlpExporter:
    enabled: true
  logsCollection:
    enabled: true
  hostMetrics:
    enabled: true
  kubeletMetrics:
    enabled: true
  kubernetesAttributes:
    enabled: true
  clusterMetrics:
    enabled: true
  k8sEvents:
    enabled: true
```

### 4. Установка k8s-infra

```bash
helm install my-release signoz/k8s-infra \
  --namespace platform --create-namespace \
  -f k8s-infra-values.yaml
```

Или обновление уже установленного релиза:

```bash
helm upgrade --install my-release signoz/k8s-infra \
  -n platform -f k8s-infra-values.yaml
```

После установки логи подов из всех namespace (кроме исключённых в blacklist) и метрики нод/кластера начнут поступать в SigNoz.

### 5. Направление приложений на коллектор

Приложения в подах должны отправлять OTLP на коллектор. При использовании k8s-infra коллектор работает как **DaemonSet** на каждой ноде и слушает hostPort. Удобно задать endpoint через `HOST_IP`:

```yaml
env:
  - name: HOST_IP
    valueFrom:
      fieldRef:
        fieldPath: status.hostIP
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://$(HOST_IP):4317"
  - name: OTEL_EXPORTER_OTLP_PROTOCOL
    value: grpc
  - name: OTEL_SERVICE_NAME
    value: my-app
  - name: OTEL_RESOURCE_ATTRIBUTES
    value: "k8s.pod.name=$(POD_NAME),k8s.namespace.name=$(POD_NAMESPACE)"
```

Либо использовать сервисный адрес OTel Agent (если не hostPort):  
`my-release-k8s-infra-otel-agent.platform.svc.cluster.local:4317`.

Подробнее: [Configure K8s Infra](https://signoz.io/docs/opentelemetry-collection-agents/k8s/k8s-infra/configure-k8s-infra/), [Collect Kubernetes Pod Logs](https://signoz.io/docs/userguide/collect_kubernetes_pod_logs/).

---

## Примеры values в стартерпаке

В каталоге [kubernetes/helm/](../kubernetes/helm/) лежат примеры:

- **signoz-values.example.yaml** — минимальный values для установки SigNoz.
- **k8s-infra-values.example.yaml** — пример values для k8s-infra (Cloud и self-hosted, с включённым сбором логов подов).

Скопируйте нужный файл в `values.yaml` / `k8s-infra-values.yaml`, подставьте свой storage class, cluster name, endpoint и API key.

---

## Кратко: что попадает в SigNoz

| Источник | Как включается | Где смотреть в SigNoz |
|----------|----------------|------------------------|
| Трейсы/метрики/логи приложений (OTLP) | Приложения шлют на OTel Agent (hostIP:4317 или сервис) | Traces, Metrics, Logs |
| Логи подов кластера | `presets.logsCollection.enabled: true` в k8s-infra | Logs (по namespace/pod/container) |
| Метрики нод (CPU, память и т.д.) | `presets.hostMetrics.enabled: true` | Infrastructure → Hosts |
| Метрики kubelet (поды/контейнеры) | `presets.kubeletMetrics.enabled: true` | Metrics / дашборды |
| Метрики кластера (узлы, ресурсы) | `presets.clusterMetrics.enabled: true` | Metrics |
| События Kubernetes | `presets.k8sEvents.enabled: true` | События/логи |

Исключение/включение логов по namespace, подам и контейнерам настраивается через `presets.logsCollection.blacklist` / `whitelist` в values k8s-infra. Подробнее — в [LOGGING_DOCKER_K8S.md](LOGGING_DOCKER_K8S.md).
