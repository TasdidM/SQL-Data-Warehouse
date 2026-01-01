/*
===========================================================================================
Stored Procedure: Carica il Livello Silver (Bronze -> Silver)
===========================================================================================
Scopo dello Script:
    Questo Stored Procedure esegue il processo ETL (Extract, Transform, Load) per popolare
    le tabelle dello schema 'silver' dallo schema 'bronze'.
    Esegue le seguenti azioni:
        - Troncare la tabella Silver.
        - Inserire i dati trasformati e puliti dalla tabella Bronze alla tabella Silver.

Parametri: 
    Nessuna
     - Questo stored procedure non accetta alcun parametro né restituisce alcun valore.

Esempio dell'utilizzo:
    EXEC silver.load_silver;

===========================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '============================================';
        PRINT 'Caricando Livello Silver';
        PRINT '============================================';

        PRINT '--------------------------------------------';
        PRINT 'Caricando Tabelle CRM';
        PRINT '--------------------------------------------';


        -- Carica silver.crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Troncando la tabella: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Caricando la tabella: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id, 
            cst_key, 
            cst_firstname, 
            cst_lastname, 
            cst_marital_status,
            cst_gndr, 
            cst_create_date
        )
        SELECT  
            cst_id,
            cst_key,
            -- Elimina gli spazi indesiderati
            TRIM(cst_firstname) AS cst_firstname,
            -- Elimina gli spazi indesiderati
            TRIM(cst_lastname) AS cst_lastname,
            -- valori chiari e significativi piuttosto che abbreviati
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'Unknown'
            END cst_marital_status,
            -- valori chiari e significativi piuttosto che abbreviati
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'Unknown'
            END cst_gndr,
            cst_create_date
        FROM (SELECT *, -- rimuovi duplicati
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL) t
        -- Selezionare il record più recente per cliente
        WHERE flag_last = 1;
        SET @end_time = GETDATE();
        PRINT '>> Durata del carico: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' secondi';
        PRINT '>> ------------------------------------';


        -- Carica silver.crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Troncando la tabella: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Caricando la tabella: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info(
            prd_id, 
            cat_id, 
            prd_key, 
            prd_nm, 
            prd_cost,
            prd_line, 
            prd_start_dt, 
            prd_end_dt
        )
        SELECT  
            prd_id,
            -- seleziona i primi 5 caratteri e modifica il delimitatore
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            -- Seleziona i caratteri dopo i primi 5
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            -- Se nell'azienda il valore NULL di prd_cost significa 0
            ISNULL(prd_cost, 0) AS prd_cost,
            -- Mappare i codici della linea di prodotti ai valori descrittivi
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'Unknown'
            END AS prd_line,
            prd_start_dt,
            -- ricrea il prd_end_dt scegliando il giorno precedente del prd_start_dt del record successivo
            DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Durata del carico: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' secondi';
        PRINT '>> ------------------------------------';



        -- Carica silver.crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> Troncando la tabella: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Caricando la tabella: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num, 
            sls_prd_key, 
            sls_cust_id, 
            sls_order_dt, 
            sls_ship_dt, 
            sls_due_dt, 
            sls_sales, 
            sls_quantity, 
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            -- Modifiche alla data da numero intero della colonna 'sls_order_dt'
            CASE 
                WHEN sls_order_dt = 0 
                OR LEN(sls_order_dt) != 8 
                    THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,
            -- Modifiche alla data da numero intero della colonna 'sls_ship_dt'
            CASE 
                WHEN sls_ship_dt = 0 
                OR LEN(sls_ship_dt) != 8 
                    THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,
            -- Modifiche alla data da numero intero della colonna 'sls_due_dt'
            CASE 
                WHEN sls_due_dt = 0 
                OR LEN(sls_due_dt) != 8 
                    THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
            -- Regole:
            -- Se il Sales è negativo, zero o null, lo deriviamo utilizzando Quantity e Price.
            -- Se il Price è zero o null, lo calculiam utilizzando Sales e Quantity,
            -- Se il Price è negativo, convertiamo al valore positivo
            CASE 
                WHEN sls_sales IS NULL
                OR sls_sales <= 0
                OR sls_sales != sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE 
                WHEN sls_price IS NULL
                OR sls_price <= 0
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Durata del carico: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' secondi';



        PRINT '--------------------------------------------';
        PRINT 'Caricando Tabelle CRM';
        PRINT '--------------------------------------------';

        -- Carica silver.erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '>> Troncando la tabella: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Caricando la tabella: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            -- Rimuove il prefisso "NAS" se presente
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, len(cid))
                ELSE cid
            END AS cid,
            -- impostare le date di nascita future su NULL
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,
            -- Normalizzare i valori di genere e gestire i casi sconosciuti
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'Unknown'
            END AS gen
        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Durata del carico: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' secondi';
        PRINT '>> ------------------------------------';
            


        -- Carica silver.erp_loc_a101
        SET @start_time = GETDATE();
        PRINT '>> Troncando la tabella: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Caricando la tabella: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,
            -- Normalizza e gestisci i codici paese mancanti o vuoti
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'Unknown'
                ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Durata del carico: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' secondi';
        PRINT '>> ------------------------------------';



        -- Carica silver.erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '>> Troncando la tabella: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Caricando la tabella: silver.erp_loc_a101';
        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT '>> Durata del carico: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' secondi';

        SET @batch_end_time = GETDATE();
        PRINT '============================================';
        PRINT 'Il Caricamento del Livello Silver è Completato';
        PRINT ' - Durata Totale del Carico: '  + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' secondi'
        PRINT '============================================';
    END TRY
    BEGIN CATCH
        
        -- Inserisce l'errore nella tabella del registro degli errori
        INSERT INTO dbo.error_log (
            error_number, error_severity, error_state,
            error_procedure, error_line, error_message
        )
        VALUES (
            ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(),
            ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE()
        );


        PRINT '==================================================';
        PRINT 'Si è verificato un errore durante il caricamento' 
            + CHAR(13) + CHAR(10)
            + 'del livello Bronze';
        PRINT 'ERROR MESSAGE:' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER :' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT '==================================================';


        THROW;
    END CATCH
END








