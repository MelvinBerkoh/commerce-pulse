with reviews as (

    select *
    from {{ ref('stg_order_reviews') }}

),

aggregated as (

    select
        order_id,

        count(*) as review_count,

        round(
            avg(review_score)::numeric,
            2
        ) as average_review_score,

        min(review_score)
            as minimum_review_score,

        max(review_score)
            as maximum_review_score,

        max(review_created_at)
            as latest_review_created_at,

        max(review_answered_at)
            as latest_review_answered_at,

        count(*) filter (
            where review_comment_message is not null
        ) as reviews_with_comment

    from reviews

    group by order_id

)

select *
from aggregated