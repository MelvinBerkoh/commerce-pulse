# CommercePulse Data Quality Notes

## Dataset Overview

The raw Olist e-commerce dataset contains data for customers, orders, order
items, payments, reviews, products, sellers, geolocation, and product category
translations.

The purpose of the initial profiling stage was to understand table grain,
relationships, missing data, and potential data quality issues before loading
the data into PostgreSQL.

## Customers

- Customer records: 99,441
- Unique customers: 96,096
- Customers with more than one order: 2,997
- Maximum orders for one customer: 17

`customer_id` represents an order-level customer record.

`customer_unique_id` should be used when analyzing individual customers across
multiple orders.

## Orders

Most orders were successfully delivered.

Order status counts:

- Delivered: 96,478
- Shipped: 1,107
- Canceled: 625
- Unavailable: 609
- Invoiced: 314
- Processing: 301
- Created: 5
- Approved: 2

## Orders Without Items

There are 775 orders without corresponding order item records.

Most are explained by incomplete or unsuccessful order states:

- Unavailable: 603
- Canceled: 164
- Created: 5
- Invoiced: 2
- Shipped: 1

These orders should remain in the order-level data but should not contribute to
item-level revenue calculations.

## Payments

There are 103,886 payment records covering 99,440 orders.

Payments have a one-to-many relationship with orders. Some orders contain
multiple payment records, with one order containing as many as 29.

Payment data must therefore be aggregated to the order level before being
combined with item-level data to avoid fan-out and double-counting.

One delivered order has no payment record:

`bfbd0f9bdef84302105ad712db648a6c`

The record should be retained and treated as a data quality exception rather
than removed or assigned an artificial payment value.

## Reviews

Reviews also have a one-to-many relationship with orders.

Most orders contain one review, but some contain two or three review records.

There are 768 orders without reviews, including 646 delivered orders.

A missing review should be interpreted as no review being recorded, not as a
zero review score.

Review data may need to be aggregated or filtered depending on the analysis.

## Products

- Products: 32,951
- All order item product IDs correspond to valid products.
- Every product appears in the order item dataset.

Some product attributes contain missing values and will require cleaning.

## Sellers

- Sellers: 3,095
- All seller IDs referenced by order items exist in the seller dataset.
- Every seller appears in the order item dataset.

## Product Categories

There are 73 product categories but only 71 English category translations.

Missing translations:

- `pc_gamer`
- `portateis_cozinha_e_preparadores_de_alimentos`

These categories will require explicit translation mappings during the
transformation stage.

## Geolocation

The geolocation dataset contains more than one million records and includes
many duplicate rows and multiple coordinate records for the same ZIP code
prefix.

The raw geolocation table should not be directly joined to customer or seller
tables because doing so may multiply rows.

A transformed geographic lookup containing one representative record per ZIP
code prefix should be created before geographic analysis.

## Modeling Decisions

Based on the profiling results:

1. Preserve the raw datasets without modifying source records.
2. Use `customer_unique_id` for customer-level analytics.
3. Aggregate payments before joining them to other order-level facts.
4. Handle reviews separately because orders can contain multiple reviews.
5. Retain incomplete and anomalous orders instead of deleting them.
6. Create a deduplicated geographic lookup before geographic joins.
7. Resolve missing category translations during transformation.
8. Perform revenue calculations from order items rather than blindly using
   joined payment records.
