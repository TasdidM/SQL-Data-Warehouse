# Guida Metodologica Naming
Questo documento descrive le convenzioni di denominazione utilizzate per schemi, tabelle, viste, colonne e altri oggetti nel data warehouse.

## Indice

1. [Principi Generali](#principi-generali)
2. [Convenzioni di Denominazione delle Tabelle](convezioni-di-denominazione-delle-tabelle)

## Principi Generali

- **Convenzioni di Denominazione**: Utilizza snake_case, con lettere minuscole e trattini bassi (_) per separare le parole.
- **Linguaggio**: Utilizza l'Inglese per tutti i nomi.
- **Evitare Parole Riservate**: Non utilizzare parole riservate da SQL come nomi di oggetti.

## Convenzioni di Denominazione delle Tabelle

### Regole di Bronze:
- Tutti i nomi devono iniziare con il nome del sistema di origine e i nomi delle tabelle devono corrispondere ai nomi originali senza essere modificati.
- **`<source-system>_<entity>`**
    - `<source-system>`: Nome del sistema di origine (ad es., `crm`, `erp`)
    - `<entity>`: Nome esatto della tabella dal sistema di origine.
    - Esempio: `crm_cutomer_info` → Informazioni sui clienti dal sistema CRM.

### Regole di Silver:
- Tutti i nomi devono iniziare con il nome del sistema di origine e i nomi delle tabelle devono corrispondere ai nomi originali senza essere modificati.
- **`<source-system>_<entity>`**
    - `<source-system>`: Nome del sistema di origine (ad es., `crm`, `erp`)
    - `<entity>`: Nome esatto della tabella dal sistema di origine.
    - Esempio: `crm_cutomer_info` → Informazioni sui clienti dal sistema CRM.

### Regole di Gold:
 - Tutti i nomi devono essere significativi e in linea con l'attivitá aziendale per le tabelle, iniziando con il prefisso della categoria.
 - **`<category>_<entity>`**
     - `<category>`: Describe il ruolo della tabella, ad esempio `dim` (tabella di dimensione) o `fact` (tabella di fatto).
     - `entity`: Nome descrittivo della tabella, allineato al dominio aziendale (ad es., `customers`, `products`, `sales`).
     - Esempio:
         - `dim_customers` → Tablella delle dimensioni per i clienti.
         - `fact_sales` → Tabella dei fatti contenente le transazioni di vendita.
#### Glossario dei Modelli di Categoria
| Modelli    | Significato              | Esempi                                     |
|------------|--------------------------|--------------------------------------------|
| `dim_`     | Tabella delle dimensioni | `dim_customer`, `dim_product`              |
| `fact_`    | Tabella dei fatti        | `fact_sales`                               |
| `report_`  | Tabella di report        | `report_customers`, `report_sales_monthly` |

---

## Convenzioni di Denominazione delle Colonne

### Chiavi Surrogate
- Tutte le chiavi primarie nelle tabelle delle dimensioni devono utilizzare il suffisso `_key`.
- **`<table-name>_key`**
    - `<table-name>`: Si refirisce al nome della tabella o dell'entitá a cui appartiene la chiave.
    - `_key`: Suffiso che indica che questa colonna è una chiave surrogata.
    - Esempio: `customer_key` → Chiave surrogata nella tabella `dim_customers`.

### Colonne di Sistema
- Tutte le colonne tecniche devono iniziare con il prefisso `dwh_`, seguito da un nome descrittivo che indica lo scopo della colonna.
- **`dwh_<column-name>`**
    - `dwh`: Prefisso esclusivamente per metadati generati dal sistema.
    - `<column-name>`: Nome descrittivo che indica lo scopo della colonna.
    - Esempio: `dwh_load_date` → Colonna generata dal sistema utilizzata per registare la data in cui è stato caricato il record.

## Stored Procedure
- Tutte le procedure di archiviazione per caricare dati devono seguire lo standard di denominazione indicato nella riga successiva.
- **`load_<layer>`**
    - `<layer>`: Rappresenta il livello che viene caricato, come `bronze`, `silver` o `gold`.
    - Esempio:
       - `load_bronze` → Stored procedure per caricare dati nel livello Bronze.
       - `load_silver` → Stored procedure per caricare dati nel livello Silver. 
















