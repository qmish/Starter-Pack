# Ansible: развёртывание OpenTelemetry Collector на VM

Роль устанавливает OpenTelemetry Collector Contrib (бинарник) на Linux-хосты, настраивает systemd и конфиг с отправкой в SigNoz (Cloud или self-hosted).

## Требования

- Ansible 2.14+
- Доступ по SSH к целевым хостам (sudo)

## Быстрый старт

```bash
cd ansible
cp group_vars/all.yml.example group_vars/all.yml
# Отредактируйте group_vars/all.yml: signoz_endpoint, signoz_ingestion_key

cp inventory.yml.example inventory.yml
# Укажите ваши хосты в inventory.yml

ansible-playbook -i inventory.yml playbook.yml
```

## Переменные (group_vars/all.yml)

| Переменная | Описание |
|------------|----------|
| `signoz_endpoint` | Endpoint SigNoz (Cloud: `ingest.<region>.signoz.cloud:443`, self-hosted: `host:4317`) |
| `signoz_ingestion_key` | Ключ SigNoz Cloud; для self-hosted — пустая строка |
| `collector_version` | Версия otelcol-contrib (например `0.130.1`) |
| `collector_config_path` | Путь к конфигу на хосте (`/etc/otelcol-contrib/config.yaml`) |
| `collector_filelog_paths` | Список путей к логам для filelog |

## Группа хостов

Плейбук выполняется на группе `signoz_collectors`. В `inventory.yml` добавьте хосты в эту группу.

## Дополнительно

- Установка бинарника: скачивание с GitHub releases, распаковка в `collector_binary_dir`, systemd unit.
- Конфиг генерируется из шаблона (OTLP, hostmetrics, filelog); endpoint и ключ подставляются из переменных.
- После изменений конфига или unit выполните плейбук повторно — handler перезапустит сервис.

См. также: [VM_SETUP.md](../docs/VM_SETUP.md), [DEPLOYMENT_VIRTUALIZATION.md](../docs/DEPLOYMENT_VIRTUALIZATION.md).
