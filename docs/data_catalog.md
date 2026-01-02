# Catalogo Dati per Gold Layer

## Panoramica
Il Gold Layer è la rappresentazione dei dati a livello aziendale, strutturata per supportare casi d'uso analitici e di reporting. È costituito da tabelle di dimensioni e di fatti per metriche aziendale spechifice.

------------------

### 1. gold.dim_customers
- **Scopo**: Contiene i dettagli dei clienti arricchiti con dati demografici e geografici.
- **Colonne**:

| Nome di Colonna    | Tipo dei dati   | Descrizione
|--------------------|-----------------|----------------------------------------------|
| `customer_key`     | INT             | Chiave surrogata che indentifica in modo unico ogni record cliente nella tabella delle dimensioni dei clienti.
| `customer_id`      | INT             | Identificativo numerico unico assegnato a ciascun cliente.
| `customer_number`  | NVARCHAR(50)    | Indentificatore alfanumerico che rappresenta il cliente, utilizzato per il tracciamento e il riferimento.
| `first_name`       | NVARCHAR(50)    | Il nome del cliente, come registrato nel sistema.
| `last_name`        | NVARCHAR(50)    | Il cognome del cliente.
| `country`          | NVARCHAR(50)    | Il paese di residenza del cliente (ad.es. 'Australia').
| `marital_status`   | NVARCHAR(50)    | Lo stato civile del cliente (ad.es. 'Married', 'Single').
| `gender`           | NVARCHAR(50)    | Il genere del cliente (ad.es. 'Male', 'Female').
| `birth_date`       | DATE            | La data di nascita del cliente, nel formato YYYY-MM-DD.
| `create_date`      | DATE            | La data in cui è stato creato il record del cliente nel sistema.

--------------------

### 2. gold.dim_products
- **Scopo**: Fornisce informazioni sui prodotti e sulle loro caratteristiche.
- **Colonne**:

| Nome di Colonna    | Tipo dei dati   | Descrizione
|--------------------|-----------------|----------------------------------------------|
| `prdocut_key`      | INT             | Chiave surrogata che identifica in modo unico ogni record di prodotto nella tabella delle dimensioni dei prodotti.
| `product_id`       | INT             | Identificatore unico assegnato al prodotto per il tracciamento interno e il riferimento.
| `product_number`   | NVARCHAR(50)    | Codice alfanumerico strutturato che rappresenta il prodotto, spesso utilizzto per la categorizzazione o l'inventario.
| `product_name`     | NVARCHAR(50)    | Nome descrittivo del prodotto, inclusi dettagli chiave come tipo, colore e dimensioni.
| `category_id`      | NVARCHAR(50)    | Un identificatore unico per la categoria del prodotto, collegato alla sua classificazione di alto livello.
| `category`         | NVARCHAR(50)    | La classificazione più generica del prodotto (ad. es. Bikes, Components) per raggruppare articoli correlati.
| `subcategory`      | NVARCHAR(50)    | Classificazione più dettagliata del prodotto all'interno della categoria, come il tipo di prodotto.
| `maintenance`      | NVARCHAR(50)    | Indica se il prodotto richiede manutenzione (ad. es. Yes, No).
| `cost`             | INT             | Il costo o il prezzo base del prodotto, valutato in unità monetarie.
| `product_line`     | NVARCHAR(50)    | La linea o serie del prodotto specifico a cui lo appartiene.
| `start_date`       | DATE            | La data in cui il prodotto è stato messo in vendita con il relativo prezzo.

--------------------

### 3. gold.fact_sales
- **Scopo**: Registra i dati relativi alle transazioni di vendita a fini analitici.
- **Colonne**:

| Nome di Colonna    | Tipo dei dati   | Descrizione
|--------------------|-----------------|----------------------------------------------|
| `order_number`     | NVARCHAR(50)    | Identificatore alfanumerico unico per ogni ordine di vendita.
| `product_key`      | INT             | Chiave surrogata che collega l'ordine alla tabella delle dimensioni del prodotto.
| `customer_key`     | INT             | Chiave surrogata che collega l'ordine alla tabella delle dimensioni del cliente.
| `order_date`       | DATE            | La data in cui è stato effettuato l'ordine.
| `shipping_date`    | DATE            | La data in cui l'ordine è stato spedito al cliente.
| `due_date`         | DATE            | La data in cui era previsto il pagamento dell'ordine.
| `sales_amount`     | INT             | Il valore monetario totale della vendita, in unità monetarie intere.
| `quantity`         | INT             | Il numero di pezzi del prodotto sono ordinati.
| `price`            | INT             | Il prezzo unitario del prodotto, in unità monetarie intere.

























