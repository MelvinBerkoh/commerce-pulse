with order_items as (

    select *
    from {{ ref('stg_order_items') }}

),

aggregated as (

    select
        order_id,

        count(*) as item_count,

        count(distinct product_id)
            as distinct_product_count,

        count(distinct seller_id)
            as distinct_seller_count,

        sum(item_price)
            as item_subtotal,

        sum(freight_value)
            as freight_total,

        sum(item_price + freight_value)
            as order_item_total

    from order_items

    group by order_id

)

select *
from aggregated