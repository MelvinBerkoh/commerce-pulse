WITH customer_performance AS (

    SELECT
        customer_unique_id,

        COUNT(*) AS delivered_orders,

        SUM(item_subtotal) AS product_revenue,

        AVG(item_subtotal) AS average_order_value,

        MIN(order_date) AS first_order_date,
        MAX(order_date) AS latest_order_date

    FROM analytics_marts.fact_orders

    WHERE order_status = 'delivered'

    GROUP BY customer_unique_id

),

segmented AS (

    SELECT
        *,

        CASE
            WHEN delivered_orders = 1
                THEN '1 order'

            WHEN delivered_orders BETWEEN 2 AND 3
                THEN '2-3 orders'

            ELSE '4+ orders'
        END AS customer_segment,

        CASE
            WHEN delivered_orders = 1 THEN 1
            WHEN delivered_orders BETWEEN 2 AND 3 THEN 2
            ELSE 3
        END AS segment_order

    FROM customer_performance

)

SELECT
    customer_segment,

    COUNT(*) AS customers,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_share_pct,

    SUM(delivered_orders) AS orders,

    ROUND(
        SUM(product_revenue),
        2
    ) AS product_revenue,

    ROUND(
        AVG(product_revenue),
        2
    ) AS average_revenue_per_customer,

    ROUND(
        AVG(average_order_value),
        2
    ) AS average_order_value

FROM segmented

GROUP BY
    customer_segment,
    segment_order

ORDER BY segment_order;