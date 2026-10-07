# Retail Margin Diagnostic

End-to-end diagnostic project using Excel, SQL, and Power BI to identify 
the root cause of declining profit margins at a mid-sized retail/e-commerce 
company, and propose a specific, actionable fix.

## Executive Summary

Two independent, confirmed problems account for the majority of excess 
margin loss in this dataset:

1. **Central region applies deep discounting to Binders far more often 
   than any other region** — 64% of Central's Binders orders receive an 
   80% discount, versus 16–54% in other regions at a shallower 70% 
   discount. This single behavior cost an estimated **$21,909** in profit.
2. **Tables incurs disproportionate shipping cost company-wide**, losing 
   an estimated **$25,276** once per-unit shipping cost is factored against 
   profit — a structural/logistics issue unrelated to region or discounting.

A third hypothesis — that the company is shifting toward a cheaper, 
lower-margin product mix — was tested and **ruled out**: Furniture's share 
of total revenue has been shrinking since 2015, not growing.

## Dashboard
<img width="1919" height="1076" alt="retail -margin-diagnostic screenshot" src="https://github.com/user-attachments/assets/828fc170-0ef5-4039-b2c7-7cab15b711ff" />


## Business Problem

The company's overall profit margin sits at approximately 12%, with 
significant variation by region and category. This project investigates 
*why*, using a structured, hypothesis-driven approach rather than a 
purely descriptive dashboard.

## Data Source

Kaggle: "Retail Sales, Returns & Shipping Dataset" — three tables:
- **Orders** (9,994 rows) — core fact table: sales, discount, profit, 
  COGS, product, customer, and geography details
- **Returns** (296 rows) — which orders were returned
- **Shipping Rate** (49 rows) — per-state shipping cost per unit

## Methodology

1. **Excel** — profiled all three raw files for data quality (nulls, 
   duplicates, negative values, unmatched join keys, date sanity). Data 
   was clean on every check.
2. **Excel (Pivot)** — exploratory cuts by Region, Segment, and Category 
   surfaced an early signal: Central + Furniture showed a collapsed 
   margin (-2% vs. ~17% elsewhere).
3. **SQL (MySQL)** — built a declared schema, loaded all three tables, 
   and ran targeted queries to test four hypotheses:
   - **H1 — Discounting:** confirmed, localized to Central + Binders
   - **H2 — Returns:** confirmed as a secondary, compounding factor on 
     Binders
   - **H3 — Shipping drag:** confirmed, but as a separate, company-wide 
     issue centered on Tables, not Central
   - **H4 — Mix shift:** ruled out, using a `LAG()` window function to 
     track category revenue share by year
4. **Power BI** — built a data model (orders → shipping_rate on state, 
   orders → returns on order_id), DAX measures (Total Profit, Total Sales, 
   Profit Margin %, Avg Discount %), and a Power Query merge for shipping 
   cost and Profit After Shipping. The dashboard highlights only the two 
   findings (coral) against neutral data (navy): margin by region and 
   category, Central Binders by discount tier, Tables after shipping, 
   KPI cards, and Region/Category/Date slicers.

## Key Insights

| Hypothesis | Verdict | Finding |
|---|---|---|
| Discounting | Confirmed | Central discounts Binders at 80% on 64% of orders vs. 16–54% elsewhere |
| Returns | Confirmed (secondary) | Binders has the worst return-driven profit loss of any sub-category |
| Shipping | Confirmed (separate) | Tables loses ~$25,276 to shipping cost, company-wide |
| Mix shift | Ruled out | Furniture's revenue share has been shrinking since 2015, not growing |

## Recommendations

1. **Cap Binders discounts at 70%** company-wide, matching the ceiling 
   already used in every other region.
2. **Audit Central's discount authorization process for Binders** — 
   investigate why 64% of orders receive the deep-discount tier versus 
   as low as 16% in the best-performing region (West).
3. **Review Tables' shipping cost structure** — the flat per-unit shipping 
   rate likely doesn't reflect the real cost of shipping bulky/low-value 
   items; consider a weight- or category-adjusted shipping rate for this 
   sub-category specifically.

## Repository Structure



## Tools Used

Excel (profiling, Pivot Tables) · MySQL (schema design, CTEs, window 
functions, joins) · Power BI (data modeling, DAX, Power Query, dashboarding)
