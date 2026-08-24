-- ============================================================
-- Script: 07_final_fact_and_dimensions.sql
-- Project: Olist Marketplace Performance Analysis
-- Analyst: isaactheanalyst
-- Description: Final analytical views — fact sales and
--              dimension views consumed by Power BI.
--              Follows Kimball-inspired star schema design.
--
-- Model grain: One row per product item within one order
--              (order-item level)
--
-- Architecture:
--              Dim Customer
--                   │
--   Dim Product ── Fact Sales ── Dim Seller
--                   │
--               Dim Date (created in Power BI)
-- ============================================================

USE olist_customer_sales;


-- ── Final Fact Sales View ─────────────────────────────────────

CREATE OR REPLACE VIEW vw_fact_sales AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
    )                               AS delivery_days,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value     AS total_sale_amount,
    p.total_payment_value,
    p.payment_count,
    p.payment_installments,
    p.payment_type,
    r.review_score
FROM fact_order_items oi
LEFT JOIN fact_orders o
    ON oi.order_id = o.order_id
LEFT JOIN vw_payment_summary p
    ON oi.order_id = p.order_id
LEFT JOIN vw_review_summary r
    ON oi.order_id = r.order_id;

-- Validation
SELECT COUNT(*)                 AS fact_rows        FROM vw_fact_sales;
SELECT COUNT(DISTINCT order_id) AS distinct_orders  FROM vw_fact_sales;
SELECT COUNT(DISTINCT product_id) AS distinct_products FROM vw_fact_sales;
SELECT COUNT(DISTINCT seller_id)  AS distinct_sellers  FROM vw_fact_sales;
SELECT COUNT(DISTINCT customer_id) AS distinct_customers FROM vw_fact_sales;


-- ── Dim Customer View ─────────────────────────────────────────

CREATE OR REPLACE VIEW vw_dim_customer AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM dim_customer;


-- ── Dim Product View ──────────────────────────────────────────

CREATE OR REPLACE VIEW vw_dim_product AS
SELECT DISTINCT
    p.product_id,
    p.product_category_name,
    dc.product_category_name_english,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM dim_product p
LEFT JOIN dim_category dc
    ON p.product_category_name = dc.product_category_name;


-- ── Dim Seller View ───────────────────────────────────────────

CREATE OR REPLACE VIEW vw_dim_seller AS
SELECT DISTINCT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM dim_seller;
