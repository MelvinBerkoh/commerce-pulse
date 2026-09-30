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
        ) * 100
            AS late_delivery_rate_pct

    FROM analytics_marts.fact_order_items AS items

    INNER JOIN analytics_marts.fact_orders AS orders
        ON items.order_id = orders.order_id

    WHERE orders.order_status = 'delivered'

    GROUP BY items.seller_id

),

ranked AS (

    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY product_revenue DESC
        ) AS revenue_rank,

        SUM(product_revenue) OVER ()
            AS total_marketplace_revenue

    FROM seller_performance

)

SELECT
    SUM(product_revenue)
        AS top_20_revenue,

    ROUND(
        100.0
        * SUM(product_revenue)
        / MAX(total_marketplace_revenue),
        2
    ) AS top_20_revenue_share_pct,

    COUNT(*) FILTER (
        WHERE average_review_score < 4.0
    ) AS top_20_sellers_below_4_stars,

    COUNT(*) FILTER (
        WHERE late_delivery_rate_pct >= 10
    ) AS top_20_sellers_above_10pct_late

FROM ranked

WHERE revenue_rank <= 20;