WITH state_performance AS (

    SELECT
        customers.customer_state,

        COUNT(*) AS delivered_orders,

        COUNT(*) FILTER (
            WHERE orders.was_delivered_late = TRUE
        ) AS late_orders,

        AVG(orders.average_review_score)
            AS average_review_score,

        AVG(orders.delivery_days)
            AS average_delivery_days

    FROM analytics_marts.fact_orders AS orders

    INNER JOIN analytics_marts.dim_customers AS customers
        ON orders.customer_unique_id
        = customers.customer_unique_id

    WHERE
        orders.order_status = 'delivered'
        AND orders.was_delivered_late IS NOT NULL

    GROUP BY customers.customer_state

)

SELECT
    customer_state,

    delivered_orders,
    late_orders,

    ROUND(
        100.0 * late_orders / delivered_orders,
        2
    ) AS late_delivery_rate_pct,

    ROUND(
        average_review_score,
        2
    ) AS average_review_score,

    ROUND(
        average_delivery_days,
        2
    ) AS average_delivery_days

FROM state_performance

WHERE delivered_orders >= 500

ORDER BY late_delivery_rate_pct DESC;