-- ============================================================
-- Script: 05_keys_constraints_indexes.sql
-- Project: Olist Marketplace Performance Analysis
-- Analyst: isaactheanalyst
-- Description: Primary keys, foreign keys, and indexes added
--              after data validation confirms referential
--              integrity. Indexes target join and filter columns.
-- ============================================================

USE olist_customer_sales;


-- ── Primary Keys ─────────────────────────────────────────────

ALTER TABLE dim_customer
    ADD PRIMARY KEY (customer_id);

ALTER TABLE dim_product
    ADD PRIMARY KEY (product_id);

ALTER TABLE dim_category
    ADD PRIMARY KEY (product_category_name);

ALTER TABLE dim_seller
    ADD PRIMARY KEY (seller_id);

ALTER TABLE fact_orders
    ADD PRIMARY KEY (order_id);


-- ── Foreign Keys ─────────────────────────────────────────────

-- Orders → Customers
ALTER TABLE fact_orders
    ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id)
    REFERENCES dim_customer (customer_id);

-- Order Items → Products
ALTER TABLE fact_order_items
    ADD CONSTRAINT fk_items_product
    FOREIGN KEY (product_id)
    REFERENCES dim_product (product_id);

-- Order Items → Sellers
ALTER TABLE fact_order_items
    ADD CONSTRAINT fk_items_seller
    FOREIGN KEY (seller_id)
    REFERENCES dim_seller (seller_id);

-- Products → Categories
ALTER TABLE dim_product
    ADD CONSTRAINT fk_product_category
    FOREIGN KEY (product_category_name)
    REFERENCES dim_category (product_category_name);

-- Reviews → Orders
ALTER TABLE fact_reviews
    ADD CONSTRAINT fk_reviews_orders
    FOREIGN KEY (order_id)
    REFERENCES fact_orders (order_id);

-- Payments → Orders
ALTER TABLE fact_payments
    ADD CONSTRAINT fk_payments_orders
    FOREIGN KEY (order_id)
    REFERENCES fact_orders (order_id);


-- ── Indexes ───────────────────────────────────────────────────
-- Targets foreign key and frequently filtered columns

CREATE INDEX idx_orders_customer_id
    ON fact_orders (customer_id);

CREATE INDEX idx_items_product_id
    ON fact_order_items (product_id);

CREATE INDEX idx_items_seller_id
    ON fact_order_items (seller_id);

CREATE INDEX idx_items_order_id
    ON fact_order_items (order_id);

CREATE INDEX idx_payments_order_id
    ON fact_payments (order_id);

CREATE INDEX idx_reviews_order_id
    ON fact_reviews (order_id);

CREATE INDEX idx_product_category
    ON dim_product (product_category_name);
