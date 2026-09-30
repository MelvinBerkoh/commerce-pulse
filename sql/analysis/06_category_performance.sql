WITH category_performance AS (

    SELECT
        products.product_category_name_english
            AS product_category,

        COUNT(DISTINCT items.order_id)
            AS orders,

        SUM(items.item_price)
            AS product_revenue,

        AVG(items.item_price)
            AS average_item_price,

        SUM(items.freight_value)
            AS freight_value

    FROM analytics_marts.fact_order_items AS items

    INNER JOIN analytics_marts.dim_products AS products
        ON items.product_id = products.product_id

    INNER JOIN analytics_marts.fact_orders AS orders
        ON items.order_id = orders.order_id

    WHERE orders.order_status = 'delivered'

    GROUP BY 1

)

SELECT
    product_category,
    orders,

    ROUND(product_revenue, 2)
        AS product_revenue,

    ROUND(average_item_price, 2)
        AS average_item_price,

    ROUND(freight_value, 2)
        AS freight_value,

    ROUND(
        100.0
        * product_revenue
        / SUM(product_revenue) OVER (),
        2
    ) AS revenue_share_pct

FROM category_performance

ORDER BY product_revenue DESC

LIMIT 15;