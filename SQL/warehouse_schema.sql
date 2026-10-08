-- =====================================================
-- InsightCart Data Warehouse Schema
-- =====================================================

CREATE DATABASE IF NOT EXISTS insightcart_dw;

USE insightcart_dw;


-- =====================================================
-- 1. Staging Tables
-- =====================================================

CREATE TABLE IF NOT EXISTS stg_customers AS
SELECT * FROM insightcart.customers;

CREATE TABLE IF NOT EXISTS stg_products AS
SELECT * FROM insightcart.products;

CREATE TABLE IF NOT EXISTS stg_orders AS
SELECT * FROM insightcart.orders;

CREATE TABLE IF NOT EXISTS stg_order_items AS
SELECT * FROM insightcart.order_items;

CREATE TABLE IF NOT EXISTS stg_sellers AS
SELECT * FROM insightcart.sellers;


-- =====================================================
-- 2. Dimension Tables
-- =====================================================

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_city VARCHAR(100),
    customer_state VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    category VARCHAR(100),
    weight DECIMAL(10,2),
    length DECIMAL(10,2),
    height DECIMAL(10,2),
    width DECIMAL(10,2)
);


CREATE TABLE IF NOT EXISTS dim_seller (
    seller_key INT AUTO_INCREMENT PRIMARY KEY,
    seller_id VARCHAR(50),
    seller_city VARCHAR(100),
    seller_state VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT
);


-- =====================================================
-- 3. Fact Table
-- =====================================================

CREATE TABLE IF NOT EXISTS fact_sales (
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