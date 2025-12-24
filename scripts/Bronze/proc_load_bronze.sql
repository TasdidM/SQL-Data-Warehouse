-- Crea la procedura archiviata
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        
        SET @batch_start_time = GETDATE();
        PRINT '==================================================';
        PRINT 'Caricamento del Bronze Layer';
        PRINT '==================================================';

        PRINT '--------------------------------------------------';
        PRINT 'Caricamento Tabelli CRM';
        PRINT '--------------------------------------------------';


        SET @start_Time = GETDATE();
        -- Elimina tutti i dati nella tabella di crm_cust_info
        PRINT '>> Trancating la Tabella: bronze.crm_cust_info'
        TRUNCATE TABLE bronze.crm_cust_info;
        -- Caricamento pieno da file 'cust_info.csv'
        PRINT '>> Inserimento di Dati in: bronze.crm_cust_info'
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\Dio Brando\Desktop\Projects\data warehouse project\datasets\source_crm\cust_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Durata del caricamento della tabella: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-----------';


        SET @start_Time = GETDATE();
        -- Elimina tutti i dati nella tabella di crm_prd_info
        PRINT '>> Trancating la Tabella: bronze.crm_prd_info'
        TRUNCATE TABLE bronze.crm_prd_info;
        -- Caricamento pieno da file 'prd_info.csv'
        PRINT '>> Inserimento di Dati in: bronze.crm_prd_info'
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\Dio Brando\Desktop\Projects\data warehouse project\datasets\source_crm\prd_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Durata del caricamento della tabella: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-----------';


        SET @start_Time = GETDATE();
        -- Elimina tutti i dati nella tabella di crm_sales_details
        PRINT '>> Trancating la Tabella: bronze.crm_sales_details'
        TRUNCATE TABLE bronze.crm_sales_details;
        -- Caricamento pieno da file 'sales_details.csv'
        PRINT '>> Inserimento di Dati in: bronze.crm_sales_details'
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\Dio Brando\Desktop\Projects\data warehouse project\datasets\source_crm\sales_details.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '-----------';
        PRINT '>> Durata del caricamento della tabella: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        PRINT '--------------------------------------------------';
        PRINT 'Caricamento Tabelli ERP';
        PRINT '--------------------------------------------------';


        SET @start_Time = GETDATE();
        -- Elimina tutti i dati nella tabella di erp_cust_az12
        PRINT '>> Trancating la Tabella: bronze.erp_cust_az12'
        TRUNCATE TABLE bronze.erp_cust_az12;
        -- Caricamento pieno da file 'CUST_AZ12.csv'
        PRINT '>> Inserimento di Dati in: bronze.erp_cust_az12'
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\Dio Brando\Desktop\Projects\data warehouse project\datasets\source_erp\CUST_AZ12.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Durata del caricamento della tabella: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-----------';


        SET @start_Time = GETDATE();
        -- Elimina tutti i dati nella tabella di erp_loc_a101
        PRINT '>> Trancating la Tabella: bronze.erp_loc_a101'
        TRUNCATE TABLE bronze.erp_loc_a101;
        -- Caricamento pieno da file 'LOC_A101.csv'
        PRINT '>> Inserimento di Dati in: bronze.erp_loc_a101'
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\Dio Brando\Desktop\Projects\data warehouse project\datasets\source_erp\LOC_A101.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Durata del caricamento della tabella: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-----------';

        
        SET @start_Time = GETDATE();
        -- Elimina tutti i dati nella tabella di erp_px_cat_g1v2
        PRINT '>> Trancating la Tabella: bronze.erp_px_cat_g1v2'
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        -- Caricamento pieno da file 'PX_CAT_G1V2.csv'
        PRINT '>> Inserimento di Dati in: bronze.erp_px_cat_g1v2'
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\Dio Brando\Desktop\Projects\data warehouse project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>> Durata del caricamento della tabella: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '-----------';
        SET @batch_end_time = GETDATE();
        PRINT '==================================================';
        PRINT 'Caricamento del Bronze Layer con successo';
        PRINT ' - Durata total del carico: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==================================================';

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
END;
