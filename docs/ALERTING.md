# Настройка алертинга в SigNoz

## Обзор

- **Правила алертов** создаются в UI SigNoz (Alerts → New Alert): по метрикам (latency, error rate, host CPU и т.д.) и по логам (log-based alerts).
- **Доставка уведомлений** (email и др.) в self-hosted инстансе настраивается через **Alertmanager** — переменными окружения.

SigNoz Cloud: каналы настраиваются в интерфейсе; ниже в основном про self-hosted.

## Создание алерта в UI

1. **Alerts** → **New Alert**.
2. **Metric-based**: выберите метрику (например, `signoz_latency_p99` или host CPU), оператор (Above/Below), порог, окно оценки.
3. **Log-based**: постройте запрос в Logs Query Builder (фильтр + агрегация), задайте условие (count above X и т.д.) и окно.
4. Укажите канал уведомлений (после настройки Alertmanager он появится в списке).

Документация:

- [Alert Management](https://signoz.io/docs/alerts)
- [Metrics-based alerts](https://signoz.io/docs/alerts-management/metrics-based-alerts)
- [Log-based alerts](https://signoz.io/docs/alerts-management/log-based-alerts)

## Alertmanager (Self-Hosted): переменные окружения

Эти переменные задаются в среде, где запущен SigNoz (docker-compose `environment`, Helm `extraEnv`, и т.д.).

### Внешний URL

Нужен, чтобы в письмах и уведомлениях были корректные ссылки на SigNoz:

```bash
SIGNOZ_ALERTMANAGER_SIGNOZ_EXTERNAL__URL=https://signoz.example.com
```

### SMTP (email)

| Переменная | Описание |
|------------|----------|
| `SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__SMARTHOST` | Адрес и порт SMTP (например `smtp.example.com:587`) |
| `SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__FROM` | Адрес отправителя |
| `SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__AUTH__USERNAME` | Логин SMTP |
| `SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__AUTH__PASSWORD` | Пароль (или используйте `_FILE` для пути к файлу) |
| `SIGNOZ_ALERTMANAGER_SIGNOZ_GLOBAL_SMTP__REQUIRE__TLS` | Требовать TLS (по умолчанию true) |

Полный список: [Alertmanager Configuration](https://signoz.io/docs/manage/administrator-guide/configuration/alertmanager/).

Пример готового блока — в [alerts/alertmanager.env.example](../alerts/alertmanager.env.example).

## Типичные алерты

- **Высокая задержка**: метрика p99 latency выше порога за N минут.
- **Ошибки**: error rate или count ошибок в логах выше порога.
- **Инфраструктура**: CPU/память хоста выше порога (используются host metrics из коллектора).
- **Логи**: количество логов с уровнем ERROR за период выше порога (log-based alert).

После настройки SMTP и внешнего URL создайте в UI нужные правила и привяжите к ним канал уведомлений.
