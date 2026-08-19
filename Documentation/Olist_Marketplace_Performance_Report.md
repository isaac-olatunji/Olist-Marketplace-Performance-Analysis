# Olist Marketplace Performance Analysis
## Full Analysis Report

**Analyst:** Isaac | isaactheanalyst
**Tools:** MySQL · SQL Server · Power BI · Power Query · DAX
**Dataset:** Brazilian E-Commerce Public Dataset by Olist — 1.5M+ records
**Period:** September 2016 – September 2018

---

## Executive Summary

This report documents the complete analytical journey from raw CSV files to an interactive five-page Power BI dashboard for the Olist Brazilian e-commerce marketplace.

The project was not designed as a dashboard build. It was designed as a business intelligence solution — one that begins with data engineering, progresses through dimensional modelling, and delivers analytical insights through a validated Power BI semantic model.

**Commercial performance:** The marketplace generated $13.59M in revenue across 99K orders between September 2016 and September 2018, with consistent year-on-year growth. Revenue grew from near-zero in late 2016 to $7.4M by end of 2018.

**Operational performance:** Average delivery time is 12.41 days. Average review score is 4/5, with 56.55% five-star reviews — but 14K one-star reviews (12.6%) represent a meaningful dissatisfaction signal that requires investigation.

**Core finding:** The marketplace is growing commercially, but delivery speed and one-star review concentration are the primary operational risks to customer retention and long-term revenue performance.

---

## Project Journey

### Why the Project Started with MySQL

The standard approach for a Power BI project is to import data directly and transform it through Power Query. This project deliberately avoided that approach.

The Olist dataset contains nine interconnected CSV files representing different business entities operating at different levels of granularity. Loading them into Power BI without first understanding the relational structure and grain would have produced an unreliable analytical model.

MySQL was used as the first layer to:
- Understand the relational structure before visualisation
- Clean and validate the data systematically
- Identify and resolve grain issues before they became dashboard problems
- Build reusable analytical views that could be consumed by any BI tool

### The Dataset Pivot

The project originally began as a Sales & Customer Analytics project using the Sample Superstore dataset. During early development, problems with the original dataset source required a rethink.

Rather than forcing the project to continue with a problematic foundation, alternative datasets were evaluated and Olist was selected. The decision was deliberate and analytical — Olist offered a far richer relational structure that better represented the complexity of real-world BI work.

This pivot expanded the project from a relatively simple sales analysis into a complete data engineering → SQL analytics → BI workflow. The progression was:

```
Sample Superstore → Dataset Problems → Evaluation → Olist Selected
→ Multi-table Relational Design → Full BI Pipeline
```

### The Star Schema Problem

The most critical technical challenge in this project was a row multiplication problem in the initial data model.

The Olist dataset contains multiple one-to-many relationships around a single order. One order can have multiple order items, multiple payment records, and multiple review records. If these tables are joined directly without aggregation:

```
3 order items × 2 payment records × 2 reviews = 12 rows (instead of 3)
```

This would inflate every additive measure — revenue, freight, order counts — producing analytically incorrect results that would look correct on the surface.

The fix required identifying the correct grain of the fact table (order-item level) and aggregating payments and reviews to order level before joining:

```
Payment Records → Payment Summary per Order → Fact Sales
Review Records  → Review Summary per Order  → Fact Sales
```

This is a fundamental dimensional modelling principle — one that is easy to miss and consequential when missed. Identifying it, understanding it, and fixing it correctly is one of the most important demonstrations in this project.

---

## Data Engineering

### Database Setup

```sql
CREATE DATABASE olist_customer_sales;
USE olist_customer_sales;
```

### Table Architecture

**Dimension Tables:** `dim_customer`, `dim_product`, `dim_category`, `dim_seller`, `dim_geolocation`

**Fact Tables:** `fact_orders`, `fact_order_items`, `fact_payments`, `fact_reviews`

### Import Challenges Resolved

**LOAD DATA LOCAL INFILE restriction** — resolved by enabling `OPT_LOCAL_INFILE=1` in MySQL Workbench connection settings.

**Geolocation zero rows** — resolved by correcting line endings from `\n` to `\r\n`. Final import: 1,000,163 records.

**Invalid zero dates** — `0000-00-00 00:00:00` values in review dates cleaned before DATETIME conversion.

**Empty strings in DATETIME columns** — order delivery columns contained empty strings that prevented schema modification. Cleaned before column type conversion.

**BLOB/TEXT primary key error** — ID columns initially imported as TEXT. Converted to `VARCHAR(50)` before primary keys could be added.

**Incorrect schema context** — `Error 1146: Table 'sys.fact_reviews' doesn't exist` resolved by executing `USE olist_customer_sales` before table operations.

### Data Validation Results

| Check | Result |
|---|---|
| Customer ID uniqueness | 99,441 rows / 99,441 unique ✅ |
| Product ID uniqueness | 32,340 rows / 32,340 unique ✅ |
| Seller ID uniqueness | 3,095 rows / 3,095 unique ✅ |
| Null values in key fields | 0 unexpected nulls ✅ |
| Duplicate orders | 0 duplicates found ✅ |
| Duplicate payments | 0 duplicates found ✅ |
| Missing customers in orders | 0 ✅ |
| Missing products in order items | Resolved after dimension reload ✅ |
| Missing sellers in order items | Resolved after seller validation ✅ |

### Star Schema — Final Design

```
              Dim Customer
                   │
Dim Product ── Fact Sales ── Dim Seller
                   │
               Dim Date (Power BI)
```

**Fact table grain:** One row per product item within one order.

---

## Reporting Views

### vw_fact_sales (Final)
Combines order-item transactions with aggregated payment and review summaries. Includes delivery days as a calculated field. Serves as the primary fact source for all five dashboard pages.

### vw_payment_summary
```sql
SELECT order_id,
    SUM(payment_value) AS total_payment_value,
    COUNT(*) AS payment_count,
    MAX(payment_installments) AS payment_installments,
    MAX(payment_type) AS payment_type
FROM olist_order_payments_dataset
GROUP BY order_id;
```

### vw_review_summary
```sql
SELECT order_id,
    AVG(review_score) AS review_score
FROM olist_order_reviews_dataset
GROUP BY order_id;
```

### Model Validation
| Metric | Result |
|---|---|
| Fact rows | ~112,650 |
| Distinct orders | ~98,666 |
| Distinct products | ~32,951 |
| Distinct sellers | 3,095 |
| Distinct customers | 99,441 |

---

## Page 1: Executive Summary

![Executive Summary](Assets/screenshots/executive-summary/executive-summary-overview.png)

### KPI Cards

[!KPI Cards](../Assets/screenshots/executive-summary/KPI-cards.png)

| Metric | Value |
|---|---:|
| Total Revenue | $13.59M |
| Total Orders | 99K |
| Total Customers | 99K |
| Average Order Value | $137.75 |
| Average Review Score | 4 |
| Average Delivery Days | 12.41 |

**Insight:** The six KPIs on the executive page are deliberately chosen to span all five analytical dimensions — revenue (commercial), orders and customers (volume), AOV (efficiency), review score (experience), and delivery days (operations). A recruiter or business user sees the full performance picture in one row before engaging with any chart.

---

### Revenue Trend Over Time

![Revenue Trend Over Time](Assets/screenshots/executive-summary/revenue-trend-over-time.png)

**Insight:** Revenue grew from near-zero in September 2016 to $6.2M through 2017, reaching $7.4M by end of 2018. The trajectory is consistently upward with no reversal — indicating genuine marketplace growth rather than a seasonal spike. The 2016 data represents only a partial year (September–December), which explains the near-zero starting point.

---

### Revenue by Product Category

[!Revenue by Product Category](../Assets/screenshots/executive-summary/revenue-by-product-category.png)

| Category | Revenue |
|---|---:|
| health_beauty | $1.26M |
| watches_gifts | $1.21M |
| bed_bath_table | $1.04M |
| sports_leisure | $0.99M |
| computers_accessories | $0.91M |
| furniture_decor | $0.73M |
| cool_stuff | $0.64M |

**Insight:** health_beauty and watches_gifts are tightly clustered at the top ($1.26M and $1.21M respectively), suggesting neither has a dominant lead — both are critical categories. The gap between the top two and the rest is meaningful; computers_accessories ($0.91M) trails by $300K+ despite likely having higher per-unit values. This points to lower order volume in high-value categories — a growth opportunity.

---

### Revenue by State

![Revenue by State](Assets/screenshots/executive-summary/revenue-by-state.png)

**Insight:** Revenue is concentrated in a small number of states. The map shows only a handful of highlighted states, confirming that the majority of Brazilian states contribute minimally to marketplace revenue. Geographic expansion into underserved states represents a significant growth lever for Olist.

---

### Reviews & Customer Satisfaction

[!Reviews & Customer Satisfaction](../Assets/screenshots/executive-summary/reviews-and-customer_satisfaction.png)

| Review Score | Reviews |
|---:|---:|
| 1 | 14K |
| 2 | 4K |
| 3 | 9K |
| 4 | 21K |
| 5 | 63K |

**Insight:** The distribution is strongly bimodal — 63K five-star reviews (56.55%) and 14K one-star reviews (12.6%). The middle scores (2, 3) are notably sparse. This polarisation suggests customers either have a great experience or a genuinely poor one, with few landing in the middle. The 14K one-star reviews are the most important signal on this page — they require root cause analysis across delivery, product quality, and seller performance dimensions available in subsequent pages.

---

## Page 2: Sales Performance

![Sales Performance](Assets/screenshots/sales-performance/sales-performance-overview.png)

### KPI Cards

[!Sales KPI Cards](../Assets/screenshots/sales-performance/KPI-cards.png)

| Metric | Value |
|---|---:|
| Total Revenue | $13.59M |
| Gross Sales | $15.84M |
| Total Orders | 99K |
| Average Order Value | $137.75 |
| Total Freight | $2.25M |
| Revenue YTD | 7.39M |

**Insight:** The gap between Gross Sales ($15.84M) and Total Revenue ($13.59M) is $2.25M — exactly equal to Total Freight. This confirms that the revenue metric represents product sales value net of freight, while gross sales includes freight. Both metrics are meaningful: Gross Sales measures total marketplace transaction value; Revenue measures product-only contribution.

---

### Sales Trend Over Time

[!Sales Trend Over Time](../Assets/screenshots/sales-performance/sales-trend-over-time.png)

**Insight:** Gross sales reached $7.1M through 2017 and $8.6M by end of 2018. The sales trajectory mirrors the revenue trend — consistent growth with no reversal. The 2017 inflection point shows the marketplace scaling meaningfully, suggesting successful seller acquisition or customer acquisition activities in 2016–2017.

---

### Revenue by Payment Type

[!Revenue by Payment Type](../Assets/screenshots/sales-performance/revenue-by-payment-type.png)

**Insight:** Revenue grew month-on-month from late 2016 through 2018, with both Total Revenue and Gross Sales tracking together. The chart confirms no single month experienced a significant reversal. The end of 2017 shows peak monthly revenue, which then stabilises into 2018 — potentially indicating market maturation or seasonal patterns.

---

### Revenue by Payment Installments

[!Revenue by Payment Installments](../Assets/screenshots/sales-performance/revenue-by-payment-installments.png)

| Installments | Revenue |
|---:|---:|
| 1 | $4.8M |
| 10 | $2.0M |
| 8 | $1.2M |
| 6 | $0.3M |

**Insight:** Single-instalment purchases dominate at $4.8M — customers who can pay in full do so. The spike at 10 instalments ($2.0M) is striking — this is the second-largest group by a significant margin, suggesting that 10 is either a platform default for high-value purchases or a psychologically preferred instalment number. Understanding what product categories drive the 10-instalment spike would reveal whether this is structural or category-specific.

---

### Total Orders by Year

[!Total Orders by Year](../Assets/screenshots/sales-performance/total-orders-by-year.png)

| Year | Orders |
|---|---:|
| 2016 | Near 0K (partial year) |
| 2017 | 45K |
| 2018 | 54K |

**Insight:** Orders grew from 45K in 2017 to 54K in 2018 — a 20% increase in order volume. Combined with the revenue growth, this confirms the marketplace is expanding both in transaction count and in average value.

---

## Page 3: Product & Customer Insights

![Product & Customer Insights](Assets/screenshots/product-and-customer-insight/product-and-customer-insight-overview.png)

### KPI Cards

[!Product KPI Cards](../Assets/screenshots/product-and-customer-insight/KPI-cards.png)

| Metric | Value |
|---|---:|
| Products Sold | 33K |
| Total Categories | 73 |
| Customer Count | 99K |
| Revenue per Product | $412.48 |
| Average Spend per Customer | $137.75 |

**Insight:** 73 categories producing $412.48 revenue per product sold across 33K products reveals a broad but relatively shallow catalogue. The average spend per customer ($137.75) matching the AOV indicates most customers make a single purchase — a significant retention and repeat-purchase opportunity.

---

### Top 10 Products by Revenue

[!Top 10 Products by Revenue](../Assets/screenshots/product-and-customer-insight/top-10-products-by-revenue.png)

| Category | Revenue |
|---|---:|
| health_beauty | $1.26M |
| watches_gifts | $1.21M |
| bed_bath_table | $1.04M |
| sports_leisure | $0.99M |
| computers_accessories | $0.91M |
| furniture_decor | $0.73M |
| cool_stuff | $0.64M |

**Insight:** The top revenue categories by product align with the executive summary. The consistency between pages confirms model integrity — the same data is being measured the same way across different aggregations.

---

### Product Category by Total Orders

[!Product Category by Total Orders](../Assets/screenshots/product-and-customer-insight/product-category-by-total-roders.png)

**Insight:** The scatter plot of Total Orders vs Total Revenue reveals that health_beauty and watches_gifts achieve both high order volume (8K–9K orders) and high revenue ($1M+). computers_accessories achieves comparable revenue despite fewer orders — confirming its high per-unit value. The cluster of lower-left categories represents small-volume, low-revenue lines that may benefit from consolidation or deprioritisation.

---

### Product Category by Average Order Value

[!Product Category by Average Order Value](../Assets/screenshots/product-and-customer-insight/product-category-by-avergae-order-value.png)

| Category | AOV |
|---|---:|
| computers | $1,231.84 |
| small_appliances_home_oven_and_coffee | $632.61 |
| home_appliances_2 | $484.26 |
| agro_industry_and_commerce | $398.52 |
| musical_instruments | $304.93 |
| small_appliances | $302.62 |

**Insight:** Computers have an AOV of $1,231.84 — nearly double the next category. Despite this, computers does not appear in the top revenue categories, confirming that order volume is low. A targeted effort to increase computer order volume — through marketing, seller acquisition, or pricing — could dramatically improve total revenue given the AOV premium.

---

### Customer State by Average Spend per Customer

[!Customer State by Average Spend per Customer](../Assets/screenshots/product-and-customer-insight/customer-state-by-average-spend-per-customer.png)

**Insight:** The map shows only a handful of highlighted states for average spend per customer — Montana (MT) and Pennsylvania (PA) appear as top spenders, which is geographically interesting for a Brazilian dataset. This likely reflects state abbreviation mapping issues where Brazilian state codes (e.g. MT = Mato Grosso, PA = Pará) have been rendered on a US map. This is a data mapping issue to investigate and correct in the Power BI geographic layer.

---

## Page 4: Seller Performance

![Seller Performance](Assets/screenshots/seller-performance/seller-performance-overview.png)

### KPI Cards

[!Seller KPI Cards](../Assets/screenshots/seller-performance/KPI-card.png)

| Metric | Value |
|---|---:|
| Seller Count | 3K |
| Average Orders per Seller | 31.88 |
| Average Revenue per Seller | $4.39K |
| Average Freight per Seller | $727.60 |
| Highest Seller Revenue | $229.47K |
| Lowest Seller Revenue | $3.50 |

**Insight:** The gap between highest ($229.47K) and lowest ($3.50) seller revenue is extreme — a ratio of over 65,000:1. This is not a minor long-tail effect; it reflects a marketplace where revenue is heavily concentrated in a small number of top-performing sellers while the majority contribute almost nothing. The average of $4.39K per seller is dragged upward by the top performers and does not represent the typical seller experience. Understanding what drives top-seller performance is the key operational question this page is designed to answer.

---

### Top 10 Sellers by Revenue

[!Top 10 Sellers by Revenue](../Assets/screenshots/seller-performance/top-10-sellers-by-revenue.png)

| Seller | Revenue |
|---|---:|
| Seller 858 | $229K |
| Seller 1014 | $223K |
| Seller 882 | $200K |
| Seller 3025 | $194K |
| Seller 1536 | $188K |
| Seller 1561 | $176K |
| Seller 2644 | $160K |

**Insight:** The top 10 sellers are tightly clustered between $160K and $229K — a range of only $69K separating first from seventh. This competitive clustering suggests no single seller has achieved dominant market position; the top performers are operating at comparable scale. Seller 858 leads at $229K and Seller 1014 follows at $223K — a difference of just $6K. This competitive parity at the top makes the long tail even more striking: the majority of 3K sellers sit far below this range.

---

### Revenue by Seller State

![Revenue by Seller State](../Assets/screenshots/seller-performance/revenue-by-seller-state.png)

**Insight:** Seller revenue is geographically concentrated in a small number of Brazilian states. The map shows only a handful of highlighted states (rendered through the US map proxy), confirming that seller recruitment and revenue generation is not evenly distributed across Brazil. Expanding seller presence into underserved Brazilian states represents a direct growth lever — particularly if paired with logistics infrastructure that supports those regions.

---

### Seller State by Total Orders

[!Seller State by Total Orders](../Assets/screenshots/seller-performance/seller-state-by-total-orders.png)

**Insight:** The order concentration map mirrors the revenue concentration pattern — the same states that generate the most seller revenue also generate the most seller orders. This confirms that geographic concentration is structural rather than category-driven. Diversifying the seller base geographically would need to be paired with customer acquisition in those same regions to be effective.

---

### Seller Revenue Distribution

[!Seller Revenue Distribution](../Assets/screenshots/seller-performance/seller-revenue-distribution.png)

**Insight:** The scatter of Average Revenue per Seller (y-axis) vs Average Freight per Seller (x-axis), with bubble size representing order volume, reveals several important patterns. Seller 858 and Seller 1014 sit at the top of the revenue axis with moderate-to-high freight — consistent with selling high-value or bulky items in volume. Seller 1536 is a notable outlier: positioned furthest right on the freight axis ($50K+) while maintaining high revenue — suggesting a seller specialising in heavy, high-value goods with above-average logistics costs. The dense cluster near the origin ($0K–$10K freight, $0K revenue) represents the long tail of low-activity sellers. The scatter also confirms that revenue and freight are broadly correlated — sellers who generate more revenue tend to have higher freight costs, consistent with higher order volumes or heavier product categories.

---

## Page 5: Delivery & Customer Experience

![Delivery & Customer Experience](../Assets/screenshots/delivery-experience/delivery-and-customer-experience-overview.png)

### KPI Cards

[!Delivery KPI Cards](../Assets/screenshots/delivery-experience/KPI-cards.png)

| Metric | Value |
|---|---:|
| Average Delivery Days | 12.41 |
| Average Review Score | 4 |
| Total Reviews | 111K |
| Five-Star Reviews | 63K |
| Five-Star Review Rate | 56.55% |
| One-Star Reviews | 14K |

**Insight:** The juxtaposition of 56.55% five-star rate with 14K one-star reviews (12.6%) is the most important tension in the customer experience data. An average score of 4 masks a deeply bimodal distribution — most customers are satisfied, but a meaningful minority is not, and the gap between those two groups is wide. The delivery and category data on this page helps identify the structural drivers of that dissatisfaction.

---

### Average Delivery Days by Product Category

[!Average Delivery Days by Product Category](../Assets/screenshots/delivery-and-customer-experience/average-delivery-days-by-product-category.png)

| Category | Avg Delivery Days |
|---|---:|
| office_furniture | 20.8 |
| christmas_supplies | 15.7 |
| fashion_shoes | 15.4 |
| security_and_services | 15.0 |
| home_comfort_2 | 14.5 |
| furniture_mattress_and_... | 14.4 |
| home_appliances_2 | 13.9 |

**Insight:** office_furniture at 20.8 days is nearly 70% above the platform average of 12.41 days. The pattern across the top seven slowest categories is clear — large, bulky, or specialist items consistently take longer to deliver. furniture_mattress also appears in the list, reinforcing that size and weight are the primary logistics constraints rather than geographic factors. These categories need category-specific delivery SLAs and dedicated logistics partnerships rather than being managed under the same standard as lightweight consumer goods.

---

### Average Delivery Days by State

![Average Delivery Days by State](Assets/screenshots/delivery-experience/average-delivery-days-by-state.png)

**Insight:** The state delivery map shows significant geographic variation in delivery performance, with the darker (red/orange) states experiencing considerably longer average delivery times than lighter states. Some states appear to exceed 25 days average delivery — more than double the platform average. This geographic delivery disparity is a compounding factor: customers in slower-delivery states experience both longer waits and, as the Review Score Distribution shows, lower satisfaction scores as a direct result.

---

### Average Review Score by Product Category

[!Average Review Score by Product Category](../Assets/screenshots/delivery-and-experience/average-review-score-by-product-category.png)

| Category | Avg Review Score |
|---|---:|
| cds_dvds_musicals | 5 |
| fashion_childrens_clothes | 5 |
| books_general_interest | 4 |
| construction_tools_tools | 4 |
| flowers | 4 |
| books_imported | 4 |
| books_technical | 4 |

**Insight:** The highest-rated categories — cds_dvds_musicals and fashion_childrens_clothes — are lightweight, compact items that are straightforward to ship quickly and accurately. Their perfect 5-star averages confirm the delivery-satisfaction link: when delivery is fast and reliable, customers are satisfied. Books and flowers also score well, likely for similar reasons. Comparing this list against the slowest delivery categories reveals the pattern: no large-item category appears on the high-review list, and no fast-delivery category appears on the slow-delivery list.

---

### Review Score Distribution

[!Review Score Distribution](../Assets/screenshots/delivery-and-experience/review-score-distribution.png)

**Insight:** The scatter plot of Average Review Score (y-axis) vs Average Delivery Days (x-axis) with bubble size representing order volume is the most analytically significant visual on this page. SP (São Paulo) anchors the bottom-left — highest order volume, fastest delivery (~8 days), and among the better review scores (~4.1). As delivery days increase moving right across the x-axis, review scores trend downward. States reaching 25–30 average delivery days (MA, AL, RR, AP) cluster at review scores of 3.5 or below. This is not a perfect negative correlation — other factors (product quality, seller communication) also influence reviews — but the directional relationship is clear and visible. Reducing average delivery days in the slowest states would be expected to improve their review scores measurably.

---

## Dashboard Scenario Analysis

One of the most powerful features of the dashboard is its interactive slicer system — Date, Customer State, Product Category, Payment Type, and Review Score filters apply simultaneously across all visuals on each page. Two analytical scenarios were used to demonstrate the depth of insight the dashboard enables beyond the default all-data view.

---

### Scenario 1 — Problem Investigation: What Drives Dissatisfaction?

**Filters applied:** São Paulo · bed_bath_table · Credit Card · Review Score 1–2 · Jan 2017 – Jun 2018

**Question:** Are delivery delays associated with customer dissatisfaction in the bed_bath_table category in São Paulo?

[!Scenario 1 — Executive Summary](Assets/screenshots/scenarios/scenario1/scenario_1-executive-summary.png)

[!Scenario 1 — Delivery & Customer Experience](Assets/screenshots/scenarios/scenario1/delivery-and-customer-experience.png)

| Metric | Scenario 1 Value | Platform Default |
|---|---:|---:|
| Total Revenue | $329.35K | $13.59M |
| Total Orders | 3K | 99K |
| Average Delivery Days | 12.62 | 12.41 |
| Average Review Score | 1 | 4 |
| Five-Star Review Rate | 340.08%* | 56.55% |
| One-Star Reviews | 537 | 14K |

*The 340.08% five-star rate is a DAX calculation anomaly under this specific filter combination — where the filtered review subset produces a denominator mismatch. This is worth investigating and correcting in the DAX measure logic.

**What the scenario reveals:**

Filtering to review scores 1–2 in São Paulo's bed_bath_table category isolates the dissatisfied customer segment. Several findings emerge:

The average delivery time for this dissatisfied segment (12.62 days) is only marginally higher than the platform average (12.41 days). This is an important finding — it suggests that delivery speed alone does not fully explain dissatisfaction in this category and state. Other factors — product quality, seller communication, packaging, or unmet expectations — may be the primary drivers of one-star reviews in bed_bath_table.

The revenue trend under this filter (declining from $168.6K in 2017 to $160.8K in 2018) shows that the dissatisfied customer group is also a declining revenue cohort — consistent with churning customers rather than growing ones. This confirms that dissatisfaction in this segment carries a real commercial cost.

**Conclusion for Scenario 1:** Delivery delay is not the sole driver of dissatisfaction in bed_bath_table / São Paulo. A product quality or expectation management investigation is recommended alongside the delivery SLA review.

---

### Scenario 2 — Performance Investigation: What Does Strong Performance Look Like?

**Filters applied:** São Paulo · health_beauty · Credit Card · Review Score 4–5 · Jan 2016 – Jun 2018

**Question:** Does strong audience performance coincide with strong customer experience in the health_beauty category in São Paulo?

[!Scenario 2 — Executive Summary](Assets/screenshots/scenarios/scenario2/scenraio_2-executive-summary.png)

[!Scenario 2 — Delivery & Customer Experience](Assets/screenshots/scenarios/scenario2/delivery-and-customer-experience.png)

| Metric | Scenario 2 Value | Platform Default |
|---|---:|---:|
| Total Revenue | $298.90K | $13.59M |
| Total Orders | 2K | 99K |
| Average Delivery Days | 7.65 | 12.41 |
| Average Review Score | 5 | 4 |
| Five-Star Review Rate | 78.85% | 56.55% |
| One-Star Reviews | 332 | 14K |

**What the scenario reveals:**

The health_beauty / São Paulo / high-review segment tells the opposite story to Scenario 1. Average delivery days drop to 7.65 — nearly 40% faster than the platform average of 12.41 days. Review scores average 5 and the five-star rate reaches 78.85%, significantly above the platform average of 56.55%.

The revenue trend is strongly positive: growing from $1K in 2016 to $123K through 2017 and reaching $175K by end of 2018. This is not coincidental — satisfied customers in fast-delivery categories with high review scores are also the customers who continue buying and drive revenue growth.

The delivery performance for health_beauty in this scenario (7.65 days) is 4.76 days faster than the platform average. This is the clearest demonstration in the entire dashboard that delivery speed and customer satisfaction are structurally linked — and that the categories and states where both are strong are also where commercial performance is strongest.

**Conclusion for Scenario 2:** health_beauty in São Paulo with credit card payments represents a best-practice segment — fast delivery, high satisfaction, strong revenue growth. The combination of lightweight product, concentrated geography (São Paulo is the largest Brazilian state by population), and credit card payment reliability creates optimal conditions for marketplace performance. This segment should be studied and replicated where possible.

---

### Scenario Comparison Summary

| Dimension | Scenario 1 (Problem) | Scenario 2 (Performance) |
|---|---|---|
| Category | bed_bath_table | health_beauty |
| Review Filter | 1–2 (dissatisfied) | 4–5 (satisfied) |
| Avg Delivery Days | 12.62 | 7.65 |
| Avg Review Score | 1 | 5 |
| Revenue Trend | Declining | Strongly growing |
| Key Insight | Dissatisfaction not fully explained by delivery | Fast delivery + satisfaction = revenue growth |

**The scenarios together answer the central operational question:** delivery speed is a necessary but not sufficient condition for satisfaction. In Scenario 1, marginal delivery delays exist but are not the primary driver of dissatisfaction — product or expectation issues matter too. In Scenario 2, fast delivery is the foundation on which excellent customer experience and strong revenue growth are built. Both scenarios reinforce that delivery and satisfaction must be managed together, not treated as independent metrics.

---

| # | Finding |
|---|---|
| 1 | Total revenue of $13.59M across 99K orders (Sept 2016 – Sept 2018) with consistent year-on-year growth — no reversal observed |
| 2 | health_beauty ($1.26M) and watches_gifts ($1.21M) are the top revenue categories — closely matched, neither dominant |
| 3 | Computers have the highest AOV at $1,231.84 but low order volume — targeted growth here has high revenue leverage |
| 4 | Single-instalment purchases dominate ($4.8M) but 10-instalment orders spike at $2.0M — structural demand for longer payment terms |
| 5 | 56.55% five-star review rate but 14K one-star reviews (12.6%) — bimodal satisfaction pattern requiring root cause analysis |
| 6 | Average delivery time of 12.41 days; office_furniture at 20.8 days — large-item logistics are the primary delivery problem |
| 7 | Delivery speed is the primary driver of customer satisfaction — slow categories receive lower review scores consistently |
| 8 | Top seller ($229.47K) vs lowest seller ($3.50) — extreme revenue concentration; long tail contributes minimally |
| 9 | Revenue is geographically concentrated — most Brazilian states contribute minimal marketplace activity |
| 10 | Average spend per customer ($137.75) matches AOV — most customers appear to make single purchases, indicating low repeat rate |

---

## Recommendations

### 1. Investigate and Reduce One-Star Reviews
14K one-star reviews at 12.6% is the most urgent customer experience issue. Cross-reference one-star reviews with delivery days, seller performance, and product category to identify the primary drivers. Targeted interventions — seller quality thresholds, delivery speed standards — should follow.

### 2. Fix Large-Item Logistics
office_furniture at 20.8 average delivery days is 70% above the platform average. Partner with specialist logistics providers for large-item categories. Set delivery SLAs by category rather than applying a single platform standard.

### 3. Leverage the Computers AOV Opportunity
$1,231.84 AOV with low order volume means a small increase in computer orders has outsized revenue impact. Increase seller recruitment in the computers category and invest in targeted marketing to high-spend customer segments.

### 4. Expand Instalment Options
The 10-instalment spike ($2.0M) demonstrates structured demand for longer payment terms. Offering 12 or 15 instalment options for high-AOV categories could increase conversion and AOV simultaneously.

### 5. Drive Repeat Purchases
Average spend per customer matching AOV suggests single-purchase behaviour dominates. A loyalty programme, post-purchase email strategy, or targeted product recommendations would improve customer lifetime value.

### 6. Geographic Expansion
Revenue and seller activity concentrate in a small number of Brazilian states. Systematic seller recruitment in underserved states — combined with logistics capability — represents the largest single growth lever available to the marketplace.

### 7. Investigate the US Map Issue
The Customer State by Average Spend map is rendering Brazilian state codes on a US map. This should be corrected to a Brazil map to accurately represent geographic customer spend patterns.

---

## Data Engineering Lessons

| Lesson | Detail |
|---|---|
| Raw data is rarely analysis-ready | Empty strings, invalid dates, CSV line endings, referential integrity problems all required resolution before analysis |
| Schema selection matters | Wrong active database caused `Table 'sys.fact_reviews' doesn't exist` — always verify active schema |
| Grain matters more than completeness | Joining multiple one-to-many tables directly produces row multiplication — aggregating first is essential |
| Referential integrity before foreign keys | Foreign key constraints fail when child records reference missing parent records — validate orphans first |
| Star schema improves everything | Clear dimension/fact separation makes DAX simpler, Power BI faster, and analysis more reliable |
| Reporting views should have business purpose | Three subject-oriented views (sales, orders, reviews) are more maintainable than one enormous flat table |
| The connector problem is not the project | MySQL → Power BI connector failure was resolved by CSV export — the SQL work retains full value regardless of connection method |

---

## Conclusion

The Olist Marketplace Performance Analysis demonstrates what a complete Business Intelligence workflow looks like in practice.

The project began with nine raw CSV files and ended with a validated five-page interactive dashboard. Between those two points: a database was built, data was cleaned and validated, a grain problem was identified and fixed, a star schema was implemented, reporting views were created, a semantic model was built in Power BI, and DAX measures were developed to convert transactional data into business KPIs.

The commercial story is positive — $13.59M in revenue, consistent growth, strong review scores for most customers. The operational story requires attention — 12.41 average delivery days, a bimodal review distribution, and an extreme seller performance gap all represent opportunities that the data makes clearly visible.

The most important technical finding — the row multiplication problem and its resolution through payment and review aggregation — is also the most transferable skill this project demonstrates. Identifying that a model can look correct while producing incorrect results, and knowing how to fix it, is what separates a data engineer from a dashboard builder.

> *"Effective BI analysis begins long before the dashboard. The dashboard is only the visible layer of a much larger workflow: Data Engineering → Data Quality → Data Modelling → SQL Analysis → Reporting Layer → Business Intelligence."*
