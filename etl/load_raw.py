import csv
from src.sql_utils import read_sql_files

def initialize_raw_layer(cur):
    raw_ddl_query = read_sql_files("sql/ddl/01_create_raw_tables.sql")
    cur.execute(raw_ddl_query)
    cur.execute("TRUNCATE TABLE raw.raw_nyc_payroll;")

def load_raw_layer(cur):
    raw_dml_query = read_sql_files("sql/dml/01_load_raw_tables.sql")
    print("Loading CSV... please wait (2.1 million rows!)")
    with open("data/raw/Citywide_Payroll_Data__Fiscal_Year_.csv", "r") as file:
        rows = csv.DictReader(file)
        for row in rows:
            cur.execute(raw_dml_query, (
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
            ))
    print("Raw layer loaded!")