SELECT
    CASE
        WHEN was_delivered_late = TRUE
            THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,

    COUNT(*) AS orders,

    ROUND(
        AVG(average_review_score),
        2
    ) AS average_review_score,

    ROUND(
        AVG(delivery_days),
        2
    ) AS average_delivery_days,

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

FROM analytics_marts.fact_orders

WHERE
    order_status = 'delivered'
    AND was_delivered_late IS NOT NULL

GROUP BY 1

ORDER BY 1;