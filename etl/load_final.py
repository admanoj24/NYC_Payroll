from src.sql_utils import read_sql_files

def initialize_final_layer(cur):
    final_ddl_query = read_sql_files("sql/ddl/03_create_final_tables.sql")
    cur.execute(final_ddl_query)
    cur.execute("""
        TRUNCATE TABLE final.fact_payroll CASCADE;
        TRUNCATE TABLE final.dim_employee CASCADE;
        TRUNCATE TABLE final.dim_agency CASCADE;
        TRUNCATE TABLE final.dim_title CASCADE;
        TRUNCATE TABLE final.dim_location CASCADE;
        TRUNCATE TABLE final.dim_pay_basis CASCADE;
        TRUNCATE TABLE final.dim_date CASCADE;
    """)

def load_final_layer(cur):
    final_dml_query = read_sql_files("sql/dml/03_load_final_tables.sql")
    cur.execute(final_dml_query)
    print("Final layer loaded!")