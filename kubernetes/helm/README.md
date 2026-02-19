# Примеры values для Helm (Kubernetes)

| Файл | Назначение |
|------|------------|
| **signoz-values.example.yaml** | Минимальный values для установки SigNoz в кластер (`helm install signoz signoz/signoz ...`). |
| **k8s-infra-values.example.yaml** | Values для чарта k8s-infra: сбор логов подов, метрик нод и кластера, OTLP от приложений. |

Перед установкой скопируйте нужный файл, подставьте свой `storageClass`, `clusterName`, `otelCollectorEndpoint` и при необходимости `signozApiKey`.

Полная инструкция: [docs/KUBERNETES_HELM.md](../../docs/KUBERNETES_HELM.md).
