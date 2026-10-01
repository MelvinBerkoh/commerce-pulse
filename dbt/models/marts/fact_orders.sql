with orders as (

    select *
    from {{ ref('int_orders_enriched') }}

),

items as (

    select *
    from {{ ref('int_order_items_per_order') }}

),

final as (

    select
        orders.order_id,
        orders.customer_unique_id,

        orders.customer_zip_code_prefix,
        orders.customer_city,
        orders.customer_state,

        orders.purchased_at::date
            as order_date,

        orders.purchased_at,
        orders.approved_at,
        orders.delivered_to_carrier_at,
        orders.delivered_to_customer_at,
        orders.estimated_delivery_at,

        orders.order_status,

        items.item_count,
        items.distinct_product_count,
        items.distinct_seller_count,

        items.item_subtotal,
        items.freight_total,
        items.order_item_total,

        orders.total_payment_value,
        orders.payment_record_count,
        orders.payment_type_count,
        orders.max_payment_installments,
        orders.payment_types,

        orders.has_payment,
        orders.has_review,

        orders.review_count,
        orders.average_review_score,

        orders.was_delivered_late,
        orders.delivery_days,
        orders.delivery_vs_estimate_days,

        orders.total_payment_value
            - items.order_item_total
            as payment_item_difference

    from orders

    left join items
        on orders.order_id = items.order_id

)

select *
from final