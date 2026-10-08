CREATE DATABASE insightcart_dw;

USE insightcart_dw;
SELECT DATABASE();

-- ### 1 customers
USE insightcart_dw;

CREATE TABLE stg_customers AS
SELECT *
FROM insightcart.customers;

SELECT COUNT(*) AS total_customers
FROM stg_customers;

-- #### 2 products
USE insightcart_dw;

CREATE TABLE stg_products AS
SELECT *
FROM insightcart.products;

SELECT COUNT(*) AS total_products
FROM stg_products;

-- ### 3 orders
USE insightcart_dw;

CREATE TABLE stg_orders AS
SELECT *
FROM insightcart.orders;

SELECT COUNT(*) AS total_orders
FROM stg_orders;

DESCRIBE stg_orders;

-- ### 4 orderitems

USE insightcart_dw;

CREATE TABLE stg_order_items AS
SELECT *
FROM insightcart.order_items;

SELECT COUNT(*) AS total_order_items
FROM stg_order_items;

DESCRIBE stg_order_items;

-- #### 5 sellers

USE insightcart_dw;

CREATE TABLE stg_sellers AS
SELECT *
FROM insightcart.sellers;

SELECT COUNT(*) AS total_sellers
FROM stg_sellers;

###### 6 Date
USE insightcart_dw;

CREATE TABLE stg_date (
    full_date DATE
);

DESCRIBE stg_date;


-- ### DIMENSIONS

#### 1 DIM CUSTOMER
USE insightcart_dw;

CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_city VARCHAR(100),
    customer_state VARCHAR(100)
);

DESCRIBE dim_customer;

INSERT INTO dim_customer (
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM stg_customers;

SELECT COUNT(*) AS total_customers
FROM dim_customer;

SELECT *
FROM dim_customer
LIMIT 5;

-- #### 2 DIM PRODUCT
USE insightcart_dw;

CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    category VARCHAR(100),
    weight DECIMAL(10,2),
    length DECIMAL(10,2),
    height DECIMAL(10,2),
    width DECIMAL(10,2)
);
DESCRIBE dim_product;

INSERT INTO dim_product (
    product_id,
    category,
    weight,
    length,
    height,
    width
)
SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM stg_products;

SELECT *
FROM dim_product
LIMIT 5;

#### 3 DIM SELLER

USE insightcart_dw;

CREATE TABLE dim_seller (
    seller_key INT AUTO_INCREMENT PRIMARY KEY,
    seller_id VARCHAR(50),
    seller_city VARCHAR(100),
    seller_state VARCHAR(100)
);
DESCRIBE dim_seller;

INSERT INTO dim_seller (
    seller_id,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_city,
    seller_state
FROM stg_sellers;

SELECT *
FROM dim_seller
LIMIT 5;

#### 4 DIM DATE

USE insightcart_dw;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT
);

DESCRIBE dim_date;

SELECT
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date
FROM stg_orders;

INSERT INTO dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day
)
WITH RECURSIVE dates AS (
    SELECT DATE(MIN(order_purchase_timestamp)) AS full_date
    FROM stg_orders

    UNION ALL

    SELECT DATE_ADD(full_date, INTERVAL 1 DAY)
    FROM dates
    WHERE full_date < (
        SELECT DATE(MAX(order_purchase_timestamp))
        FROM stg_orders
    )
)
SELECT
    YEAR(full_date) * 10000
        + MONTH(full_date) * 100
        + DAY(full_date) AS date_key,
    full_date,
    YEAR(full_date) AS year,
    QUARTER(full_date) AS quarter,
    MONTH(full_date) AS month,
    MONTHNAME(full_date) AS month_name,
    DAY(full_date) AS day
FROM dates;

SELECT *
FROM dim_date
ORDER BY full_date
LIMIT 5;

#### FACT TABLE

USE insightcart_dw;

CREATE TABLE fact_sales (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    date_key INT,
    customer_key INT,
    product_key INT,
    seller_key INT,
    quantity INT,
    product_price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    total_amount DECIMAL(10,2)
);

DESCRIBE fact_sales;

INSERT INTO fact_sales (
    order_id,
    date_key,
    customer_key,
    product_key,
    seller_key,
    quantity,
    product_price,
    freight_value,
    total_amount
)
SELECT
    oi.order_id,

    YEAR(o.order_purchase_timestamp) * 10000
        + MONTH(o.order_purchase_timestamp) * 100
        + DAY(o.order_purchase_timestamp) AS date_key,

    dc.customer_key,
    dp.product_key,
    ds.seller_key,

    1 AS quantity,

    oi.price,
    oi.freight_value,

    oi.price + oi.freight_value AS total_amount

FROM stg_order_items oi

JOIN stg_orders o
    ON oi.order_id = o.order_id

JOIN dim_customer dc
    ON o.customer_id = dc.customer_id

JOIN dim_product dp
    ON oi.product_id = dp.product_id

JOIN dim_seller ds
    ON oi.seller_id = ds.seller_id;
    
    SELECT COUNT(*) AS total_sales
FROM fact_sales;

SELECT *
FROM fact_sales
LIMIT 10;

SELECT COUNT(*) AS source_order_items
FROM stg_order_items;

SELECT
    COUNT(*) AS total_rows,
    SUM(customer_key IS NULL) AS missing_customer,
    SUM(product_key IS NULL) AS missing_product,
    SUM(seller_key IS NULL) AS missing_seller,
    SUM(date_key IS NULL) AS missing_date
FROM fact_sales;

SELECT
    SUM(total_amount) AS total_revenue
FROM fact_sales;

SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.total_amount) AS monthly_revenue
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;
    
SELECT
p.category,
SUM(f.total_amount) AS category_revenue
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.category
ORDER BY
    category_revenue DESC;
    
SELECT
    c.customer_state,
    SUM(f.total_amount) AS state_revenue
FROM fact_sales f
JOIN dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_state
ORDER BY
    state_revenue DESC;
    
SELECT
    customer_id,
    COUNT(*) AS count
FROM dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    product_id,
    COUNT(*) AS count
FROM dim_product
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
    seller_id,
    COUNT(*) AS count
FROM dim_seller
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS incorrect_rows
FROM fact_sales
WHERE total_amount <> product_price + freight_value;

USE insightcart_dw;
CREATE TABLE fact_sales_etl (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    date_key INT,
    customer_key INT,
    product_key INT,
    seller_key INT,
    quantity INT,
    product_price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    total_amount DECIMAL(10,2)
);

SHOW TABLES;

TRUNCATE TABLE fact_sales_etl;

USE insightcart_dw;

SELECT COUNT(*) AS total_rows
FROM fact_sales_etl;

SELECT 1;

SELECT
    COUNT(*) AS total_rows,
    SUM(customer_key IS NULL) AS missing_customer,
    SUM(product_key IS NULL) AS missing_product,
    SUM(seller_key IS NULL) AS missing_seller,
    SUM(date_key IS NULL) AS missing_date
FROM fact_sales_etl;

SELECT COUNT(*) AS incorrect_rows
FROM fact_sales_etl
WHERE total_amount <> product_price + freight_value;

SELECT
    (SELECT COUNT(*) FROM dim_customer) AS customers,
    (SELECT COUNT(*) FROM dim_product) AS products,
    (SELECT COUNT(*) FROM dim_seller) AS sellers,
    (SELECT COUNT(*) FROM dim_date) AS dates;
    
SELECT
COUNT(*) AS total_fact_rows,
COUNT(dc.customer_key) AS matched_customers,
COUNT(dp.product_key) AS matched_products,
COUNT(ds.seller_key) AS matched_sellers,
COUNT(dd.date_key) AS matched_dates
FROM fact_sales f
LEFT JOIN dim_customer dc
    ON f.customer_key = dc.customer_key
LEFT JOIN dim_product dp
    ON f.product_key = dp.product_key
LEFT JOIN dim_seller ds
    ON f.seller_key = ds.seller_key
LEFT JOIN dim_date dd
    ON f.date_key = dd.date_key;
    
SELECT customer_key, COUNT(*) AS cnt
FROM dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT
    customer_key,
    COUNT(*) AS cnt
FROM dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

SELECT
    seller_key,
    COUNT(*) AS cnt
FROM dim_seller
GROUP BY seller_key
HAVING COUNT(*) > 1;

SELECT
    date_key,
    COUNT(*) AS cnt
FROM dim_date
GROUP BY date_key
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS total_rows
FROM fact_sales;

SELECT
    order_id,
    date_key,
    customer_key,
    product_key,
    seller_key,
    quantity,
    product_price,
    freight_value,
    total_amount,
    COUNT(*) AS cnt
FROM fact_sales
GROUP BY
    order_id,
    date_key,
    customer_key,
    product_key,
    seller_key,
    quantity,
    product_price,
    freight_value,
    total_amount
HAVING COUNT(*) > 1
LIMIT 10;

TRUNCATE TABLE fact_sales;
INSERT INTO fact_sales (
    order_id,
    date_key,
    customer_key,
    product_key,
    seller_key,
    quantity,
    product_price,
    freight_value,
    total_amount
)
SELECT
    oi.order_id,
    YEAR(o.order_purchase_timestamp) * 10000
        + MONTH(o.order_purchase_timestamp) * 100
        + DAY(o.order_purchase_timestamp) AS date_key,
    dc.customer_key,
    dp.product_key,
    ds.seller_key,
    1 AS quantity,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS total_amount
FROM stg_order_items oi
JOIN stg_orders o
    ON oi.order_id = o.order_id
JOIN dim_customer dc
    ON o.customer_id = dc.customer_id
JOIN dim_product dp
    ON oi.product_id = dp.product_id
JOIN dim_seller ds
    ON oi.seller_id = ds.seller_id;
    
SELECT COUNT(*) AS total_rows
FROM fact_sales;

SELECT
    COUNT(*) AS duplicate_groups
FROM (
    SELECT
        order_id,
        date_key,
        customer_key,
        product_key,
        seller_key,
        quantity,
        product_price,
        freight_value,
        total_amount
    FROM fact_sales
    GROUP BY
        order_id,
        date_key,
        customer_key,
        product_key,
        seller_key,
        quantity,
        product_price,
        freight_value,
        total_amount
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT
    COUNT(*) AS source_order_items
FROM stg_order_items;

SELECT
    COUNT(*) AS total_rows,
    SUM(customer_key IS NULL) AS missing_customer,
    SUM(product_key IS NULL) AS missing_product,
    SUM(seller_key IS NULL) AS missing_seller,
    SUM(date_key IS NULL) AS missing_date
FROM fact_sales;

SELECT SUM(total_amount) AS warehouse_revenue
FROM fact_sales;