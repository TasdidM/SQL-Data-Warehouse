/*
=========================================================================
DDL Script: Crea le tabelle del livello Bronze
=========================================================================
Scopo dello Script:
    Questo script crea le tabelle nello schema 'bronze', eliminando 
    quelle già esistenti.
    Eseguire questo script DDL per ridefinire la struttura delle tabelle
    'bronze'.
*/


-- Elimina la tabella se esiste già
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO
-- Crea la tabella per il file 'cust_info.csv' dal sistema CRM
CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO

-- Elimina la tabella se esiste già
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO
-- Crea la tabella per il file 'prd_info.csv' dal sistema CRM
CREATE TABLE bronze.crm_prd_info (
    prd_id          INT,
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      Date
);
GO

-- Elimina la tabella se esiste già
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO
-- Crea la tabella per il file 'sales_details.csv' dal sistema CRM
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO



-- Elimina la tabella se esiste già
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO
-- Crea la tabella per il file 'CUST_AZ12.csv' dal sistema ERP
CREATE TABLE bronze.erp_cust_az12 (
    cid     NVARCHAR(50),
    bdate   DATE,
    gen     NVARCHAR(50)
);
GO

-- Elimina la tabella se esiste già
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO
-- Crea la tabella per il file 'erp_LOC_A101.csv' dal sistema ERP
CREATE TABLE bronze.erp_loc_a101 (
    cid     NVARCHAR(50),
    cntry   NVARCHAR(50)
);
GO

-- Elimina la tabella se esiste già
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO
-- Crea la tabella per il file 'PX_CAT_G1V2.csv' dal sistema ERP
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50)
);


