-- ============================================================
-- Script: 04_data_validation.sql
-- Project: Olist Marketplace Performance Analysis
-- Analyst: isaactheanalyst
-- Description: Data quality validation — uniqueness, nulls,
--              duplicates, and referential integrity checks
--              performed before adding keys and constraints.
-- ============================================================

USE olist_customer_sales;


-- ── 1. Row counts ────────────────────────────────────────────
SELECT COUNT(*) AS customer_rows     FROM dim_customer;      -- 99,441
SELECT COUNT(*) AS product_rows      FROM dim_product;       -- 32,340
SELECT COUNT(*) AS seller_rows       FROM dim_seller;        -- 3,095
SELECT COUNT(*) AS review_rows       FROM fact_reviews;      -- 98,409
SELECT COUNT(*) AS geolocation_rows  FROM dim_geolocation;   -- 1,000,163


-- ── 2. Primary key uniqueness checks ─────────────────────────

-- Customers
SELECT
    COUNT(*)                    AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM dim_customer;
-- Pass: both values equal 99,441

-- Products
SELECT
    COUNT(*)                   AS total_rows,
    COUNT(DISTINCT product_id) AS unique_products
FROM dim_product;
-- Pass: both values equal 32,340

-- Sellers
SELECT
    COUNT(*)                  AS total_rows,
    COUNT(DISTINCT seller_id) AS unique_sellers
FROM dim_seller;
-- Pass: both values equal 3,095


-- ── 3. Null checks on key fields ─────────────────────────────

SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id
FROM dim_customer;

SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id
FROM dim_product;

SELECT
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id
FROM dim_seller;

SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id
FROM fact_orders;


-- ── 4. Duplicate checks ──────────────────────────────────────

-- Duplicate orders
SELECT order_id, COUNT(*) AS occurrences
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
-- Pass: empty result set

-- Duplicate payments (same order + sequence)
SELECT order_id, payment_sequential, COUNT(*) AS occurrences
FROM fact_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;
-- Pass: empty result set


-- ── 5. Referential integrity checks ─────────────────────────
-- Run BEFORE adding foreign keys

-- Order items → Products (missing products)
SELECT COUNT(*) AS missing_products
FROM fact_order_items foi
LEFT JOIN dim_product dp ON foi.product_id = dp.product_id
WHERE dp.product_id IS NULL;

-- Order items → Sellers (missing sellers)
SELECT COUNT(*) AS missing_sellers
FROM fact_order_items foi
LEFT JOIN dim_seller ds ON foi.seller_id = ds.seller_id
WHERE ds.seller_id IS NULL;

-- Orders → Customers (missing customers)
SELECT COUNT(*) AS missing_customers
FROM fact_orders fo
LEFT JOIN dim_customer dc ON fo.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;
-- Pass: 0

-- Reviews → Orders (orphan reviews)
SELECT COUNT(*) AS missing_orders
FROM fact_reviews fr
LEFT JOIN fact_orders fo ON fr.order_id = fo.order_id
WHERE fo.order_id IS NULL;
-- Pass: 0

-- Payments → Orders (orphan payments)
SELECT COUNT(*) AS missing_orders
FROM fact_payments fp
LEFT JOIN fact_orders fo ON fp.order_id = fo.order_id
WHERE fo.order_id IS NULL;
-- Pass: 0


-- ── 6. Sample individual product check ──────────────────────
-- Used to investigate missing product referential integrity

SELECT * FROM dim_product
WHERE product_id = 'ff6caf9340512b8bf6d2a2a6df032cfa';

SELECT * FROM dim_product
WHERE product_id = 'a9c404971d1a5b1cbc2e4070e02731fd';


-- ── 7. Review date validation ────────────────────────────────
-- Check for any remaining invalid dates after cleaning

SELECT COUNT(*) AS invalid_dates
FROM fact_reviews
WHERE review_creation_date = '0000-00-00 00:00:00'
   OR review_answer_timestamp = '0000-00-00 00:00:00';
-- Pass: 0

-- Latest review date
SELECT MAX(review_creation_date) AS latest_review
FROM fact_reviews;
-- Expected: 2018-08-31
