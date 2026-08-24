-- ============================================================
-- Script: 06_payment_review_aggregation.sql
-- Project: Olist Marketplace Performance Analysis
-- Analyst: isaactheanalyst
-- Description: Aggregates payments and reviews to order level
--              before joining to the fact table. This prevents
--              row multiplication caused by multiple payment
--              records or review records per order.
--
-- Problem identified:
--   One order can have multiple payment records AND multiple
--   review records. Joining them directly to fact_order_items
--   multiplies rows:
--   3 items × 2 payments × 2 reviews = 12 rows (not 3)
--   This inflates revenue, freight, and order counts.
--
-- Solution:
--   Aggregate to 1 row per order BEFORE joining to fact.
-- ============================================================

USE olist_customer_sales;


-- ── Payment Summary — 1 row per order ────────────────────────

CREATE OR REPLACE VIEW vw_payment_summary AS
SELECT
    order_id,
    SUM(payment_value)          AS total_payment_value,
    COUNT(*)                    AS payment_count,
    MAX(payment_installments)   AS payment_installments,
    MAX(payment_type)           AS payment_type
FROM fact_payments
GROUP BY order_id;

-- Validation: row count should match distinct orders in fact_payments
SELECT COUNT(*) AS payment_summary_rows FROM vw_payment_summary;


-- ── Review Summary — 1 row per order ─────────────────────────

CREATE OR REPLACE VIEW vw_review_summary AS
SELECT
    order_id,
    AVG(review_score) AS review_score
FROM fact_reviews
GROUP BY order_id;

-- Validation: row count should match distinct orders in fact_reviews
SELECT COUNT(*) AS review_summary_rows FROM vw_review_summary;
