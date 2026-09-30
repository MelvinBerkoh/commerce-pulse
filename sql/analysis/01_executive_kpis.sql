WITH delivered_orders AS (
    SELECT *
    FROM analytics_marts.fact_orders
    WHERE order_status = 'delivered'
)

SELECT
    COUNT(*) AS delivered_orders,

    COUNT(DISTINCT customer_unique_id)
        AS unique_customers,

    ROUND(
        SUM(item_subtotal),
        2
    ) AS product_revenue,

    ROUND(
        SUM(freight_total),
        2
    ) AS freight_revenue,

    ROUND(
        SUM(order_item_total),
        2
    ) AS total_order_value,

    ROUND(
        AVG(item_subtotal),
        2
    ) AS average_order_value,

    ROUND(
        AVG(average_review_score),
        2
    ) AS average_review_score,

    ROUND(
        100.0
        * COUNT(*) FILTER (
            WHERE was_delivered_late = TRUE
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE was_delivered_late IS NOT NULL
            ),
            0
        ),
        2
    ) AS late_delivery_rate_pct,

    ROUND(
        AVG(delivery_days),
        2
    ) AS average_delivery_days

FROM delivered_orders;