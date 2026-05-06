import csv
from src.sql_utils import read_sql_files
from datetime import datetime
from psycopg2.extras import execute_values

# ─────────────────────────────────────────
# INITIALIZE BATCH TRACKER TABLE
# creates batch_runs table if not exists
# ─────────────────────────────────────────
def initialize_batch_tracker(cur):
    batch_ddl_query = read_sql_files(
        "sql/ddl/04_create_batch_tracker.sql"
    )
    cur.execute(batch_ddl_query)

# ─────────────────────────────────────────
# START BATCH
# records when pipeline starts running
# returns batch_id for tracking
# ─────────────────────────────────────────
def start_batch(cur):
    cur.execute("""
        INSERT INTO batch_runs (status, start_time)
        VALUES ('running', %s)
        RETURNING batch_id;
    """, (datetime.now(),))
    batch_id = cur.fetchone()[0]
    return batch_id

# ─────────────────────────────────────────
# END BATCH
# updates batch status when pipeline ends
# status = 'success' or 'failed'
# ─────────────────────────────────────────
def end_batch(cur, batch_id, status, error=None):
    cur.execute("""
        UPDATE batch_runs
        SET status = %s,
            end_time = %s,
            error_message = %s
        WHERE batch_id = %s;
    """, (status, datetime.now(), error, batch_id))

# ─────────────────────────────────────────
# LOAD INCREMENTAL RAW
# reads new CSV file
# inserts only NEW records into raw table
# skips existing records (ON CONFLICT)
# ─────────────────────────────────────────
def load_incremental_raw(cur, file_path):
    print("Loading incremental data...")
    with open(file_path, "r") as file:
        rows = list(csv.DictReader(file))

    # prepare data tuples from CSV rows
    data = [
        (
            row["Fiscal Year"],
            row["Agency Name"],
            row["Last Name"],
            row["First Name"],
            row["Mid Init"],
            row["Agency Start Date"],
            row["Work Location Borough"],
            row["Title Description"],
            row["Leave Status as of June 30"],
            row["Base Salary"],
            row["Pay Basis"],
            row["Regular Hours"],
            row["Regular Gross Paid"],
            row["OT Hours"],
            row["Total OT Paid"],
            row["Total Other Pay"]
        )
        for row in rows
    ]

    # insert all rows at once
    # ON CONFLICT DO NOTHING = skip duplicates!
    query = """
        INSERT INTO raw.raw_nyc_payroll (
            fiscal_year, agency_name, last_name,
            first_name, mid_init, agency_start_date,
            work_location_borough, title_description,
            leave_status, base_salary, pay_basis,
            regular_hours, regular_gross_paid,
            ot_hours, total_ot_paid, total_other_pay
        )
        VALUES %s
        ON CONFLICT DO NOTHING;
    """
    execute_values(cur, query, data)
    print(f"Incremental raw loaded! ({len(rows)} rows processed)")

# ─────────────────────────────────────────
# LOAD INCREMENTAL STAGING
# loads only NEW fiscal year (2018) data
# from raw into staging with transformations
# ─────────────────────────────────────────
def load_incremental_stg(cur):
    print("Loading incremental staging...")
    cur.execute("""
        INSERT INTO stg.stg_nyc_payroll
        SELECT DISTINCT
            TRIM(fiscal_year)::INT,
            TRIM(agency_name),
            COALESCE(TRIM(last_name), 'UNKNOWN'),
            COALESCE(TRIM(first_name), 'UNKNOWN'),
            TRIM(mid_init),
            TRIM(agency_start_date)::DATE,
            COALESCE(TRIM(work_location_borough), 'UNKNOWN'),
            COALESCE(TRIM(title_description), 'UNKNOWN'),
            TRIM(leave_status),
            REPLACE(TRIM(base_salary), '$', '')::NUMERIC,
            TRIM(pay_basis),
            regular_hours::NUMERIC,
            REPLACE(TRIM(regular_gross_paid), '$', '')::NUMERIC,
            ot_hours::NUMERIC,
            REPLACE(TRIM(total_ot_paid), '$', '')::NUMERIC,
            REPLACE(TRIM(total_other_pay), '$', '')::NUMERIC
        FROM raw.raw_nyc_payroll
        WHERE TRIM(fiscal_year)::INT = 2018;
    """)
    print("Incremental staging loaded!")

# ─────────────────────────────────────────
# LOAD INCREMENTAL FINAL
# loads new dimension records first
# then loads new fact records last
# only inserts records that don't exist!
# ─────────────────────────────────────────
def load_incremental_final(cur):
    print("Loading incremental final layer...")

    # ── 1. load new agencies ──
    cur.execute("""
        INSERT INTO final.dim_agency (agency_name)
        SELECT DISTINCT TRIM(agency_name)
        FROM stg.stg_nyc_payroll
        WHERE fiscal_year = 2018
        AND agency_name IS NOT NULL
        AND TRIM(agency_name) NOT IN (
            SELECT agency_name FROM final.dim_agency
        );
    """)
    print("dim_agency done!")

    # ── 2. load new job titles ──
    cur.execute("""
        INSERT INTO final.dim_title (title_description)
        SELECT DISTINCT TRIM(title_description)
        FROM stg.stg_nyc_payroll
        WHERE fiscal_year = 2018
        AND title_description IS NOT NULL
        AND TRIM(title_description) NOT IN (
            SELECT title_description FROM final.dim_title
        );
    """)
    print("dim_title done!")

    # ── 3. load new locations ──
    cur.execute("""
        INSERT INTO final.dim_location (work_location_borough)
        SELECT DISTINCT TRIM(work_location_borough)
        FROM stg.stg_nyc_payroll
        WHERE fiscal_year = 2018
        AND work_location_borough IS NOT NULL
        AND TRIM(work_location_borough) NOT IN (
            SELECT work_location_borough
            FROM final.dim_location
        );
    """)
    print("dim_location done!")

    # ── 4. load new pay basis ──
    cur.execute("""
        INSERT INTO final.dim_pay_basis (pay_basis)
        SELECT DISTINCT TRIM(pay_basis)
        FROM stg.stg_nyc_payroll
        WHERE fiscal_year = 2018
        AND pay_basis IS NOT NULL
        AND TRIM(pay_basis) NOT IN (
            SELECT pay_basis FROM final.dim_pay_basis
        );
    """)
    print("dim_pay_basis done!")

    # ── 5. load new fiscal year ──
    cur.execute("""
        INSERT INTO final.dim_date (fiscal_year)
        SELECT DISTINCT fiscal_year
        FROM stg.stg_nyc_payroll
        WHERE fiscal_year = 2018
        AND fiscal_year NOT IN (
            SELECT fiscal_year FROM final.dim_date
        );
    """)
    print("dim_date done!")

    # ── 6. load new employees ──
    cur.execute("""
        INSERT INTO final.dim_employee (
            first_name, last_name, mid_init,
            agency_start_date, leave_status
        )
        SELECT DISTINCT
            first_name, last_name, mid_init,
            agency_start_date, leave_status
        FROM stg.stg_nyc_payroll
        WHERE fiscal_year = 2018
        AND first_name IS NOT NULL
        AND last_name IS NOT NULL
        AND (first_name, last_name, agency_start_date)
        NOT IN (
            SELECT first_name, last_name, agency_start_date
            FROM final.dim_employee
        );
    """)
    print("dim_employee done!")

    # ── 7. load new fact records (LAST!) ──
    cur.execute("""
        INSERT INTO final.fact_payroll (
            employee_id, agency_id, title_id,
            location_id, pay_basis_id, date_id,
            base_salary, regular_hours,
            regular_gross_paid, ot_hours,
            total_ot_paid, total_other_pay
        )
        SELECT
            e.employee_id,
            a.agency_id,
            t.title_id,
            l.location_id,
            p.pay_basis_id,
            d.date_id,
            s.base_salary,
            s.regular_hours,
            s.regular_gross_paid,
            s.ot_hours,
            s.total_ot_paid,
            s.total_other_pay
        FROM stg.stg_nyc_payroll s
        JOIN final.dim_employee e
            ON e.first_name = s.first_name
            AND e.last_name = s.last_name
            AND e.agency_start_date = s.agency_start_date
        JOIN final.dim_agency a
            ON a.agency_name = s.agency_name
        JOIN final.dim_title t
            ON t.title_description = s.title_description
        JOIN final.dim_location l
            ON l.work_location_borough = s.work_location_borough
        JOIN final.dim_pay_basis p
            ON p.pay_basis = s.pay_basis
        JOIN final.dim_date d
            ON d.fiscal_year = s.fiscal_year
        WHERE s.fiscal_year = 2018
        AND s.base_salary IS NOT NULL;
    """)
    print("fact_payroll done!")
    print("Incremental final layer loaded!")