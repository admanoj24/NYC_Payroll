





-- check all counts
SELECT COUNT(*) FROM raw.raw_nyc_payroll;
SELECT COUNT(*) FROM stg.stg_nyc_payroll;
SELECT COUNT(*) FROM final.final_nyc_payroll;
SELECT COUNT(*) FROM final.dim_employee;
SELECT COUNT(*) FROM final.dim_agency;
SELECT COUNT(*) FROM final.dim_title;
SELECT COUNT(*) FROM final.dim_location;
SELECT COUNT(*) FROM final.dim_pay_basis;
SELECT COUNT(*) FROM final.dim_date;
SELECT COUNT(*) FROM final.fact_payroll;

SELECT 'raw.raw_nyc_payroll' AS table_name, COUNT(*) AS records FROM raw.raw_nyc_payroll
UNION ALL
SELECT 'stg.stg_nyc_payroll', COUNT(*) FROM stg.stg_nyc_payroll
UNION ALL
SELECT 'final.dim_employee', COUNT(*) FROM final.dim_employee
UNION ALL
SELECT 'final.dim_agency', COUNT(*) FROM final.dim_agency
UNION ALL
SELECT 'final.dim_title', COUNT(*) FROM final.dim_title
UNION ALL
SELECT 'final.dim_location', COUNT(*) FROM final.dim_location
UNION ALL
SELECT 'final.dim_pay_basis', COUNT(*) FROM final.dim_pay_basis
UNION ALL
SELECT 'final.dim_date', COUNT(*) FROM final.dim_date
UNION ALL
SELECT 'final.fact_payroll', COUNT(*) FROM final.fact_payroll;

SELECT * FROM batch_runs;
SELECT count(*) FROM batch_runs;

-- delete old failed batches
DELETE FROM batch_runs
WHERE status != 'success';

-- check 2018 data loaded!
SELECT DISTINCT fiscal_year
FROM stg.stg_nyc_payroll
ORDER BY fiscal_year;


-- check batch history
SELECT * FROM batch_runs;




