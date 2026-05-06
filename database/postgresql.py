import psycopg2

def get_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="nyc_payroll",
        user="postgres",
        password="admin@54321",  
    )
    return conn