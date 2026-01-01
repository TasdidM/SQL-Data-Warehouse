/*
=======================================================================
Controlli di Qualità
=======================================================================
Scopo dello script:
    Questo script esegue controlli di qualità per convalidare 
    l'integrità, la coerenza e l'accuratezza del Gold Layer.
    Questi controlli assicurano:
    - Unicità delle chiavi surrogate nelle tabelle delle dimensioni.
    - Integrità referenziale tra tabelle dei fatti e delle dimensioni.
    - Convalida delle relazioni nel modello di dati a uso analitici.

Note sull'uso:
    - Esaminare e risolvere eventuali discrepanze individuate durante 
    i controlli.
*/ 


-- ====================================================================
-- Controllo di 'gold.dim_customers'
-- ====================================================================

-- Verifica l'unicità della customer_key in gold.dim_customers
-- Aspettativa: NO resulti
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Controllo di 'gold.product_key'
-- ====================================================================

-- Verifica l'unicità della customer_key in gold.product_key
-- Aspettativa: NO resulti
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Controllo 'gold.fact_sales'
-- ====================================================================

-- Verifica la collegabilità del modello di dati tra fatti e dimensioni
-- Aspettativa: NO resulti
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE c.customer_key IS NULL
OR p.product_key IS NULL;
