INSERT INTO final.dim_agency (agency_name)
SELECT DISTINCT TRIM(agency_name)
FROM stg.stg_nyc_payroll
WHERE agency_name IS NOT NULL;

INSERT INTO final.dim_title (title_description)
SELECT DISTINCT TRIM(title_description)
FROM stg.stg_nyc_payroll
WHERE title_description IS NOT NULL;

INSERT INTO final.dim_location (work_location_borough)
SELECT DISTINCT TRIM(work_location_borough)
FROM stg.stg_nyc_payroll
WHERE work_location_borough IS NOT NULL;

INSERT INTO final.dim_pay_basis (pay_basis)
SELECT DISTINCT TRIM(pay_basis)
FROM stg.stg_nyc_payroll
WHERE pay_basis IS NOT NULL;

INSERT INTO final.dim_date (fiscal_year)
SELECT DISTINCT fiscal_year
FROM stg.stg_nyc_payroll
WHERE fiscal_year IS NOT NULL;

INSERT INTO final.dim_employee (
    first_name, last_name, mid_init,
    agency_start_date, leave_status
)
SELECT DISTINCT
    first_name, last_name, mid_init,
    agency_start_date, leave_status
FROM stg.stg_nyc_payroll
WHERE first_name IS NOT NULL
AND last_name IS NOT NULL;

INSERT INTO final.fact_payroll (
    employee_id, agency_id, title_id,
    location_id, pay_basis_id, date_id,
    base_salary, regular_hours, regular_gross_paid,
    ot_hours, total_ot_paid, total_other_pay
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
WHERE s.base_salary IS NOT NULL;