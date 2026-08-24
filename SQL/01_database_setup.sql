-- ============================================================
-- Script: 01_database_setup.sql
-- Project: Olist Marketplace Performance Analysis
-- Analyst: isaactheanalyst
-- Description: Database creation and initial table structure
--              for the Olist e-commerce analytical database.
-- ============================================================


-- ── Create and select the database ──────────────────────────
CREATE DATABASE olist_customer_sales;

USE olist_customer_sales;


-- ── Dimension Tables ─────────────────────────────────────────

CREATE TABLE dim_customer (
    customer_id             TEXT,
    customer_unique_id      TEXT,
    customer_zip_code_prefix TEXT,
    customer_city           TEXT,
    customer_state          TEXT
);

CREATE TABLE dim_product (
    product_id                  TEXT,
    product_category_name       TEXT,
    product_name_length         INT,
    product_description_length  INT,
    product_photos_qty          INT,
    product_weight_g            DECIMAL(10,2),
    product_length_cm           DECIMAL(10,2),
    product_height_cm           DECIMAL(10,2),
    product_width_cm            DECIMAL(10,2)
);

CREATE TABLE dim_category (
    product_category_name         TEXT,
    product_category_name_english TEXT
);

CREATE TABLE dim_seller (
    seller_id               TEXT,
    seller_zip_code_prefix  TEXT,
    seller_city             TEXT,
    seller_state            TEXT
);

CREATE TABLE dim_geolocation (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat             DECIMAL(18,15),
    geolocation_lng             DECIMAL(18,15),
    geolocation_city            TEXT,
    geolocation_state           TEXT
);


-- ── Fact Tables ───────────────────────────────────────────────

CREATE TABLE fact_orders (
    order_id                        TEXT,
    customer_id                     TEXT,
    order_status                    TEXT,
    order_purchase_timestamp        TEXT,
    order_approved_at               TEXT,
    order_delivered_carrier_date    TEXT,
    order_delivered_customer_date   TEXT,
    order_estimated_delivery_date   TEXT
);

CREATE TABLE fact_order_items (
    order_id            TEXT,
    order_item_id       INT,
    product_id          TEXT,
    seller_id           TEXT,
    shipping_limit_date TEXT,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2)
);

CREATE TABLE fact_payments (
    order_id                TEXT,
    payment_sequential      INT,
    payment_type            TEXT,
    payment_installments    INT,
    payment_value           DECIMAL(10,2)
);

CREATE TABLE fact_reviews (
    review_id               TEXT,
    order_id                TEXT,
    review_score            INT,
    review_creation_date    TEXT,
    review_answer_timestamp TEXT
);
