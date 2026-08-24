-- ============================================================
-- Script: 02_data_import.sql
-- Project: Olist Marketplace Performance Analysis
-- Analyst: isaactheanalyst
-- Description: CSV import using LOAD DATA LOCAL INFILE.
--              Update file paths to match your local directory.
-- Note: Enable OPT_LOCAL_INFILE=1 in MySQL Workbench
--       connection settings before running these imports.
-- ============================================================

USE olist_customer_sales;


-- ── dim_category ─────────────────────────────────────────────
LOAD DATA LOCAL INFILE
'/your-path/product_category_name_translation.csv'
INTO TABLE dim_category
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_category_name,
    product_category_name_english
);
-- Expected: 71 rows


-- ── dim_customer ─────────────────────────────────────────────
LOAD DATA LOCAL INFILE
'/your-path/olist_customers_dataset.csv'
INTO TABLE dim_customer
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
);
-- Expected: 99,441 rows


-- ── dim_product ──────────────────────────────────────────────
LOAD DATA LOCAL INFILE
'/your-path/olist_products_dataset.csv'
INTO TABLE dim_product
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
);
-- Expected: 32,340 rows


-- ── dim_seller ───────────────────────────────────────────────
LOAD DATA LOCAL INFILE
'/your-path/olist_sellers_dataset.csv'
INTO TABLE dim_seller
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
);
-- Expected: 3,095 rows


-- ── dim_geolocation ──────────────────────────────────────────
-- Note: This file uses \r\n line endings — use LINES TERMINATED BY '\r\n'
LOAD DATA LOCAL INFILE
'/your-path/olist_geolocation_dataset.csv'
INTO TABLE dim_geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
);
-- Expected: 1,000,163 rows


-- ── fact_orders ──────────────────────────────────────────────
LOAD DATA LOCAL INFILE
'/your-path/olist_orders_dataset.csv'
INTO TABLE fact_orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
);


-- ── fact_order_items ─────────────────────────────────────────
LOAD DATA LOCAL INFILE
'/your-path/olist_order_items_dataset.csv'
INTO TABLE fact_order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
);


-- ── fact_payments ────────────────────────────────────────────
LOAD DATA LOCAL INFILE
'/your-path/olist_order_payments_dataset.csv'
INTO TABLE fact_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
);


-- ── fact_reviews ─────────────────────────────────────────────
LOAD DATA LOCAL INFILE
'/your-path/olist_order_reviews_dataset.csv'
INTO TABLE fact_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    review_id,
    order_id,
    review_score,
    review_creation_date,
    review_answer_timestamp
);
-- Expected: 98,409 rows
