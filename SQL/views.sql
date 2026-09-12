use insightcart;
-- create the monthly sales view

CREATE VIEW vw_monthly_sales AS
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%M') AS Month,
    ROUND(SUM(p.payment_value), 2) AS Revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%M')
ORDER BY MIN(o.order_purchase_timestamp);

-- Create State Revenue View

CREATE VIEW vw_state_revenue AS
SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value),2) AS Revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state;

SELECT * FROM vw_state_revenue;

-- Create Top Categories View

CREATE VIEW vw_top_categories AS
SELECT
    pr.product_category_name,
    ROUND(SUM(oi.price),2) AS Revenue
FROM products pr
JOIN order_items oi
ON pr.product_id = oi.product_id
GROUP BY pr.product_category_name;

-- Create Seller Revenue View

CREATE VIEW vw_seller_revenue AS
SELECT
    seller_id,
    ROUND(SUM(price + freight_value),2) AS Revenue
FROM order_items
GROUP BY seller_id;

-- check all views

SHOW FULL TABLES
WHERE Table_type = 'VIEW';