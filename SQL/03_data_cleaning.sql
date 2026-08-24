-- ============================================================
-- Script: 03_data_cleaning.sql
-- Project: Olist Marketplace Performance Analysis
-- Analyst: isaactheanalyst
-- Description: Data type standardisation, empty string
--              handling, and invalid date cleaning before
--              schema modification and key creation.
-- ============================================================

USE olist_customer_sales;


-- ── Step 1: Convert ID columns from TEXT to VARCHAR ──────────
-- Required before primary keys can be added (TEXT columns
-- cannot be used as primary keys without a key length)

ALTER TABLE dim_customer
    MODIFY customer_id              VARCHAR(50) NOT NULL,
    MODIFY customer_unique_id       VARCHAR(50),
    MODIFY customer_zip_code_prefix VARCHAR(20),
    MODIFY customer_city            VARCHAR(100),
    MODIFY customer_state           VARCHAR(10);

ALTER TABLE dim_product
    MODIFY product_id               VARCHAR(50) NOT NULL,
    MODIFY product_category_name    VARCHAR(100);

ALTER TABLE dim_category
    MODIFY product_category_name         VARCHAR(100) NOT NULL,
    MODIFY product_category_name_english VARCHAR(100);

ALTER TABLE dim_seller
    MODIFY seller_id                VARCHAR(50) NOT NULL,
    MODIFY seller_zip_code_prefix   VARCHAR(20),
    MODIFY seller_city              VARCHAR(100),
    MODIFY seller_state             VARCHAR(10);

ALTER TABLE dim_geolocation
    MODIFY geolocation_zip_code_prefix VARCHAR(20),
    MODIFY geolocation_lat             DECIMAL(18,15),
    MODIFY geolocation_lng             DECIMAL(18,15),
    MODIFY geolocation_city            VARCHAR(100),
    MODIFY geolocation_state           VARCHAR(10);

ALTER TABLE fact_order_items
    MODIFY order_id     VARCHAR(50) NOT NULL,
    MODIFY product_id   VARCHAR(50),
    MODIFY seller_id    VARCHAR(50);

ALTER TABLE fact_payments
    MODIFY order_id     VARCHAR(50) NOT NULL;

ALTER TABLE fact_reviews
    MODIFY review_id    VARCHAR(50),
    MODIFY order_id     VARCHAR(50) NOT NULL;


-- ── Step 2: Clean empty strings in fact_orders date columns ──
-- Empty strings prevent conversion to DATETIME

UPDATE fact_orders
SET order_approved_at = NULL
WHERE order_approved_at = '';

UPDATE fact_orders
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date = '';

UPDATE fact_orders
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

UPDATE fact_orders
SET order_estimated_delivery_date = NULL
WHERE order_estimated_delivery_date = '';


-- ── Step 3: Clean invalid zero dates in fact_reviews ─────────
-- 0000-00-00 00:00:00 is not a valid DATETIME value

UPDATE fact_reviews
SET review_creation_date = NULL
WHERE review_creation_date = '0000-00-00 00:00:00';

UPDATE fact_reviews
SET review_answer_timestamp = NULL
WHERE review_answer_timestamp = '0000-00-00 00:00:00';


-- ── Step 4: Convert date columns to DATETIME ─────────────────

ALTER TABLE fact_orders
    MODIFY order_id                         VARCHAR(50) NOT NULL,
    MODIFY customer_id                      VARCHAR(50),
    MODIFY order_status                     VARCHAR(20),
    MODIFY order_purchase_timestamp         DATETIME,
    MODIFY order_approved_at                DATETIME,
    MODIFY order_delivered_carrier_date     DATETIME,
    MODIFY order_delivered_customer_date    DATETIME,
    MODIFY order_estimated_delivery_date    DATETIME;

ALTER TABLE fact_reviews
    MODIFY review_creation_date     DATETIME,
    MODIFY review_answer_timestamp  DATETIME;


-- ── Step 5: Convert numeric columns ──────────────────────────

ALTER TABLE fact_order_items
    MODIFY price            DECIMAL(10,2),
    MODIFY freight_value    DECIMAL(10,2);

ALTER TABLE fact_payments
    MODIFY payment_value    DECIMAL(10,2);
