DROP TABLE IF EXISTS stg_customers;
CREATE TABLE stg_customers AS
SELECT DISTINCT
    trim(customer_id) AS customer_id,
    trim(customer_unique_id) AS customer_unique_id,
    trim(customer_zip_code_prefix) AS customer_zip_code_prefix,
    lower(trim(customer_city)) AS customer_city,
    upper(trim(customer_state)) AS customer_state
FROM raw_customers
WHERE customer_id IS NOT NULL AND trim(customer_id) <> '';

DROP TABLE IF EXISTS stg_geolocation;
CREATE TABLE stg_geolocation AS
SELECT
    trim(geolocation_zip_code_prefix) AS geolocation_zip_code_prefix,
    round(avg(CAST(geolocation_lat AS REAL)), 6) AS geolocation_lat,
    round(avg(CAST(geolocation_lng AS REAL)), 6) AS geolocation_lng,
    lower(trim(geolocation_city)) AS geolocation_city,
    upper(trim(geolocation_state)) AS geolocation_state
FROM raw_geolocation
WHERE geolocation_zip_code_prefix IS NOT NULL
GROUP BY
    trim(geolocation_zip_code_prefix),
    lower(trim(geolocation_city)),
    upper(trim(geolocation_state));

DROP TABLE IF EXISTS stg_orders;
CREATE TABLE stg_orders AS
WITH ranked_orders AS (
    SELECT
        trim(order_id) AS order_id,
        trim(customer_id) AS customer_id,
        lower(trim(order_status)) AS order_status,
        trim(order_purchase_timestamp) AS order_purchase_timestamp,
        nullif(trim(order_approved_at), '') AS order_approved_at,
        nullif(trim(order_delivered_carrier_date), '') AS order_delivered_carrier_date,
        nullif(trim(order_delivered_customer_date), '') AS order_delivered_customer_date,
        nullif(trim(order_estimated_delivery_date), '') AS order_estimated_delivery_date,
        row_number() OVER (
            PARTITION BY trim(order_id)
            ORDER BY trim(order_purchase_timestamp) DESC
        ) AS row_num
    FROM raw_orders
    WHERE order_id IS NOT NULL AND trim(order_id) <> ''
)
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM ranked_orders
WHERE row_num = 1;

DROP TABLE IF EXISTS stg_order_items;
CREATE TABLE stg_order_items AS
SELECT DISTINCT
    trim(order_id) AS order_id,
    CAST(order_item_id AS INTEGER) AS order_item_id,
    trim(product_id) AS product_id,
    trim(seller_id) AS seller_id,
    trim(shipping_limit_date) AS shipping_limit_date,
    CAST(price AS REAL) AS price,
    CAST(freight_value AS REAL) AS freight_value
FROM raw_order_items
WHERE order_id IS NOT NULL
  AND trim(order_id) <> ''
  AND CAST(price AS REAL) >= 0
  AND CAST(freight_value AS REAL) >= 0;

DROP TABLE IF EXISTS stg_products;
CREATE TABLE stg_products AS
SELECT DISTINCT
    trim(product_id) AS product_id,
    coalesce(nullif(lower(trim(product_category_name)), ''), 'unknown') AS product_category_name,
    CAST(product_name_lenght AS INTEGER) AS product_name_length,
    CAST(product_description_lenght AS INTEGER) AS product_description_length,
    CAST(product_photos_qty AS INTEGER) AS product_photos_qty,
    CAST(product_weight_g AS REAL) AS product_weight_g,
    CAST(product_length_cm AS REAL) AS product_length_cm,
    CAST(product_height_cm AS REAL) AS product_height_cm,
    CAST(product_width_cm AS REAL) AS product_width_cm
FROM raw_products
WHERE product_id IS NOT NULL AND trim(product_id) <> '';

DROP TABLE IF EXISTS stg_payments;
CREATE TABLE stg_payments AS
SELECT
    trim(order_id) AS order_id,
    CAST(payment_sequential AS INTEGER) AS payment_sequential,
    lower(trim(payment_type)) AS payment_type,
    CAST(payment_installments AS INTEGER) AS payment_installments,
    CAST(payment_value AS REAL) AS payment_value
FROM raw_payments
WHERE order_id IS NOT NULL
  AND trim(order_id) <> ''
  AND CAST(payment_value AS REAL) >= 0;

DROP TABLE IF EXISTS stg_reviews;
CREATE TABLE stg_reviews AS
SELECT
    trim(review_id) AS review_id,
    trim(order_id) AS order_id,
    CAST(review_score AS INTEGER) AS review_score,
    nullif(trim(review_comment_title), '') AS review_comment_title,
    nullif(trim(review_comment_message), '') AS review_comment_message,
    trim(review_creation_date) AS review_creation_date,
    trim(review_answer_timestamp) AS review_answer_timestamp
FROM raw_reviews
WHERE order_id IS NOT NULL AND trim(order_id) <> '';

DROP TABLE IF EXISTS stg_sellers;
CREATE TABLE stg_sellers AS
SELECT DISTINCT
    trim(seller_id) AS seller_id,
    trim(seller_zip_code_prefix) AS seller_zip_code_prefix,
    lower(trim(seller_city)) AS seller_city,
    upper(trim(seller_state)) AS seller_state
FROM raw_sellers
WHERE seller_id IS NOT NULL AND trim(seller_id) <> '';

DROP TABLE IF EXISTS stg_category_translation;
CREATE TABLE stg_category_translation AS
SELECT DISTINCT
    lower(trim(product_category_name)) AS product_category_name,
    lower(trim(product_category_name_english)) AS product_category_name_english
FROM raw_category_translation
WHERE product_category_name IS NOT NULL
  AND trim(product_category_name) <> '';
