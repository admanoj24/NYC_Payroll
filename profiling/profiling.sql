
-- ============================================================
-- DATA PROFILING REPORT - NYC PAYROLL
-- ============================================================

-- 1. TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows
FROM raw.raw_nyc_payroll;

-- 2. CHECK DATA TYPES
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'raw_nyc_payroll'
AND table_schema = 'raw'
ORDER BY ordinal_position;

-- 3. NULL VALUES PER COLUMN
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(fiscal_year) AS fiscal_year_nulls,
    COUNT(*) - COUNT(agency_name) AS agency_name_nulls,
    COUNT(*) - COUNT(last_name) AS last_name_nulls,
    COUNT(*) - COUNT(first_name) AS first_name_nulls,
    COUNT(*) - COUNT(mid_init) AS mid_init_nulls,
    COUNT(*) - COUNT(agency_start_date) AS agency_start_date_nulls,
    COUNT(*) - COUNT(work_location_borough) AS work_location_nulls,
    COUNT(*) - COUNT(title_description) AS title_description_nulls,
    COUNT(*) - COUNT(leave_status) AS leave_status_nulls,
    COUNT(*) - COUNT(base_salary) AS base_salary_nulls,
    COUNT(*) - COUNT(pay_basis) AS pay_basis_nulls,
    COUNT(*) - COUNT(regular_hours) AS regular_hours_nulls,
    COUNT(*) - COUNT(regular_gross_paid) AS regular_gross_paid_nulls,
    COUNT(*) - COUNT(ot_hours) AS ot_hours_nulls,
    COUNT(*) - COUNT(total_ot_paid) AS total_ot_paid_nulls,
    COUNT(*) - COUNT(total_other_pay) AS total_other_pay_nulls
FROM raw.raw_nyc_payroll;

-- 4. DUPLICATE RECORDS
SELECT
    fiscal_year, agency_name, last_name,
    first_name, agency_start_date,
    COUNT(*) AS duplicate_count
FROM raw.raw_nyc_payroll
GROUP BY
    fiscal_year, agency_name, last_name,
    first_name, agency_start_date
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- 5. FISCAL YEAR RANGE
SELECT
    MIN(fiscal_year) AS from_year,
    MAX(fiscal_year) AS to_year,
    COUNT(DISTINCT fiscal_year) AS total_years
FROM raw.raw_nyc_payroll;

-- 6. UNIQUE VALUES PER COLUMN
SELECT
    COUNT(DISTINCT fiscal_year) AS unique_fiscal_years,
    COUNT(DISTINCT agency_name) AS unique_agencies,
    COUNT(DISTINCT work_location_borough) AS unique_boroughs,
    COUNT(DISTINCT title_description) AS unique_titles,
    COUNT(DISTINCT leave_status) AS unique_leave_status,
    COUNT(DISTINCT pay_basis) AS unique_pay_basis
FROM raw.raw_nyc_payroll;

-- 7. LEAVE STATUS BREAKDOWN
SELECT
    leave_status,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM raw.raw_nyc_payroll
GROUP BY leave_status
ORDER BY total DESC;

-- 8. PAY BASIS BREAKDOWN
-- (checking spaces issue we found!)
SELECT
    pay_basis,
    COUNT(*) AS total
FROM raw.raw_nyc_payroll
GROUP BY pay_basis
ORDER BY total DESC;

-- 9. TOP 5 AGENCIES
SELECT
    TRIM(agency_name) AS agency_name,
    COUNT(*) AS total_employees
FROM raw.raw_nyc_payroll
GROUP BY TRIM(agency_name)
ORDER BY total_employees DESC
LIMIT 5;

-- 10. TOP 5 BOROUGHS
SELECT
    TRIM(work_location_borough) AS borough,
    COUNT(*) AS total
FROM raw.raw_nyc_payroll
WHERE work_location_borough IS NOT NULL
GROUP BY TRIM(work_location_borough)
ORDER BY total DESC
LIMIT 5;

-- 11. SALARY RANGE CHECK
-- (checking $ sign issue!)
SELECT
    MIN(REPLACE(TRIM(base_salary), '$', '')::NUMERIC) AS min_salary,
    MAX(REPLACE(TRIM(base_salary), '$', '')::NUMERIC) AS max_salary,
    ROUND(AVG(REPLACE(TRIM(base_salary), '$', '')::NUMERIC), 2) AS avg_salary
FROM raw.raw_nyc_payroll;

-- 12. NEGATIVE SALARY CHECK
SELECT COUNT(*) AS negative_salary_count
FROM raw.raw_nyc_payroll
WHERE REPLACE(TRIM(regular_gross_paid), '$', '')::NUMERIC < 0;

-- 13. CHECK STAGING CLEANED CORRECTLY
-- compare raw vs stg counts
SELECT 'raw' AS layer, COUNT(*) AS total
FROM raw.raw_nyc_payroll
UNION ALL
SELECT 'staging' AS layer, COUNT(*) AS total
FROM stg.stg_nyc_payroll;

-- 14. CHECK NULLS FIXED IN STAGING
SELECT
    COUNT(*) - COUNT(work_location_borough) AS location_nulls,
    COUNT(*) - COUNT(last_name) AS last_name_nulls,
    COUNT(*) - COUNT(first_name) AS first_name_nulls
FROM stg.stg_nyc_payroll;

-- 15. CHECK PAY BASIS TRIMMED IN STAGING
SELECT
    pay_basis,
    COUNT(*) AS total
FROM stg.stg_nyc_payroll
GROUP BY pay_basis
ORDER BY total DESC;