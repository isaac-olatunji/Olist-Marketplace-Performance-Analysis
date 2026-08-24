# DAX Measures Documentation
## Olist Marketplace Performance Analysis

**Analyst:** Isaac | isaactheanalyst
**Tool:** Power BI Desktop

---

## Overview

All DAX measures are stored in a hidden `_Measures` table to keep the semantic model organised and prevent measures from being confused with columns. Measures are grouped below by analytical area.

---

## Revenue Measures

```dax
Total Revenue =
SUM('Fact Sales'[price])
```

```dax
Gross Sales =
SUM('Fact Sales'[total_sale_amount])
```

```dax
Total Freight =
SUM('Fact Sales'[freight_value])
```

```dax
Average Order Value =
DIVIDE(
    [Total Revenue],
    [Total Orders]
)
```

```dax
Revenue per Product =
DIVIDE(
    [Total Revenue],
    DISTINCTCOUNT('Fact Sales'[product_id])
)
```

```dax
Average Spend per Customer =
DIVIDE(
    [Total Revenue],
    DISTINCTCOUNT('Fact Sales'[customer_id])
)
```

```dax
Revenue YTD =
TOTALYTD(
    [Total Revenue],
    'Dim Date'[Date]
)
```

---

## Order & Volume Measures

```dax
Total Orders =
DISTINCTCOUNT('Fact Sales'[order_id])
```

```dax
Total Customers =
DISTINCTCOUNT('Fact Sales'[customer_id])
```

```dax
Products Sold =
DISTINCTCOUNT('Fact Sales'[product_id])
```

```dax
Total Categories =
DISTINCTCOUNT('Fact Sales'[product_category_name_english])
```

---

## Seller Measures

```dax
Seller Count =
DISTINCTCOUNT('Fact Sales'[seller_id])
```

```dax
Average Orders per Seller =
DIVIDE(
    [Total Orders],
    [Seller Count]
)
```

```dax
Average Revenue per Seller =
DIVIDE(
    [Total Revenue],
    [Seller Count]
)
```

```dax
Average Freight per Seller =
DIVIDE(
    [Total Freight],
    [Seller Count]
)
```

```dax
Highest Seller Revenue =
MAXX(
    VALUES('Dim Seller'[seller_id]),
    CALCULATE([Total Revenue])
)
```

```dax
Lowest Seller Revenue =
MINX(
    VALUES('Dim Seller'[seller_id]),
    CALCULATE([Total Revenue])
)
```

---

## Delivery Measures

```dax
Average Delivery Days =
AVERAGE('Fact Sales'[delivery_days])
```

---

## Review & Satisfaction Measures

```dax
Total Reviews =
CALCULATE(
    COUNTROWS('Fact Sales'),
    NOT ISBLANK('Fact Sales'[review_score])
)
```

```dax
Average Review Score =
AVERAGE('Fact Sales'[review_score])
```

```dax
Five Star Reviews =
CALCULATE(
    [Total Reviews],
    'Fact Sales'[review_score] = 5
)
```

```dax
One Star Reviews =
CALCULATE(
    [Total Reviews],
    'Fact Sales'[review_score] = 1
)
```

```dax
Five Star Review Rate =
DIVIDE(
    [Five Star Reviews],
    [Total Reviews]
)
```

---

## Notes

- `DIVIDE()` is used instead of `/` throughout to handle division-by-zero gracefully — it returns BLANK() rather than an error when the denominator is zero.
- `DISTINCTCOUNT()` is used for orders, customers, products, and sellers to correctly count unique entities rather than row counts.
- `TOTALYTD()` uses the Dim Date table to calculate year-to-date revenue correctly with time intelligence.
- The `_Measures` table is marked as hidden in the model so it does not appear in report field lists — measures are accessed directly from the Fields pane.
