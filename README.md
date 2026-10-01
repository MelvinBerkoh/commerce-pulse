# CommercePulse

CommercePulse is an end-to-end e-commerce analytics project built with the Brazilian Olist dataset.

The project starts with raw CSV files and takes them through Python, PostgreSQL, dbt, SQL, and Tableau. The goal was to clean the data, build reliable reporting tables, answer business questions, and turn the results into dashboards.

The dataset is historical and mainly covers orders from 2016 to 2018.

## Dashboard Preview

### Executive Overview

![Executive Overview](reports/images/executive-overview.png)

### Delivery & Customer Experience

![Delivery and Customer Experience](reports/images/delivery-customer-experience.png)

### Customer Behavior

![Customer Behavior](reports/images/customer-behavior.png)

### Product & Seller Performance

![Product and Seller Performance](reports/images/product-seller-performance.png)

## What This Project Does

The project follows a full analytics workflow:

1. Profile the raw CSV files with Python and Pandas
2. Load the data into PostgreSQL
3. Clean and transform the data with dbt
4. Build fact and dimension tables for analysis
5. Write SQL queries to answer business questions
6. Export the final tables for Tableau
7. Build dashboards for revenue, delivery, customers, products, and sellers

## Tech Stack

- Python
- Pandas
- PostgreSQL
- Docker
- dbt
- SQL
- Tableau
- Git and GitHub

## Data Flow

```text
Olist CSV files
      |
      v
Python profiling
      |
      v
PostgreSQL raw tables
      |
      v
dbt staging models
      |
      v
dbt intermediate models
      |
      v
dbt marts
      |
      v
SQL analysis
      |
      v
Tableau dashboards
```

## Final Data Model

The main reporting tables are:

### Fact Tables

- `fact_orders` - one row per order
- `fact_order_items` - one row per order item

### Dimension Tables

- `dim_customers`
- `dim_products`
- `dim_sellers`
- `dim_date`

There are also intermediate models that handle payments, reviews, geolocation, and other cleanup before the final marts are built.

## Main Findings

For delivered orders, the dataset had:

- 96,478 delivered orders
- 93,358 unique customers
- $13.22M in product revenue
- $137.04 average order value
- 4.16 average review score
- 8.11% late delivery rate

### Delivery and Reviews

Delivery timing had a strong relationship with review scores.

| Delivery Timing | Average Review Score |
| --------------- | -------------------: |
| On time / early |                 4.29 |
| 1-3 days late   |                 3.76 |
| 4-7 days late   |                 2.32 |
| 8-14 days late  |                 1.74 |
| 15+ days late   |                 1.71 |

Orders delivered on time had an average review score of 4.29.

Late orders averaged 2.57.

The biggest drop happened once an order was four or more days late.

### Customer Behavior

Most customers only placed one delivered order.

| Orders     | Customers |  Share |
| ---------- | --------: | -----: |
| 1 order    |    90,557 | 97.00% |
| 2-3 orders |     2,754 |  2.95% |
| 4+ orders  |        47 |  0.05% |

Repeat purchasing was low across the dataset.

### Product Categories

The largest product categories included:

- Health & Beauty
- Watches & Gifts
- Bed, Bath & Table
- Sports & Leisure
- Computers & Accessories

The top five categories made up about 40% of product revenue.

### Sellers

The top 20 sellers made up about 21% of total product revenue.

Some high-revenue sellers also had lower review scores or higher late delivery rates. Because of that, seller performance should not be judged by revenue alone.

## Data Cleanup

The raw data had a few things that needed extra handling.

Payments can have multiple rows for the same order, so they are grouped before joining them to the order table.

Reviews can also have more than one row per order, so they are handled before building the final order model.

The geolocation file contains many duplicate rows and many locations for the same ZIP code. A cleaner ZIP-level lookup is created before it is used.

For customer analysis, `customer_unique_id` is used instead of `customer_id` because it better represents the same customer across multiple orders.

More notes are available in:

```text
reports/data_quality_notes.md
```

The full SQL findings are in:

```text
reports/business_findings.md
```

## Project Structure

```text
commerce-pulse/
├── data/
│   ├── raw/
│   └── processed/
├── dbt/
│   └── models/
│       ├── staging/
│       ├── intermediate/
│       └── marts/
├── reports/
│   ├── images/
│   ├── business_findings.md
│   └── data_quality_notes.md
├── sql/
│   ├── analysis/
│   └── create_raw_schema.sql
├── src/
│   ├── analysis/
│   └── ingestion/
├── tableau/
│   └── CommercePulse.twb
├── tests/
├── docker-compose.yml
├── requirements.txt
└── README.md
```

## How to Run It

### 1. Clone the repo

```bash
git clone https://github.com/MelvinBerkoh/commerce-pulse.git
cd commerce-pulse
```

### 2. Create a Python environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Create your environment file

Copy the example file:

```bash
cp .env.example .env
```

The default local setup uses:

```text
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=commerce_pulse
POSTGRES_USER=commerce_user
POSTGRES_PASSWORD=commerce_password
DATABASE_URL=postgresql://commerce_user:commerce_password@localhost:5432/commerce_pulse
```

### 4. Add the Olist CSV files

Download the Brazilian E-Commerce Public Dataset by Olist.

Place the nine CSV files inside:

```text
data/raw/
```

The raw data is not stored in GitHub.

### 5. Start PostgreSQL

Make sure Docker Desktop is running.

Then run:

```bash
docker compose up -d
```

You can check that the container is running with:

```bash
docker ps
```

### 6. Create the raw database tables

Run:

```bash
docker exec -i commerce-pulse-postgres \
psql -U commerce_user -d commerce_pulse \
< sql/create_raw_schema.sql
```

### 7. Load the CSV files into PostgreSQL

Run:

```bash
python src/ingestion/load_raw_data.py
```

Then check the load:

```bash
python src/ingestion/validate_ingestion.py
```

### 8. Set up dbt

The local dbt profile is ignored by Git because it contains connection settings.

Create:

```text
dbt/profiles.yml
```

Add:

```yaml
commerce_pulse:
  target: dev

  outputs:
    dev:
      type: postgres
      host: "{{ env_var('POSTGRES_HOST') }}"
      port: "{{ env_var('POSTGRES_PORT') | int }}"
      user: "{{ env_var('POSTGRES_USER') }}"
      password: "{{ env_var('POSTGRES_PASSWORD') }}"
      dbname: "{{ env_var('POSTGRES_DB') }}"
      schema: analytics
      threads: 4
```

### 9. Build the dbt models

Move into the dbt folder:

```bash
cd dbt
```

Load the environment variables:

```bash
set -a
source ../.env
set +a
```

Test the connection:

```bash
dbt debug --profiles-dir .
```

Then build everything:

```bash
dbt build --profiles-dir .
```

If the build passes, the staging, intermediate, and mart models are ready.

Return to the project root:

```bash
cd ..
```

### 10. Run the SQL analysis

The business analysis queries are inside:

```text
sql/analysis/
```

They cover:

- executive KPIs
- monthly revenue
- delivery performance
- customer reviews
- customer repeat behavior
- product categories
- sellers

### 11. Export the Tableau data

Run:

```bash
python src/analysis/export_tableau_data.py
```

This creates the CSV files used by Tableau inside:

```text
tableau/data/
```

Those generated files are ignored by Git.

### 12. Open the Tableau workbook

Open:

```text
tableau/CommercePulse.twb
```

The workbook contains four dashboards:

- Executive Overview
- Delivery & Customer Experience
- Customer Behavior
- Product & Seller Performance

If Tableau cannot find the exported CSV files, reconnect the data sources to the files inside:

```text
tableau/data/
```

## About the Dataset

This project uses the Brazilian E-Commerce Public Dataset by Olist.

It includes data for:

- orders
- customers
- sellers
- products
- order items
- payments
- reviews
- geolocation
- product category translations

The dataset is historical, so this project is meant to show the analytics process rather than describe the current Brazilian e-commerce market.

## Author

**Melvin Berkoh**

Computer Science graduate interested in software engineering, analytics, and data-driven applications.

GitHub: [github.com/MelvinBerkoh](https://github.com/MelvinBerkoh)

Portfolio: [portfolio-ten-olive-82.vercel.app](https://portfolio-ten-olive-82.vercel.app)

LinkedIn: [linkedin.com/in/melvinberkoh](https://linkedin.com/in/melvinberkoh)
