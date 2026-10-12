from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

import pandas as pd
from pathlib import Path


FILE_NAME = "test_dataset"
DATA_DIR = Path(Variable.get("data_dir"))
POSTGRES_CONN_ID = "postgres-db"
SCHEMA_NAME = "stage"


def create_schema():
    postgres_hook = PostgresHook(postgres_conn_id=POSTGRES_CONN_ID)
    postgres_hook.run(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA_NAME};")


def load_csv():
    df = pd.read_csv(
        DATA_DIR / f"{FILE_NAME}.csv",
        sep="|",
        decimal=".",
        parse_dates=["load_date"],
    )

    postgres_hook = PostgresHook(postgres_conn_id=POSTGRES_CONN_ID)
    engine = postgres_hook.get_sqlalchemy_engine()

    try:
        df.to_sql(
            name=FILE_NAME,
            con=engine,
            schema=SCHEMA_NAME,
            if_exists="replace",
            index=False,
            chunksize=5000,
            method="multi",
        )
    finally:
        engine.dispose()


with DAG(
    dag_id="csv_to_postgres",
    schedule=None,
    catchup=False,
) as dag:

    create_schema_task = PythonOperator(
        task_id="create_schema",
        python_callable=create_schema,
    )

    load_csv_task = PythonOperator(
        task_id="load_csv",
        python_callable=load_csv,
    )

    create_schema_task >> load_csv_task