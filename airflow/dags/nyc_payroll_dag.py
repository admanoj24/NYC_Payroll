from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import sys
import os

# add project path so airflow can find your code
sys.path.insert(0, '/opt/airflow/scripts')

# default settings for all tasks
default_args = {
    'owner': 'manoj_adhikari',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

# ─────────────────────────────────────
# DEFINE DAG
# ─────────────────────────────────────
with DAG(
    dag_id='nyc_payroll_pipeline',
    default_args=default_args,
    description='NYC Payroll ETL Pipeline',
    schedule_interval='@daily',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['nyc_payroll', 'etl']
) as dag:

    # ─────────────────────────────────
    # TASK 1 - EXTRACT (RAW LAYER)
    # ─────────────────────────────────
    def run_raw_layer():
        print("Starting RAW layer...")
        print("RAW layer completed!")

    raw_task = PythonOperator(
        task_id='extract_raw_layer',
        python_callable=run_raw_layer
    )

    # ─────────────────────────────────
    # TASK 2 - TRANSFORM (STAGING)
    # ─────────────────────────────────
    def run_stg_layer():
        print("Starting STAGING layer...")
        print("STAGING layer completed!")

    stg_task = PythonOperator(
        task_id='transform_stg_layer',
        python_callable=run_stg_layer
    )

    # ─────────────────────────────────
    # TASK 3 - LOAD (WAREHOUSE)
    # ─────────────────────────────────
    def run_final_layer():
        print("Starting WAREHOUSE layer...")
        print("WAREHOUSE layer completed!")

    final_task = PythonOperator(
        task_id='load_warehouse_layer',
        python_callable=run_final_layer
    )

    # ─────────────────────────────────
    # TASK 4 - INCREMENTAL LOAD
    # ─────────────────────────────────
    def run_incremental():
        print("Starting INCREMENTAL load...")
        print("INCREMENTAL load completed!")

    incremental_task = PythonOperator(
        task_id='incremental_load',
        python_callable=run_incremental
    )

    # ─────────────────────────────────
    # TASK ORDER (dependencies)
    # ─────────────────────────────────
    raw_task >> stg_task >> final_task >> incremental_task