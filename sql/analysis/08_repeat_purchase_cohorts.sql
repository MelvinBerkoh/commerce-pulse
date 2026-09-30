WITH delivered_orders AS (

    SELECT
        customer_unique_id,
        order_id,
        order_date

    FROM analytics_marts.fact_orders

    WHERE order_status = 'delivered'

),

dataset_bounds AS (

    SELECT
        MAX(order_date) AS max_order_date

    FROM delivered_orders

),

first_orders AS (

    SELECT
        customer_unique_id,
        MIN(order_date) AS first_order_date

    FROM delivered_orders

    GROUP BY customer_unique_id

),

eligible_customers AS (

    SELECT
        first_orders.*

    FROM first_orders

    CROSS JOIN dataset_bounds

    WHERE
        first_order_date
        <= max_order_date - INTERVAL '90 days'

),

customer_repeat_behavior AS (

    SELECT
        customers.customer_unique_id,
        customers.first_order_date,

        MIN(orders.order_date) FILTER (
            WHERE orders.order_date > customers.first_order_date
              AND orders.order_date
                  <= customers.first_order_date + INTERVAL '90 days'
        ) AS second_order_date

    FROM eligible_customers AS customers

    LEFT JOIN delivered_orders AS orders
        ON customers.customer_unique_id
        = orders.customer_unique_id

    GROUP BY
        customers.customer_unique_id,
        customers.first_order_date

)

SELECT
    DATE_TRUNC(
        'month',
        first_order_date
    )::date AS first_order_month,

    COUNT(*) AS customers,

    COUNT(*) FILTER (
        WHERE second_order_date IS NOT NULL
    ) AS repeat_customers_90d,

    ROUND(
        100.0
        * COUNT(*) FILTER (
            WHERE second_order_date IS NOT NULL
        )
        / COUNT(*),
        2
    ) AS repeat_rate_90d_pct,

    ROUND(
        AVG(
            second_order_date - first_order_date
        ) FILTER (
            WHERE second_order_date IS NOT NULL
        ),
        2
    ) AS avg_days_to_second_order

FROM customer_repeat_behavior

GROUP BY 1

ORDER BY 1;