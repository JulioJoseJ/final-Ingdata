from datetime import datetime, timezone

from airflow import DAG
from airflow.operators.python import PythonOperator
from runtime import run_dbt

with DAG(
    dag_id="examen_ventas",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    max_active_tasks=1,
    default_args={"retries": 0},
    tags=["examen"],
) as dag:
    # Comprueba la actualidad de raw.ventas (max(_loaded_at) vs. ahora, en UTC).
    # warn (>12 h) -> dbt sale con código 0 -> success; error (>24 h) -> código != 0 -> failed.
    comprobar_freshness = PythonOperator(
        task_id="comprobar_freshness",
        python_callable=run_dbt,
        op_args=[["source", "freshness"]],
    )

    construir_resumen = PythonOperator(
        task_id="construir_resumen",
        python_callable=run_dbt,
        op_args=[["build"]],
    )

    # trigger_rule por defecto (all_success): si freshness falla, build queda upstream_failed.
    comprobar_freshness >> construir_resumen
