# Java / JVM + SigNoz

1. Добавьте Java Agent или зависимость OpenTelemetry (например `opentelemetry-javaagent.jar`).

2. Задайте переменные из `env.example` или JVM options `-Dotel.*`.

3. Запуск с агентом (пример):
   ```bash
   java -javaagent:opentelemetry-javaagent.jar -jar app.jar
   ```

Подробнее: [SigNoz — Java](https://signoz.io/docs/instrumentation/java/).
