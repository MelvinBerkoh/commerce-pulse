# CommercePulse Tableau Dashboard Plan

## Goal

Build an interactive business intelligence dashboard from the CommercePulse
analytics warehouse.

The dashboard should help a marketplace operator understand:

- overall business performance
- revenue trends
- customer behavior
- delivery performance
- customer satisfaction
- product category performance
- seller performance

## Dashboard 1 — Executive Overview

### KPI Cards

- Product Revenue
- Delivered Orders
- Unique Customers
- Average Order Value
- Average Review Score
- Late Delivery Rate

### Visuals

1. Monthly Product Revenue
   - Line chart
   - Month on x-axis
   - Product revenue on y-axis

2. Monthly Delivered Orders
   - Line or bar chart
   - Shows marketplace volume growth

3. Top Product Categories
   - Horizontal bar chart
   - Ranked by product revenue

4. Order Status Breakdown
   - Bar chart

### Purpose

Give leadership a quick summary of marketplace performance.

---

## Dashboard 2 — Delivery & Customer Experience

### KPI Cards

- Late Delivery Rate
- Average Delivery Days
- On-Time Average Review Score
- Late Average Review Score

### Visuals

1. Review Score by Delivery Timing
   - Bar chart
   - On-time vs late

2. Lateness Severity
   - Ordered bar chart
   - On time / early
   - 1–3 days late
   - 4–7 days late
   - 8–14 days late
   - 15+ days late

3. Late Delivery Rate by State
   - Geographic map

4. Delivery Days vs Review Score
   - Scatter plot

### Main Finding

Customer satisfaction declines sharply as delivery lateness increases.

---

## Dashboard 3 — Customers

### KPI Cards

- Unique Customers
- Repeat Customer Rate
- 90-Day Repeat Rate
- Average Revenue per Customer

### Visuals

1. Customer Order Frequency
   - One order
   - Two to three orders
   - Four or more orders

2. 90-Day Repeat Rate by Cohort
   - Monthly line chart

3. Revenue per Customer Segment
   - Bar chart

4. Customer Distribution by State
   - Map or ranked bar chart

### Main Finding

Repeat purchasing is extremely low, while repeat customers generate
substantially more revenue per customer.

---

## Dashboard 4 — Products & Sellers

### KPI Cards

- Product Revenue
- Active Product Categories
- Active Sellers
- Top 20 Seller Revenue Share

### Visuals

1. Revenue by Product Category
   - Horizontal bar chart

2. Category Revenue vs Order Volume
   - Scatter plot

3. Top Sellers by Revenue
   - Horizontal bar chart

4. Seller Revenue vs Review Score
   - Scatter plot

5. Seller Revenue vs Late Delivery Rate
   - Scatter plot

### Main Finding

Revenue is diversified across categories and sellers, but some high-revenue
sellers underperform on delivery and customer satisfaction.

---

## Data Sources

### Order-Level Analysis

Primary table:

- `analytics_marts.fact_orders`

Related dimensions:

- `analytics_marts.dim_customers`
- `analytics_marts.dim_date`

Used for:

- executive KPIs
- revenue trends
- customer behavior
- delivery analysis
- review analysis

### Item-Level Analysis

Primary table:

- `analytics_marts.fact_order_items`

Related dimensions:

- `analytics_marts.dim_products`
- `analytics_marts.dim_sellers`

Used for:

- product category analysis
- seller analysis
- item revenue
- freight analysis

## Design Principles

- Keep dashboards simple and easy to scan.
- Avoid unnecessary charts.
- Use consistent KPI definitions.
- Default business performance analysis to delivered orders.
- Clearly label the historical dataset period.
- Use filters for date, state, category, and seller where useful.
- Do not imply correlation proves causation.
