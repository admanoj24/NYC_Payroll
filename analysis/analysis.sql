-- ============================================================
-- ANALYSIS QUERIES - NYC PAYROLL
-- ============================================================

-- ============================================================
-- SECTION 1: KPIs AND METRICS
-- ============================================================

-- 1. TOTAL EMPLOYEES
SELECT COUNT(DISTINCT employee_id) AS total_employees
FROM final.fact_payroll;

-- 2. TOTAL PAYROLL COST
SELECT
    ROUND(SUM(regular_gross_paid), 2) AS total_regular_pay,
    ROUND(SUM(total_ot_paid), 2) AS total_overtime_pay,
    ROUND(SUM(total_other_pay), 2) AS total_other_pay,
    ROUND(SUM(regular_gross_paid + total_ot_paid + total_other_pay), 2) AS total_payroll_cost
FROM final.fact_payroll;

-- 3. AVERAGE SALARY
SELECT
    ROUND(AVG(base_salary), 2) AS avg_base_salary,
    ROUND(AVG(regular_gross_paid), 2) AS avg_gross_paid,
    ROUND(AVG(total_ot_paid), 2) AS avg_ot_paid
FROM final.fact_payroll;

-- 4. TOTAL OVERTIME HOURS
SELECT
    ROUND(SUM(ot_hours), 2) AS total_ot_hours,
    ROUND(AVG(ot_hours), 2) AS avg_ot_hours_per_employee
FROM final.fact_payroll;

-- 5. HIGHEST PAID EMPLOYEE
SELECT
    e.first_name,
    e.last_name,
    a.agency_name,
    t.title_description,
    ROUND(f.base_salary, 2) AS base_salary,
    ROUND(f.regular_gross_paid, 2) AS gross_paid
FROM final.fact_payroll f
JOIN final.dim_employee e ON e.employee_id = f.employee_id
JOIN final.dim_agency a ON a.agency_id = f.agency_id
JOIN final.dim_title t ON t.title_id = f.title_id
ORDER BY f.base_salary DESC
LIMIT 5;

-- ============================================================
-- SECTION 2: TREND ANALYSIS
-- ============================================================

-- 6. SALARY TREND BY FISCAL YEAR
SELECT
    d.fiscal_year,
    COUNT(DISTINCT f.employee_id) AS total_employees,
    ROUND(AVG(f.base_salary), 2) AS avg_base_salary,
    ROUND(SUM(f.regular_gross_paid), 2) AS total_gross_paid
FROM final.fact_payroll f
JOIN final.dim_date d ON d.date_id = f.date_id
GROUP BY d.fiscal_year
ORDER BY d.fiscal_year;

-- 7. OVERTIME TREND BY YEAR
SELECT
    d.fiscal_year,
    ROUND(SUM(f.ot_hours), 2) AS total_ot_hours,
    ROUND(SUM(f.total_ot_paid), 2) AS total_ot_paid,
    ROUND(AVG(f.ot_hours), 2) AS avg_ot_hours
FROM final.fact_payroll f
JOIN final.dim_date d ON d.date_id = f.date_id
GROUP BY d.fiscal_year
ORDER BY d.fiscal_year;

-- 8. EMPLOYEE COUNT TREND BY YEAR
SELECT
    d.fiscal_year,
    COUNT(*) AS total_records,
    COUNT(DISTINCT f.employee_id) AS unique_employees
FROM final.fact_payroll f
JOIN final.dim_date d ON d.date_id = f.date_id
GROUP BY d.fiscal_year
ORDER BY d.fiscal_year;

-- ============================================================
-- SECTION 3: DIMENSIONAL ANALYSIS
-- ============================================================

-- 9. TOP 10 AGENCIES BY TOTAL PAYROLL COST
SELECT
    a.agency_name,
    COUNT(DISTINCT f.employee_id) AS total_employees,
    ROUND(AVG(f.base_salary), 2) AS avg_salary,
    ROUND(SUM(f.regular_gross_paid), 2) AS total_gross_paid
FROM final.fact_payroll f
JOIN final.dim_agency a ON a.agency_id = f.agency_id
GROUP BY a.agency_name
ORDER BY total_gross_paid DESC
LIMIT 10;

-- 10. SALARY BY BOROUGH
SELECT
    l.work_location_borough,
    COUNT(DISTINCT f.employee_id) AS total_employees,
    ROUND(AVG(f.base_salary), 2) AS avg_salary,
    ROUND(SUM(f.regular_gross_paid), 2) AS total_gross_paid
FROM final.fact_payroll f
JOIN final.dim_location l ON l.location_id = f.location_id
GROUP BY l.work_location_borough
ORDER BY avg_salary DESC;

-- 11. TOP 10 HIGHEST PAYING JOB TITLES
SELECT
    t.title_description,
    COUNT(DISTINCT f.employee_id) AS total_employees,
    ROUND(AVG(f.base_salary), 2) AS avg_salary,
    ROUND(MAX(f.base_salary), 2) AS max_salary
FROM final.fact_payroll f
JOIN final.dim_title t ON t.title_id = f.title_id
GROUP BY t.title_description
ORDER BY avg_salary DESC
LIMIT 10;

-- 12. SALARY BY PAY BASIS
SELECT
    p.pay_basis,
    COUNT(DISTINCT f.employee_id) AS total_employees,
    ROUND(AVG(f.base_salary), 2) AS avg_salary,
    ROUND(SUM(f.regular_gross_paid), 2) AS total_gross_paid
FROM final.fact_payroll f
JOIN final.dim_pay_basis p ON p.pay_basis_id = f.pay_basis_id
GROUP BY p.pay_basis
ORDER BY total_employees DESC;

-- 13. LEAVE STATUS BREAKDOWN
SELECT
    e.leave_status,
    COUNT(DISTINCT f.employee_id) AS total_employees,
    ROUND(AVG(f.base_salary), 2) AS avg_salary
FROM final.fact_payroll f
JOIN final.dim_employee e ON e.employee_id = f.employee_id
GROUP BY e.leave_status
ORDER BY total_employees DESC;

-- 14. TOP 5 OVERTIME AGENCIES
SELECT
    a.agency_name,
    ROUND(SUM(f.ot_hours), 2) AS total_ot_hours,
    ROUND(SUM(f.total_ot_paid), 2) AS total_ot_paid,
    ROUND(AVG(f.ot_hours), 2) AS avg_ot_hours
FROM final.fact_payroll f
JOIN final.dim_agency a ON a.agency_id = f.agency_id
GROUP BY a.agency_name
ORDER BY total_ot_hours DESC
LIMIT 5;

-- 15. SALARY COMPARISON BY AGENCY AND YEAR
SELECT
    d.fiscal_year,
    a.agency_name,
    ROUND(AVG(f.base_salary), 2) AS avg_salary
FROM final.fact_payroll f
JOIN final.dim_date d ON d.date_id = f.date_id
JOIN final.dim_agency a ON a.agency_id = f.agency_id
GROUP BY d.fiscal_year, a.agency_name
ORDER BY d.fiscal_year, avg_salary DESC
LIMIT 20;