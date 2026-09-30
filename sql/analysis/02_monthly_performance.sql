WITH monthly_performance AS (

    SELECT
        DATE_TRUNC('month', order_date)::date
            AS month,

        COUNT(*) AS delivered_orders,

        COUNT(DISTINCT customer_unique_id)
            AS unique_customers,

        SUM(item_subtotal)
            AS product_revenue,

        AVG(item_subtotal)
            AS average_order_value

    FROM analytics_marts.fact_orders

    WHERE
        order_status = 'delivered'
        AND order_date >= DATE '2017-01-01'

    GROUP BY 1

),

with_growth AS (

    SELECT
        *,

        LAG(product_revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue

    FROM monthly_performance

)

SELECT
    month,
    delivered_orders,
    unique_customers,

    ROUND(product_revenue, 2)
        AS product_revenue,

    ROUND(average_order_value, 2)
        AS average_order_value,

    ROUND(
        100.0
        * (
            product_revenue
            - previous_month_revenue
        )
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS revenue_growth_pct

FROM with_growth

ORDER BY month;