CREATE SCHEMA IF NOT EXISTS final;

CREATE TABLE IF NOT EXISTS final.dim_employee (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    mid_init VARCHAR(5),
    agency_start_date DATE,
    leave_status VARCHAR(50)
    -- remove UNIQUE constraint!
);

CREATE TABLE IF NOT EXISTS final.dim_agency (
    agency_id SERIAL PRIMARY KEY,
    agency_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS final.dim_title (
    title_id SERIAL PRIMARY KEY,
    title_description VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS final.dim_location (
    location_id SERIAL PRIMARY KEY,
    work_location_borough VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS final.dim_pay_basis (
    pay_basis_id SERIAL PRIMARY KEY,
    pay_basis VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS final.dim_date (
    date_id SERIAL PRIMARY KEY,
    fiscal_year INT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS final.fact_payroll (
    payroll_id SERIAL PRIMARY KEY,
    employee_id BIGINT REFERENCES final.dim_employee(employee_id),
    agency_id BIGINT REFERENCES final.dim_agency(agency_id),
    title_id BIGINT REFERENCES final.dim_title(title_id),
    location_id BIGINT REFERENCES final.dim_location(location_id),
    pay_basis_id BIGINT REFERENCES final.dim_pay_basis(pay_basis_id),
    date_id BIGINT REFERENCES final.dim_date(date_id),
    base_salary NUMERIC(14,2),
    regular_hours NUMERIC(10,2),
    regular_gross_paid NUMERIC(14,2),
    ot_hours NUMERIC(10,2),
    total_ot_paid NUMERIC(14,2),
    total_other_pay NUMERIC(14,2),
    loaded_at TIMESTAMP DEFAULT NOW()
);