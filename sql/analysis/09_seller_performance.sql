WITH seller_performance AS (

    SELECT
        items.seller_id,

        COUNT(DISTINCT items.order_id)
            AS orders,

        SUM(items.item_price)
            AS product_revenue,

        AVG(orders.average_review_score)
            AS average_review_score,

        AVG(
            CASE
                WHEN orders.was_delivered_late THEN 1.0
                ELSE 0.0
            END
        ) * 100 AS late_delivery_rate_pct

    FROM analytics_marts.fact_order_items AS items

    INNER JOIN analytics_marts.fact_orders AS orders
        ON items.order_id = orders.order_id

    WHERE orders.order_status = 'delivered'

    GROUP BY items.seller_id

),

ranked AS (

    SELECT
        *,

        ROUND(
            100.0
            * product_revenue
            / SUM(product_revenue) OVER (),
            2
        ) AS revenue_share_pct

    FROM seller_performance

)

SELECT
    seller_id,
    orders,

    ROUND(product_revenue, 2)
        AS product_revenue,

    revenue_share_pct,

    ROUND(average_review_score, 2)
        AS average_review_score,

    ROUND(late_delivery_rate_pct, 2)
        AS late_delivery_rate_pct

FROM ranked

WHERE orders >= 100

ORDER BY product_revenue DESC

LIMIT 20;