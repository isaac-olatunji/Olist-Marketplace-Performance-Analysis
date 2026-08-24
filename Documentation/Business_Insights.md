# Business Insights
## Olist Marketplace Performance Analysis

**Analyst:** Isaac | isaactheanalyst
**Period:** September 2016 – September 2018
**Dataset:** Brazilian E-Commerce Public Dataset by Olist

---

## Executive Summary

The Olist marketplace generated **$13.59M in revenue** across **99K orders** between September 2016 and September 2018. Revenue grew consistently year-on-year — from near-zero in late 2016 to $7.4M by end of 2018 — with no reversal observed across the full period.

The business is commercially growing, but faces two operational risks that require attention:
- **Delivery speed** — 12.41 average delivery days with significant category and geographic variation
- **Customer dissatisfaction** — 14K one-star reviews (12.6%) representing a meaningful churn signal despite a 56.55% five-star rate

---

## Key Business Metrics

| Metric | Value |
|---|---:|
| Total Revenue | $13.59M |
| Gross Sales | $15.84M |
| Total Freight | $2.25M |
| Total Orders | 99K |
| Total Customers | 99K |
| Average Order Value | $137.75 |
| Average Review Score | 4.0 / 5 |
| Five-Star Review Rate | 56.55% |
| One-Star Reviews | 14K (12.6%) |
| Average Delivery Days | 12.41 |
| Seller Count | 3K |
| Average Revenue per Seller | $4.39K |

---

## Sales Performance

- Revenue grew from $0.0M (Sept 2016) → $6.2M (2017) → $7.4M (2018)
- Order volume: 45K orders in 2017, growing to 54K in 2018 — a 20% increase
- Gross Sales ($15.84M) exceeds Total Revenue ($13.59M) by exactly $2.25M — the total freight value, confirming the revenue metric represents product-only sales

### Payment Behaviour

- Single-instalment orders dominate at $4.8M — customers who can pay in full do so
- 10-instalment orders spike at $2.0M — the second-largest group, indicating structural demand for longer payment terms
- Understanding which categories drive the 10-instalment spike is a recommended next investigation

---

## Product & Category Performance

| Category | Revenue |
|---|---:|
| health_beauty | $1.26M |
| watches_gifts | $1.21M |
| bed_bath_table | $1.04M |
| sports_leisure | $0.99M |
| computers_accessories | $0.91M |

- health_beauty and watches_gifts lead by revenue but are closely matched — neither has a dominant position
- **Computers AOV is $1,231.84** — the highest of any category, nearly double the next. Low order volume means targeted growth here has outsized revenue leverage
- Average spend per customer ($137.75) matches AOV — most customers make a single purchase, indicating a low repeat-purchase rate

---

## Seller Performance

- **Top seller (Seller 858): $229K** vs lowest seller: **$3.50** — a 65,000:1 ratio
- Top 10 sellers cluster between $160K–$229K — competitive parity at the top
- The majority of 3K sellers contribute minimally — a classic long-tail marketplace distribution
- Higher-revenue sellers correlate with higher freight costs, consistent with volume or heavy-item specialisation

---

## Delivery Performance

| Category | Avg Delivery Days |
|---|---:|
| office_furniture | 20.8 |
| christmas_supplies | 15.7 |
| fashion_shoes | 15.4 |
| security_and_services | 15.0 |
| Platform Average | 12.41 |

- office_furniture at 20.8 days is **68% above the platform average**
- Large and bulky categories consistently cluster above the average
- Geographic variation is significant — some Brazilian states exceed 25 average delivery days
- States with the longest delivery times also have the lowest review scores (visible in the Review Score Distribution scatter)

---

## Customer Satisfaction

| Review Score | Reviews |
|---:|---:|
| 5 | 63K (56.55%) |
| 4 | 21K |
| 3 | 9K |
| 2 | 4K |
| 1 | 14K (12.6%) |

- Distribution is bimodal — customers either have an excellent or a poor experience
- Middle scores (2, 3) are sparse, suggesting polarisation rather than gradual variation
- Best-rated categories: cds_dvds_musicals and fashion_childrens_clothes both average 5/5 — lightweight, fast-delivery items
- The delivery–satisfaction link is directional and visible: as average delivery days increase across states, average review scores decrease

---

## Scenario Analysis

### Scenario 1 — Problem Investigation
**Filters:** São Paulo · bed_bath_table · Credit Card · Review Score 1–2

- Average delivery days for this dissatisfied group: **12.62** (only marginally above platform average)
- **Key finding:** Delivery delay alone does not explain dissatisfaction in bed_bath_table/São Paulo — product quality or expectation management are likely additional drivers
- Revenue trend is declining in this cohort — dissatisfied customers are churning

### Scenario 2 — Performance Investigation
**Filters:** São Paulo · health_beauty · Credit Card · Review Score 4–5

- Average delivery days for this satisfied group: **7.65** (38% faster than platform average)
- Five-star review rate: **78.85%** vs platform average 56.55%
- Revenue trend: strongly growing from $1K (2016) → $123K (2017) → $175K (2018)
- **Key finding:** health_beauty in São Paulo with credit card payments is the best-practice segment — fast delivery, high satisfaction, strong revenue growth

### Scenario Comparison

| | Scenario 1 | Scenario 2 |
|---|---|---|
| Avg Delivery Days | 12.62 | 7.65 |
| Avg Review Score | 1 | 5 |
| Revenue Trend | Declining | Strongly growing |

**Combined conclusion:** Delivery speed is a necessary but not sufficient condition for satisfaction. Fast delivery builds the foundation for strong experience and revenue growth. But dissatisfaction can also stem from product or expectation issues independent of logistics.

---

## Recommendations

### 1. Investigate One-Star Reviews
Cross-reference 14K one-star reviews with delivery days, product category, and seller to identify the primary drivers. Delivery alone is not the full explanation (as Scenario 1 shows).

### 2. Fix Large-Item Logistics
office_furniture at 20.8 days needs category-specific delivery SLAs and specialist logistics partnerships. Apply the same logic to all categories above 15 days.

### 3. Leverage the Computers AOV Opportunity
$1,231.84 AOV with low volume — targeted seller recruitment and marketing in this category could deliver significant revenue uplift per incremental order.

### 4. Expand Instalment Options
The 10-instalment spike ($2.0M) demonstrates demand for longer payment terms. Offering 12–15 instalment options on high-AOV categories could improve conversion and AOV.

### 5. Drive Repeat Purchases
Most customers appear to make a single purchase. A loyalty programme or post-purchase recommendation strategy would improve customer lifetime value.

### 6. Geographic Expansion
Seller and customer activity concentrate in a small number of Brazilian states. Systematic seller recruitment in underserved regions — paired with logistics capability — is the largest available growth lever.

### 7. Fix the Map Geographic Layer
All state maps are currently rendering Brazilian state codes on a US map. Switch to a Brazil choropleth map for accurate geographic representation of customer and seller concentration.

### 8. Fix the Five-Star Rate DAX Under Low-Review Filters
The 340.08% five-star rate in Scenario 1 is a DAX calculation anomaly — the denominator produces a mismatch under restrictive review filters. Review the `Five Star Review Rate` measure logic to handle edge cases.
