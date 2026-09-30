# CommercePulse Business Findings

## Overview

CommercePulse analyzes historical Olist marketplace data from 2016 through 2018. The analysis focuses on revenue, customer behavior, delivery performance,
product categories, and seller performance.

The findings below are based primarily on delivered orders so canceled and
unavailable orders do not distort marketplace performance.

## Executive Performance

The marketplace recorded:

- 96,478 delivered orders
- 93,358 unique customers
- $13.22M in product revenue
- $2.20M in freight charges
- $15.42M in total order value
- $137.04 average product order value
- 4.16 average review score
- 8.11% late-delivery rate
- 12.56 average delivery days

## 1. Delivery Performance Is Strongly Associated With Customer Satisfaction

Delivery timing showed one of the clearest relationships in the dataset.

On-time or early orders averaged a 4.29 review score, while late orders
averaged only 2.57.

Low review scores of one or two stars occurred on:

- 9.19% of on-time orders
- 53.99% of late orders

Five-star reviews occurred on:

- 62.38% of on-time orders
- 22.20% of late orders

Customer satisfaction deteriorated further as delays increased.

| Delivery Timing | Average Review | Low-Review Rate |
| --------------- | -------------: | --------------: |
| On time / early |           4.29 |           9.19% |
| 1–3 days late   |           3.76 |          19.17% |
| 4–7 days late   |           2.32 |          61.25% |
| 8–14 days late  |           1.74 |          78.10% |
| 15+ days late   |           1.71 |          78.66% |

The strongest decline occurs once orders become four or more days late.

This is an association and does not by itself prove that delivery delays cause
lower review scores.

## 2. Delivery Problems Are Geographically Concentrated

Late-delivery rates varied substantially by customer state.

Among states with at least 500 delivered orders, some of the highest
late-delivery rates were:

- MA: 19.58%
- CE: 15.30%
- BA: 14.04%
- RJ: 13.48%
- PA: 12.37%
- ES: 12.22%

By comparison:

- SP: 5.89%
- MG: 5.62%
- PR: 5.00%

This suggests logistics performance varies meaningfully by geography rather
than being uniform across the marketplace.

## 3. Revenue Is Diversified Across Product Categories

Health and beauty was the highest-revenue category at approximately $1.23M.

Watches and gifts generated approximately $1.17M despite having fewer orders
than several other leading categories, supported by an average item price of
about $199.

Bed, bath, and table had the highest order volume among the leading categories
but lower average item prices.

The top five product categories generated approximately 39.8% of product
revenue, while the top fifteen generated approximately 76.3%.

Revenue therefore has meaningful category concentration without depending on a
single product category.

## 4. Repeat Purchasing Is Very Low

Among customers with delivered orders:

- 97.0% placed exactly one delivered order
- 2.95% placed two or three orders
- 0.05% placed four or more orders

Customers who returned generated substantially more revenue per customer.

Average product revenue per customer was approximately:

- $137.96 for one-order customers
- $253.18 for customers with two or three orders
- $662.97 for customers with four or more orders

To control for customers entering near the end of the dataset, a 90-day cohort
analysis was also performed.

Among customers with at least 90 days of observation, only approximately 1.3%
placed another delivered order within 90 days.

The low repeat-purchase pattern was consistent across most monthly cohorts.

## 5. High Seller Revenue Does Not Always Mean Strong Customer Experience

The top 20 sellers generated approximately $2.81M in product revenue,
representing 21.28% of marketplace product revenue.

Marketplace revenue is therefore distributed across a relatively broad seller
base rather than being dependent on one dominant seller.

However, among the top 20 sellers:

- 5 averaged below 4 stars
- 4 had late-delivery rates of at least 10%

This suggests seller evaluation should consider fulfillment quality and
customer satisfaction alongside sales volume.

## 6. Marketplace Growth Accelerated Through 2017 and Stabilized in 2018

The early 2016 data contains very low order volume and should not be treated as
a representative operating period.

From 2017 onward, marketplace revenue and order volume increased substantially.

Monthly product revenue reached roughly $950K–$980K during several months in
early 2018 before moderating later in the observed period.

Average order value generally decreased as marketplace volume grew, suggesting
growth was driven more strongly by increasing order volume than by increasing
basket size.

## Business Opportunities

Based on the analysis, the strongest areas for further investigation are:

1. Reduce delivery delays, especially once expected delivery dates are missed
   by several days.
2. Investigate logistics performance in states with unusually high late-order
   rates.
3. Develop customer re-engagement strategies within the first 30–40 days
   following an initial purchase.
4. Monitor high-revenue sellers using both commercial and customer-experience
   metrics.
5. Protect strong revenue categories while identifying opportunities to grow
   lower-volume categories.
