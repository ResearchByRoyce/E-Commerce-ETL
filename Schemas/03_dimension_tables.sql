DROP TABLE IF EXISTS dim_customers;
CREATE TABLE dim_customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM stg_customers;

DROP TABLE IF EXISTS dim_geolocation;
CREATE TABLE dim_geolocation AS
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM stg_geolocation;

DROP TABLE IF EXISTS dim_products;
CREATE TABLE dim_products AS
SELECT
    p.product_id,
    p.product_category_name AS product_category_name_original,
    coalesce(t.product_category_name_english, p.product_category_name) AS product_category_name,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM stg_products p
LEFT JOIN stg_category_translation t
    ON p.product_category_name = t.product_category_name;

DROP TABLE IF EXISTS dim_sellers;
CREATE TABLE dim_sellers AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM stg_sellers;

DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date AS
WITH source_dates AS (
    SELECT substr(order_purchase_timestamp, 1, 10) AS date_day FROM stg_orders
    UNION
    SELECT substr(order_delivered_customer_date, 1, 10) AS date_day FROM stg_orders
    UNION
    SELECT substr(order_estimated_delivery_date, 1, 10) AS date_day FROM stg_orders
)
SELECT
    date_day,
    CAST(substr(date_day, 1, 4) AS INTEGER) AS year_num,
    CAST(substr(date_day, 6, 2) AS INTEGER) AS month_num,
    CAST(substr(date_day, 9, 2) AS INTEGER) AS day_num,
    substr(date_day, 1, 7) AS year_month
FROM source_dates
WHERE date_day IS NOT NULL AND trim(date_day) <> '';
