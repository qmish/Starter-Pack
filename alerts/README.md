# Алертинг SigNoz

В SigNoz алерты создаются через UI (по метрикам и логам). Доставка уведомлений (email, Slack и т.д.) в **self-hosted** настраивается через **Alertmanager** (переменные окружения).

## Создание правил в SigNoz

1. **Alerts** → **New Alert**.
2. Выберите тип: **Metric-based** или **Log-based**.
3. Задайте запрос (метрика/лог), порог и окно оценки.
4. Укажите канал уведомлений (после настройки Alertmanager).

Документация: [Alert Management](https://signoz.io/docs/alerts), [Log-based alerts](https://signoz.io/docs/alerts-management/log-based-alerts), [Metrics-based alerts](https://signoz.io/docs/alerts-management/metrics-based-alerts).

## Настройка Alertmanager (Self-Hosted)

Переменные задаются в окружении контейнера/пода SigNoz (или в `docker-compose` / Helm values).

### Внешний URL (обязательно для ссылок в письмах)

```bash
SIGNOZ_ALERTMANAGER_SIGNOZ_EXTERNAL__URL=https://signoz.example.com
```

### SMTP для email

```bash
SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__SMARTHOST=smtp.example.com:587
SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__FROM=alerts@example.com
SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__AUTH__USERNAME=your-user
SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__AUTH__PASSWORD=your-password
SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__REQUIRE__TLS=true
```

Готовый шаблон: [alertmanager.env.example](alertmanager.env.example).

Подробнее: [docs/ALERTING.md](../docs/ALERTING.md), [Alertmanager Configuration](https://signoz.io/docs/manage/administrator-guide/configuration/alertmanager/).
