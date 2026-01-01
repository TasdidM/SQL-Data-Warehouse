/*
===================================================================================
Quality Checks
===================================================================================
Scopo dello Script:
    Questo script esegue vari controlli di qualità per verificare
    la coerenza, l'accuratezza e la standardizzazione dei dati
    nel livello 'silver'. 
    Include controlli per:
        - Null o duplicate delle Primary Key.
        - Spazi indesiderati nei campi String.
        - Standardizzazione e coerenza dei dati.
        - Intervalli e ordini di date non validi.
        - Coerenza dei dati tra campi correlati.

Note sull'utilizzo:
    - Eseguire questi controlli dopo aver caricato i dati nel livello 'Silver'.
    - Esaminare e risolvere eventualli discrepanze individuate durante i controlli.
*/


-- ===============================================================
-- Controllo 'silver.crm_cust_info'
-- ===============================================================

-- Controlla per NULL o duplicati nel Primary Key
-- Aspettativa: NO risultati
SELECT cst_id, count(*) AS pk_freq
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING count(*) > 1 OR cst_id IS NULL;
-- per trovare la soluzione della problema di simile Primary Key

-- SELECT *
-- FROM bronze.crm_cust_info
-- WHERE cst_id IN (
--     SELECT cst_id
--     FROM bronze.crm_cust_info
--     GROUP BY cst_id
--     HAVING count(*) > 1 AND cst_id IS NOT NULL
-- );

-- si vede che gli ultimi dati aggiornati sono ragionevoli


-- Controlla la presenza di spazi indesiderati
-- Aspettativa: NO resulti
-- customer first name
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
-- customer last name
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
-- customer key
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);
-- customer marital status
SELECT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);
-- customer gender
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);


-- Controllo per coerenza dei dati
-- customer marital status
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;
-- customer gender
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- ===============================================================
-- Controllo 'silver.crm_prd_info'
-- ===============================================================

-- Controllo per NULL or duplicati nel Primary Key
-- Aspettativa: NO resultati
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
-- Verifica l'integrità referenziale: FK in silver.crm_prd_info e PK in silver.erp_px_cat_g1v2

-- SELECT prd_key
-- FROM bronze.crm_prd_info;
-- GO
-- SELECT id
-- FROM bronze.erp_px_cat_g1v2;

-- Solo i primi 5 caratteri sono il PK della tabella bronze.erp_px_cat_g1v2
-- Dobbiamo sostituire il trattino con il carattere di sottolineatura.

-- Tabella di prodotti che non ci siano in categoria di produtti
SELECT *
FROM silver.crm_prd_info
WHERE cat_id NOT IN (
    SELECT DISTINCT id
    FROM silver.erp_px_cat_g1v2
);

-- Tabella di prodotti che non ci siano in ordini di prodotti
SELECT *
FROM silver.crm_prd_info
WHERE prd_key NOT IN (
    SELECT sls_prd_key
    FROM silver.crm_sales_details
);

-- Controlla la presenza di spazi indesiderati
-- Aspetattiva: NO resultati
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Controllo per i valori NULL o numeri negativi
-- Aspettativa: NO resultati
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Controllo per coerenza dei dati
-- linea di prodotti 
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Verifica ordini con date non valide (data di inizio > data di fine)
-- Aspettativa: NO resultati
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Per trovare la soluzione prima controlliamo le date
-- ci concentriamo su un unico prodotto

-- SELECT *
-- FROM bronze.crm_prd_info
-- WHERE prd_key LIKE 'AC-HE-HL-U509-R'

-- Non cambiamo la colonna di prd_start_dt
-- ricreiamo il prd_end_dt scegliando il giorno precedente del prd_start_dt del record successivo


-- ===============================================================
-- Controllo 'silver.crm_sales_details'
-- ===============================================================

-- Controlla la presenza di spazi indesiderati
-- Aspettativa: NO resultati
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Controlla l'integrazione tra le chiavi delle altre tabelle
-- Aspettativa: NO resultati
SELECT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (
    SELECT prd_key
    FROM silver.crm_prd_info
);
-- Aspettativa: NO resultati
SELECT sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id
    FROM silver.crm_cust_info
);

-- Controllo delle date invalide dalla tabella bronze
-- sls_order_dt
-- SELECT 
--     NULLIF(sls_order_dt, 0) sls_order_dt
-- FROM bronze.crm_sales_details
-- WHERE sls_order_dt <= 0 
-- OR LEN(sls_order_dt) != 8;
--OR sls_order_dt > 20500101
--OR sls_order_dt < 19000101

-- sls_ship_dt
-- SELECT 
--     NULLIF(sls_ship_dt, 0) sls_ship_dt
-- FROM bronze.crm_sales_details
-- WHERE sls_ship_dt <= 0 
-- OR LEN(sls_ship_dt) != 8;

-- sls_due_dt
-- SELECT 
--     NULLIF(sls_due_dt, 0) sls_due_dt
-- FROM bronze.crm_sales_details
-- WHERE sls_due_dt <= 0 
-- OR LEN(sls_due_dt) != 8;


-- Controllo ordine con dati non valide (data dell'ordine > date di spedizione/scadenza)
-- Aspettativa: NO risulti
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt;


-- Verifica la corenza dei dati: tra Sales, Quantity e Price
-- >> sales = quantity * price
-- >> I valori non devono essere NULL, zero o negativo.
/*
SELECT 
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0 
OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
--*/
-- Regole:
-- Se il Sales è negativo, zero o null, lo deriviamo utilizzando Quantity e Price.
-- Se il Price è zero o null, lo calculiam utilizzando Sales e Quantity,
-- Se il Price è negativo, convertiamo al valore positivo


-- Controlla la corenza dei dati: tra Sales, Quantity e Price
-- Aspettativa: NO resultati
SELECT 
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0 
OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ===============================================================
-- Controllo 'silver.erp_cust_az12'
-- ===============================================================

-- Controllo degli PK e FK nelle tabelle
-- SELECT * FROM bronze.erp_cust_az12;
-- GO
-- SELECT * FROM silver.crm_cust_info;
-- Nella tabella di erp_cust_az12, la colonna 'cid' contiene caratteri aggunti
-- SELECT *
-- FROM bronze.erp_cust_az12
-- WHERE cid LIKE '%AW00011011'
-- Dobbiamo eliminare 'NAS' per collegare le tabelle


-- controllo degli 'cid' mancanti
-- Aspetattiva: NO resultati
SELECT *
FROM silver.erp_cust_az12
WHERE cid NOT IN (
    SELECT DISTINCT cst_key
    FROM silver.crm_cust_info
);

-- Controllo delle date di nascita non valide
-- Aspettativa: NO resultati
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();


-- Controllo per coerenza dei dati
SELECT DISTINCT gen
FROM silver.erp_cust_az12


-- ===============================================================
-- Controllo 'silver.erp_loc_a101'
-- ===============================================================

-- Verifica se i dati per collegare tabelli sono apposti
-- SELECT * FROM bronze.erp_loc_a101;
-- GO
-- SELECT cst_key FROM silver.crm_cust_info;
-- Dobbiamo redifinire il PK in tabella erp_loc_a101


-- Controllo degli 'cid' mancanti 
-- Aspetattiva: NO resultati
SELECT *
FROM silver.erp_loc_a101
WHERE cid NOT IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);

-- Controllo per coerenza dei dati
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ===============================================================
-- Controllo 'silver.erp_px_cat_g1v2'
-- ===============================================================

-- Controllo tra PK e FK delle tabelle
-- SELECT * FROM bronze.erp_px_cat_g1v2;
-- GO
-- SELECT cat_id FROM silver.crm_prd_info;


-- controllare la presenza di spazi indesiderati
-- Aspetattiva: NO resultati
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);


-- Controllo per coerenza dei dati
-- la colonna 'cat'
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2;
-- la colonna 'subcat'
SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2;
-- la colonna 'maintenance'
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;
