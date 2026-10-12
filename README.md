# Запуск

1. Скачайте репозиторий

2. Создайте переменную окружения

    ```bash
    cp .env.example .env
    ```

3. Поместите `test_dataset.csv` в директорию `data/`

4. Запустите контейнеры:

   ```bash
   docker compose up -d
   ```

# Адреса

- Apache Airflow - http://localhost:8080

- Postgres - localhost:5432

- Clickhouse - localhost:8123