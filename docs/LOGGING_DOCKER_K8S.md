# Логирование Docker-контейнеров и подов Kubernetes

В стартерпаке предусмотрены два сценария сбора логов:

1. **Docker (на хосте)** — логи контейнеров из `/var/lib/docker/containers/*/*-json.log`.
2. **Kubernetes** — логи подов кластера (файлы на нодах в `/var/log/pods/` или через симлинки в `/var/log/containers/`).

Ниже — как это настроить и где смотреть логи в SigNoz.

---

## 1. Логи Docker-контейнеров (хост с Docker)

### Как это устроено

- На хосте с Docker логи каждого контейнера пишутся в файлы вида  
  `/var/lib/docker/containers/<container-id>/<container-id>-json.log`.
- OpenTelemetry Collector с receiver **filelog** в формате **container** (Docker) читает эти файлы, парсит JSON и отправляет логи в SigNoz.

### Конфигурация в стартерпаке

В конфигах **config.full.yaml** и **config.docker.yaml** уже есть секция:

```yaml
receivers:
  filelog/docker:
    include: [/var/lib/docker/containers/*/*-json.log]
    poll_interval: 200ms
    start_at: end
    operators:
      - type: container
        format: docker
        add_metadata_from_filepath: false
```

Для **Kubernetes** (логи подов на ноде в формате Docker/containerd) путь другой — см. раздел 2.

### Запуск коллектора с доступом к логам Docker

Коллектор должен иметь доступ к каталогу контейнеров. При запуске в **Docker** добавьте volume и при необходимости `user: "0:0"`:

```yaml
volumes:
  - /var/lib/docker/containers:/var/lib/docker/containers:ro
```

Пример полного варианта — в [docker-compose.collector.yml](../docker-compose.collector.yml) (раскомментируйте секцию volumes и при необходимости `pid: host`, `network_mode: host`).

### Где смотреть в SigNoz

- Вкладка **Logs**: фильтрация по контейнеру, по `service.name` (если задан в приложении или добавлен в конфиге коллектора).

Подробнее: [Collect Docker logs (SigNoz)](https://signoz.io/docs/userguide/collect_docker_logs/).

---

## 2. Логи подов Kubernetes

В Kubernetes логи контейнеров на ноде лежат в каталогах вида:

- **Стандартный путь:** `/var/log/pods/<namespace>_<pod>_<uid>/<container>/<n>.log`
- Часто доступны также по симлинкам: `/var/log/containers/<pod>_<namespace>_<container>-<container-id>.log`

Каждый под на ноде пишет в свой подкаталог; коллектор должен читать эти файлы **на каждой ноде**. Поэтому в кластере коллектор обычно ставят как **DaemonSet**.

### Рекомендуемый способ: чарт k8s-infra (Helm)

Чарт **signoz/k8s-infra** разворачивает OpenTelemetry Collector в режиме **DaemonSet**. В нём уже настроены:

- **filelog** по путям логов подов на ноде;
- обогащение метаданными Kubernetes (namespace, pod name, container, node);
- blacklist/whitelist по namespace, pod, container.

Включение и настройка — через **presets.logsCollection** в values:

```yaml
presets:
  logsCollection:
    enabled: true
    startAt: end
    includeFilePath: true
    includeFileName: false
    blacklist:
      enabled: true
      signozLogs: true
      namespaces:
        - kube-system
      pods: []        # исключить по имени пода
      containers: []  # исключить по имени контейнера
    # Либо whitelist — собирать только из указанных namespace/pod/container
    whitelist:
      enabled: false
      namespaces: []
      pods: []
      containers: []
```

Установка и пример values — в [KUBERNETES_HELM.md](KUBERNETES_HELM.md) и [kubernetes/helm/k8s-infra-values.example.yaml](../kubernetes/helm/k8s-infra-values.example.yaml).

После установки k8s-infra логи подов из выбранных namespace начинают поступать в SigNoz без дополнительной конфигурации.

Документация SigNoz: [Collect Kubernetes Pod Logs](https://signoz.io/docs/userguide/collect_kubernetes_pod_logs/), [K8s Infra - Configure](https://signoz.io/docs/opentelemetry-collection-agents/k8s/k8s-infra/configure-k8s-infra/).

### Альтернатива: свой коллектор с filelog по /var/log/pods

Если вы разворачиваете коллектор в кластере **без** чарта k8s-infra (например, свой DaemonSet с общим конфигом), можно использовать конфиг **collector/config.k8s.yaml** из стартерпака. В нём настроен filelog по путям логов подов и парсер формата контейнера с извлечением метаданных из пути файла (`add_metadata_from_filepath: true`).

Подключите этот конфиг к своему DaemonSet и смонтируйте на поды коллектора каталог `/var/log/pods` (и при необходимости `/var/lib/docker/containers` или `/var/log/containers` в зависимости от CRI). Пример конфига — в [collector/config.k8s.yaml](../collector/config.k8s.yaml).

---

## 3. Сводка

| Среда        | Источник логов              | Как включить |
|-------------|-----------------------------|--------------|
| Хост с Docker | Контейнеры Docker           | config.full.yaml / config.docker.yaml, volume `/var/lib/docker/containers` |
| Kubernetes  | Поды всех/выбранных namespace | Чарт k8s-infra, presets.logsCollection.enabled: true |
| Kubernetes  | Поды (свой DaemonSet)       | collector/config.k8s.yaml, volume `/var/log/pods` |

И в Docker, и в Kubernetes логи в SigNoz можно фильтровать по namespace, pod, container, уровню и тексту. Алерты по логам настраиваются в разделе Alerts (log-based alerts).
