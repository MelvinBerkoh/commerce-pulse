with source as (

    select *
    from {{ source('raw', 'order_items') }}

),

renamed_and_cast as (

    select
        order_id,
        cast(order_item_id as integer) as order_item_id,
        product_id,
        seller_id,

        cast(shipping_limit_date as timestamp)
            as shipping_limit_at,

        cast(price as numeric(12, 2))
            as item_price,

        cast(freight_value as numeric(12, 2))
            as freight_value

    from source

)

select *
from renamed_and_cast