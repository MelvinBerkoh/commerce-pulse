with orders as (

    select *
    from {{ ref('stg_orders') }}

),

customers as (

    select *
    from {{ ref('stg_customers') }}

),

payments as (

    select *
    from {{ ref('int_payments_per_order') }}

),

reviews as (

    select *
    from {{ ref('int_reviews_per_order') }}

),

final as (

    select
        orders.order_id,

        orders.customer_id,
        customers.customer_unique_id,

        customers.customer_zip_code_prefix,
        customers.customer_city,
        customers.customer_state,

        orders.order_status,

        orders.purchased_at,
        orders.approved_at,
        orders.delivered_to_carrier_at,
        orders.delivered_to_customer_at,
        orders.estimated_delivery_at,

        payments.total_payment_value,
        payments.payment_record_count,
        payments.payment_type_count,
        payments.max_payment_installments,
        payments.payment_types,

        reviews.review_count,
        reviews.average_review_score,
        reviews.minimum_review_score,
        reviews.maximum_review_score,
        reviews.reviews_with_comment,

        payments.order_id is not null
            as has_payment,

        reviews.order_id is not null
            as has_review,

        orders.delivered_to_customer_at
            > orders.estimated_delivery_at
            as was_delivered_late,

        round(
            (
                extract(
                    epoch from (
                        orders.delivered_to_customer_at
                        - orders.purchased_at
                    )
                )
                / 86400
            )::numeric,
            2
        ) as delivery_days,

        round(
            (
                extract(
                    epoch from (
                        orders.delivered_to_customer_at
                        - orders.estimated_delivery_at
                    )
                )
                / 86400
            )::numeric,
            2
        ) as delivery_vs_estimate_days

    from orders

    inner join customers
        on orders.customer_id = customers.customer_id

    left join payments
        on orders.order_id = payments.order_id

    left join reviews
        on orders.order_id = reviews.order_id

)

select *
from final