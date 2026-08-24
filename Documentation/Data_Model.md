# Data Model Documentation
## Olist Marketplace Performance Analysis

**Analyst:** Isaac | isaactheanalyst
**Tools:** MySQL · SQL Server · Power BI

---

## Overview

The Power BI semantic model follows a **Kimball-inspired star schema** design. The central fact table (`Fact Sales`) sits at the order-item grain and connects to four surrounding dimension tables plus a dedicated measures table.

This model was the result of identifying and resolving a **row multiplication problem** in the initial SQL model — where joining multiple payment records and review records directly to order items produced inflated row counts and incorrect metrics.

---

## Model Diagram

```
              Dim Customer
                   │
                   │  (many-to-one)
                   │
Dim Product ──── Fact Sales ──── Dim Seller
                   │
                   │  (many-to-one)
                   │
               Dim Date
```

Plus a hidden `_Measures` table containing all DAX measures.

---

## Tables

### Fact Sales

**Grain:** One row per product item within one order (order-item level)

| Field | Type | Description |
|---|---|---|
| order_id | Text | Order identifier |
| order_item_id | Integer | Line item number within order |
| customer_id | Text | Foreign key → Dim Customer |
| product_id | Text | Foreign key → Dim Product |
| seller_id | Text | Foreign key → Dim Seller |
| order_date | Date | Order purchase date (links to Dim Date) |
| order_status | Text | Order status |
| order_approved_at | DateTime | Approval timestamp |
| order_delivered_carrier_date | DateTime | Carrier handover date |
| order_delivered_customer_date | DateTime | Customer delivery date |
| order_estimated_delivery_date | DateTime | Estimated delivery date |
| delivery_days | Integer | Calculated: delivered − purchased |
| price | Decimal | Product price |
| freight_value | Decimal | Freight cost |
| total_sale_amount | Decimal | price + freight_value |
| total_payment_value | Decimal | Aggregated from payment summary |
| payment_installments | Integer | Max installments for order |
| payment_type | Text | Dominant payment method |
| review_score | Decimal | Averaged review score per order |

---

### Dim Customer

| Field | Type | Description |
|---|---|---|
| Customer Name | Text | Calculated label for display |
| customer_id | Text | Primary key |
| customer_city | Text | Customer city |
| customer_state | Text | Brazilian state abbreviation |

---

### Dim Product

| Field | Type | Description |
|---|---|---|
| product_id | Text | Primary key |
| product_category_name_english | Text | English category name |

---

### Dim Seller

| Field | Type | Description |
|---|---|---|
| Seller Name | Text | Calculated label for display |
| seller_id | Text | Primary key |
| seller_city | Text | Seller city |
| seller_state | Text | Brazilian state abbreviation |

---

### Dim Date

Created in Power BI using DAX. Supports time intelligence across the full order date range.

| Field | Type | Description |
|---|---|---|
| Date | Date | Primary key — full date |
| Month | Text | Month name |
| Month Number | Integer | Numeric month (for sorting) |
| Month Short | Text | Three-letter month abbreviation |
| Month-Year | Text | Display label e.g. "Jan 2017" |

---

### _Measures

A hidden table used to organise all DAX measures. Hidden from report view — measures only.

---

## Relationships

| From | To | Cardinality | Direction |
|---|---|---|---|
| Fact Sales [customer_id] | Dim Customer [customer_id] | Many-to-One | Single |
| Fact Sales [product_id] | Dim Product [product_id] | Many-to-One | Single |
| Fact Sales [seller_id] | Dim Seller [seller_id] | Many-to-One | Single |
| Fact Sales [order_date] | Dim Date [Date] | Many-to-One | Single |

---

## Why This Model Design

### The Row Multiplication Problem

The Olist dataset contains multiple one-to-many relationships around a single order:

```
One Order
  ├── Multiple Order Items   (fact_order_items)
  ├── Multiple Payment Records (fact_payments)
  └── Multiple Review Records  (fact_reviews)
```

Joining these tables directly without pre-aggregation produces:

```
3 items × 2 payments × 2 reviews = 12 rows (instead of 3)
```

This inflates every additive measure — revenue, freight, order counts.

### The Fix

Payments and reviews were aggregated to order level in SQL **before** joining to the fact table:

```sql
-- Payment summary: 1 row per order
SELECT order_id, SUM(payment_value), MAX(payment_type), ...
FROM fact_payments GROUP BY order_id;

-- Review summary: 1 row per order
SELECT order_id, AVG(review_score)
FROM fact_reviews GROUP BY order_id;
```

The final fact view then joins these summaries — not the raw tables — ensuring the order-item grain is preserved.

### Validation Results

| Metric | Value |
|---|---:|
| Fact rows | ~112,650 |
| Distinct orders | ~98,666 |
| Distinct products | ~32,951 |
| Distinct sellers | 3,095 |
| Distinct customers | 99,441 |
