DROP TABLE IF EXISTS mart_sales_summary;
CREATE TABLE mart_sales_summary AS
SELECT
    order_month,
    count(DISTINCT order_id) AS total_orders,
    round(sum(total_payment_value), 2) AS total_revenue,
    round(avg(total_payment_value), 2) AS average_order_value
FROM fact_orders
WHERE order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

DROP TABLE IF EXISTS mart_customer_summary;
CREATE TABLE mart_customer_summary AS
SELECT
    c.customer_id,
    min(f.order_purchase_date) AS first_order_date,
    max(f.order_purchase_date) AS last_order_date,
    count(DISTINCT f.order_id) AS total_orders,
    round(sum(f.total_payment_value), 2) AS total_spent,
    CASE
        WHEN sum(f.total_payment_value) >= 1000 THEN 'high_value'
        WHEN sum(f.total_payment_value) >= 300 THEN 'growing'
        ELSE 'new'
    END AS customer_segment
FROM dim_customers c
INNER JOIN fact_orders f ON c.customer_id = f.customer_id
WHERE f.order_status = 'delivered'
GROUP BY c.customer_id
ORDER BY total_spent DESC;

DROP TABLE IF EXISTS mart_product_performance;
CREATE TABLE mart_product_performance AS
SELECT
    p.product_category_name AS product_category,
    p.product_id,
    count(*) AS total_units_sold,
    round(sum(oi.item_revenue), 2) AS total_revenue,
    round(avg(oi.price), 2) AS average_price
FROM fact_order_items oi
INNER JOIN dim_products p ON oi.product_id = p.product_id
INNER JOIN fact_orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name, p.product_id
ORDER BY total_revenue DESC;

DROP TABLE IF EXISTS mart_delivery_performance;
CREATE TABLE mart_delivery_performance AS
SELECT
    substr(order_delivered_customer_date, 1, 7) AS delivery_month,
    round(avg(delivery_days), 2) AS avg_delivery_days,
    sum(is_delayed) AS delayed_orders,
    round(100.0 * sum(is_delayed) / count(*), 2) AS delay_rate_percent
FROM fact_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY substr(order_delivered_customer_date, 1, 7)
ORDER BY delivery_month;

