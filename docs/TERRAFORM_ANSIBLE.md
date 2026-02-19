# Развёртывание коллектора: Terraform и Ansible

Краткое описание вариантов развёртывания OpenTelemetry Collector с помощью **Terraform** (Docker на хосте) и **Ansible** (бинарник на VM).

---

## Terraform (Docker)

Каталог: **terraform/collector-docker/**.

- Запускает коллектор в **Docker-контейнере** на текущем хосте.
- Конфиг генерируется из шаблона: подставляются `signoz_endpoint` и `signoz_ingestion_key`.
- Требуется: Terraform 1.x, Docker, [Docker provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest).

**Пример:**

```bash
cd terraform/collector-docker
terraform init
terraform apply -var="signoz_endpoint=ingest.us.signoz.cloud:443" -var="signoz_ingestion_key=YOUR_KEY"
```

Подробности и переменные — в [terraform/collector-docker/README.md](../terraform/collector-docker/README.md).

**Когда использовать:** единый хост с Docker, инфраструктура как код (IaC), повторяемый деплой коллектора без ручного копирования конфигов.

---

## Ansible (VM, бинарник)

Каталог: **ansible/**.

- Устанавливает **бинарник** OpenTelemetry Collector Contrib на Linux-хосты по SSH.
- Настраивает systemd, конфиг (OTLP, hostmetrics, filelog), пути к логам задаются переменными.
- Подходит для VMware/гипервизоров и любых VM без Docker.

**Пример:**

```bash
cd ansible
cp group_vars/all.yml.example group_vars/all.yml
# Указать signoz_endpoint, signoz_ingestion_key в group_vars/all.yml
cp inventory.yml.example inventory.yml
# Указать хосты в inventory.yml

ansible-playbook -i inventory.yml playbook.yml
```

Подробности — в [ansible/README.md](../ansible/README.md).

**Когда использовать:** несколько VM, централизованное управление конфигом и версией коллектора, интеграция с существующим Ansible-парком.

---

## Сравнение

| Критерий | Terraform (Docker) | Ansible (бинарник) |
|----------|--------------------|---------------------|
| Среда | Хост с Docker | Linux VM (без обязательного Docker) |
| Установка | Контейнер из образа | Скачивание бинарника, systemd |
| Конфиг | Шаблон Terraform → файл на хосте | Jinja2-шаблон роли |
| Масштаб | Один хост (можно расширить модулями на несколько) | Много хостов по inventory |

Оба варианта не хранят секреты в репозитории: endpoint и ключ задаются переменными (tfvars, group_vars) или CI/CD.

---

## Связь с остальной документацией

- **VM без IaC:** установка вручную — [VM_SETUP.md](VM_SETUP.md).
- **Виртуализация (VMware, Hyper-V, KVM):** [DEPLOYMENT_VIRTUALIZATION.md](DEPLOYMENT_VIRTUALIZATION.md).
- **Kubernetes/Helm:** [KUBERNETES_HELM.md](KUBERNETES_HELM.md).
