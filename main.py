import pyodbc
import os
from dotenv import load_dotenv

# carica variabile d'ambiente da .env file
load_dotenv()

# Ottiene i dettagli della connessione dalle variabili d'ambiente
server = os.getenv("SQL_SERVER")
database = os.getenv("SQL_DATABASE")

# Stringa di connessione per l'autenticazione di SQL Server
connection_string = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes"

try:
    #stabilire la connessione
    conn = pyodbc.connect(connection_string)
    cursor = conn.cursor()

    cursor.execute("SELECT @@VERSION")
    row = cursor.fetchone()
    print(f"Connected! SQL Server version: {row[0]}")

    cursor.close()
    conn.close()
except pyodbc.Error as e:
    print(f"Errore durante la connessione a SQL Server: {e}") 
