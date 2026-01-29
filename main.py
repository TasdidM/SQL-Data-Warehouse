import pyodbc
import os
from dotenv import load_dotenv

# carica variabile d'ambiente da .env file
load_dotenv()

<<<<<<< HEAD
<<<<<<< HEAD
params = {
    'crm_cust_info': os.path.abspath("datasets\source_crm\cust_info.csv"),
    'crm_prd_info': os.path.abspath('datasets\source_crm\prd_info.csv'),
    'crm_sales_details': os.path.abspath('datasets\source_crm\sales_details.csv'),
    'erp_cust_az12': os.path.abspath("datasets\source_erp\CUST_AZ12.csv"),
    'erp_loc_a101': os.path.abspath('datasets\source_erp\LOC_A101.csv'),
    'erp_px_cat_g1v2': os.path.abspath('datasets\source_erp\PX_CAT_G1V2.csv')
}

def execute_sql_file(cursor, filepath, params = None):
    """Esegue script SQL da file"""
    with open(filepath, "r") as file:
        sql_script = file.read()
    
    # parametri per placeholders nello script di SQL
    if params:
        for key, value in params.items():
            sql_script = sql_script.replace(f"{{{key}}}", value)

    # per rimuovere l'istruzione GO
    commands = sql_script.split("GO")
    for command in commands: 
        command = command.strip()
        if command:
            cursor.execute(command)

    print(f"Executed {filepath}")

def exec_SP(cursor, SP_name):
    """Esegue lo script di Stored Procedure"""
    cursor.execute(f'EXEC {SP_name}')
    for msg in cursor.messages:
        clean_msg = msg[1].split(']')[-1].strip()
        print(f"SQL: {clean_msg}")

def main():
    try:
        # Ottiene i dettagli della connessione dalle variabili d'ambiente
        server = os.getenv("SQL_SERVER")
        database = os.getenv("SQL_DATABASE")

        # Stringa di connessione per l'autenticazione di SQL Server
        connection_string = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes"
        # stabilire la connessione
        with pyodbc.connect(connection_string) as conn:
            with conn.cursor() as cursor:
                conn.autocommit = True
                # inizializzazione del database
                execute_sql_file(cursor, 'scripts\init_database.sql')
                # crea tabella di errore
                execute_sql_file(cursor, 'scripts\create_error_log_table.sql')

                # crea il livello Bronze
                execute_sql_file(cursor, 'scripts\Bronze\ddl_bronze.sql')
                execute_sql_file(cursor, 'scripts\Bronze\proc_load_bronze.sql', params = params)
                exec_SP(cursor, 'bronze.load_bronze')

                # crea il livello Silver
                execute_sql_file(cursor, 'scripts\Silver\ddl_silver.sql')
                execute_sql_file(cursor, 'scripts\Silver\proc_load_silver.sql')
                exec_SP(cursor, 'silver.load_silver')

                # controllo di qualita del livello Silver
                execute_sql_file(cursor, 'tests\quality_checks_silver.sql')

                # crea il livello Gold
                execute_sql_file(cursor, 'scripts\Gold\ddl_gold.sql')
                # controllo di qualita del livello Gold
                execute_sql_file(cursor, 'tests\quality_checks_gold.sql')
        
    except pyodbc.Error as e:
        #conn.rollback()
        print(f"Errore durante la connessione a SQL Server: {e}")

if __name__ == "__main__":
    main()
=======
# # Ottiene i dettagli della connessione dalle variabili d'ambiente
# server = os.getenv("SQL_SERVER")
# database = os.getenv("SQL_DATABASE")
=======
# Ottiene i dettagli della connessione dalle variabili d'ambiente
server = os.getenv("SQL_SERVER")
database = os.getenv("SQL_DATABASE")
>>>>>>> 87353e3dd97376bd66b0cbc2b511c06a7c9e7b7f

# Stringa di connessione per l'autenticazione di SQL Server
connection_string = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes"

try:
    #stabilire la connessione
    conn = pyodbc.connect(connection_string)
    cursor = conn.cursor()

    cursor.execute("SELECT @@VERSION")
    row = cursor.fetchone()
    print(f"Connected! SQL Server version: {row[0]}")

<<<<<<< HEAD
#     cursor.close()
#     conn.close()
# except pyodbc.Error as e:
#     print(f"Errore durante la connessione a SQL Server: {e}") 
>>>>>>> 6bbb9d7af4967eb23accdb59bcd9a8cebd0e0b75
=======
    cursor.close()
    conn.close()
except pyodbc.Error as e:
    print(f"Errore durante la connessione a SQL Server: {e}") 
>>>>>>> 87353e3dd97376bd66b0cbc2b511c06a7c9e7b7f
