/*
=======================================================================================
Creare il Database e gli Schemi
=======================================================================================
Scopo dello script:
    Questo script crea un nuovo database denominato 'data_warehouse' dopo aver 
    verificato se esiste già.
    Se il database esiste, viene eliminato e ricreato. Inoltre, lo script imposta
    tre schemi all'interno del database: 'bronze', 'silver', 'gold'.

ATTENZAIONE:
    L'esecuzione di questo script cancellerà l'intero dataset 'data_warehouse',
    se esiste.
    Tutti i dati nel database saranno eliminati in modo permanente. Procedere
    con cautela e assicurarsi di disporre di backup adeguati prima di eseguire
    questo script
*/


-- Utilizzare il master database
USE master;
GO

-- Elimina e recrea se esiste il database 'data_warehouse'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'data_warehouse')
BEGIN
    -- Disconnetti tutti gli utenti e rollback delle transazioni attive per ottener l'accesso esclusivo
    ALTER DATABASE data_warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    -- Elimina il database
    DROP DATABASE data_warehouse;
END;
GO
-- Crea il database
CREATE DATABASE data_warehouse;
GO


-- Utilizza il database
USE data_warehouse;
GO

-- Crea gli schemi
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
