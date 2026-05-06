CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS raw.raw_nyc_payroll (
    fiscal_year TEXT NULL,
    agency_name TEXT NULL,
    last_name TEXT NULL,
    first_name TEXT NULL,
    mid_init TEXT NULL,
    agency_start_date TEXT NULL,
    work_location_borough TEXT NULL,
    title_description TEXT NULL,
    leave_status TEXT NULL,
    base_salary TEXT NULL,
    pay_basis TEXT NULL,
    regular_hours TEXT NULL,
    regular_gross_paid TEXT NULL,
    ot_hours TEXT NULL,
    total_ot_paid TEXT NULL,
    total_other_pay TEXT NULL,
    raw_loaded_at TIMESTAMP NOT NULL DEFAULT NOW()
);