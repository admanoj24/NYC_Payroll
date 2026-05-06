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
FROM raw.raw_nyc_payroll;