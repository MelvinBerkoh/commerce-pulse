with order_items as (

    select *
    from {{ ref('stg_order_items') }}

),

orders as (

    select *
    from {{ ref('int_orders_enriched') }}

),

final as (

    select
        order_items.order_id
            || '-'
            || order_items.order_item_id
            as order_item_key,

        order_items.order_id,
        order_items.order_item_id,

        orders.customer_unique_id,

        orders.purchased_at::date
            as order_date,

        orders.order_status,
        orders.average_review_score,
        orders.was_delivered_late,
        orders.delivery_days,

        order_items.product_id,
        order_items.seller_id,

        order_items.shipping_limit_at,

        order_items.item_price,
        order_items.freight_value,

        order_items.item_price
            + order_items.freight_value
            as item_total

    from order_items

    inner join orders
        on order_items.order_id = orders.order_id

)

select *
from final