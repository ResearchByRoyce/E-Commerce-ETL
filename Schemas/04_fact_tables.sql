DROP TABLE IF EXISTS fact_orders;
CREATE TABLE fact_orders AS
WITH payment_totals AS (
    SELECT
        order_id,
        sum(payment_value) AS total_payment_value
    FROM stg_payments
    GROUP BY order_id
),
item_totals AS (
    SELECT
        order_id,
        sum(price + freight_value) AS total_item_value
    FROM stg_order_items
    GROUP BY order_id
),
review_scores AS (
    SELECT
        order_id,
        avg(review_score) AS avg_review_score
    FROM stg_reviews
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    substr(o.order_purchase_timestamp, 1, 10) AS order_purchase_date,
    substr(o.order_purchase_timestamp, 1, 7) AS order_month,
    o.order_status,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    coalesce(p.total_payment_value, 0) AS total_payment_value,
    coalesce(i.total_item_value, 0) AS total_item_value,
    r.avg_review_score,
    date_diff_days(o.order_delivered_customer_date, o.order_purchase_timestamp) AS delivery_days,
    CASE
        WHEN o.order_delivered_customer_date IS NULL THEN 0
        WHEN substr(o.order_delivered_customer_date, 1, 10) > substr(o.order_estimated_delivery_date, 1, 10) THEN 1
        ELSE 0
    END AS is_delayed
FROM stg_orders o
LEFT JOIN payment_totals p ON o.order_id = p.order_id
LEFT JOIN item_totals i ON o.order_id = i.order_id
LEFT JOIN review_scores r ON o.order_id = r.order_id;

DROP TABLE IF EXISTS fact_order_items;
CREATE TABLE fact_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS item_revenue
FROM stg_order_items oi
INNER JOIN stg_orders o ON oi.order_id = o.order_id;

DROP TABLE IF EXISTS fact_payments;
CREATE TABLE fact_payments AS
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM stg_payments;

