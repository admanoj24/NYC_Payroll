CREATE SCHEMA IF NOT EXISTS stg;

CREATE TABLE IF NOT EXISTS stg.stg_nyc_payroll (
    fiscal_year INT NULL,
    agency_name VARCHAR(100) NULL,
    last_name VARCHAR(50) NULL,
    first_name VARCHAR(50) NULL,
    mid_init VARCHAR(5) NULL,
    agency_start_date DATE NULL,
    work_location_borough VARCHAR(50) NULL,
    title_description VARCHAR(100) NULL,
    leave_status VARCHAR(50) NULL,
    base_salary NUMERIC(14,2) NULL,
    pay_basis VARCHAR(50) NULL,
    regular_hours NUMERIC(10,2) NULL,
    regular_gross_paid NUMERIC(14,2) NULL,
    ot_hours NUMERIC(10,2) NULL,
    total_ot_paid NUMERIC(14,2) NULL,
    total_other_pay NUMERIC(14,2) NULL
);