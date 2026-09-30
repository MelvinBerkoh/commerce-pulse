WITH delivered_orders AS (

    SELECT
        order_id,
        average_review_score,
        delivery_vs_estimate_days

    FROM analytics_marts.fact_orders

    WHERE
        order_status = 'delivered'
        AND delivery_vs_estimate_days IS NOT NULL

),

bucketed AS (

    SELECT
        *,

        CASE
            WHEN delivery_vs_estimate_days <= 0
                THEN 'On time / early'

            WHEN delivery_vs_estimate_days <= 3
                THEN '1-3 days late'

            WHEN delivery_vs_estimate_days <= 7
                THEN '4-7 days late'

            WHEN delivery_vs_estimate_days <= 14
                THEN '8-14 days late'

            ELSE '15+ days late'
        END AS lateness_bucket,

        CASE
            WHEN delivery_vs_estimate_days <= 0 THEN 1
            WHEN delivery_vs_estimate_days <= 3 THEN 2
            WHEN delivery_vs_estimate_days <= 7 THEN 3
            WHEN delivery_vs_estimate_days <= 14 THEN 4
            ELSE 5
        END AS bucket_order

    FROM delivered_orders

)

SELECT
    lateness_bucket,

    COUNT(*) AS orders,

    ROUND(
        AVG(average_review_score),
        2
    ) AS average_review_score,

    ROUND(
        100.0
        * COUNT(*) FILTER (
            WHERE average_review_score <= 2
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE average_review_score IS NOT NULL
            ),
            0
        ),
        2
    ) AS low_review_rate_pct,

    ROUND(
        100.0
        * COUNT(*) FILTER (
            WHERE average_review_score = 5
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE average_review_score IS NOT NULL
            ),
            0
        ),
        2
    ) AS five_star_review_rate_pct

FROM bucketed

GROUP BY
    lateness_bucket,
    bucket_order

ORDER BY bucket_order;