with orders as (

    select *
    from {{ ref('int_orders_enriched') }}

),

geolocation as (

    select *
    from {{ ref('int_geolocation_by_zip') }}

),

customer_summary as (

    select
        customer_unique_id,

        min(purchased_at) as first_order_at,
        max(purchased_at) as latest_order_at,

        count(*) as lifetime_order_count

    from orders

    group by customer_unique_id

),

latest_customer_record as (

    select
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,

        row_number() over (
            partition by customer_unique_id
            order by purchased_at desc, order_id
        ) as row_number

    from orders

),

final as (

    select
        customer_summary.customer_unique_id,

        latest_customer_record.customer_zip_code_prefix,
        latest_customer_record.customer_city,
        latest_customer_record.customer_state,

        geolocation.latitude,
        geolocation.longitude,

        customer_summary.first_order_at,
        customer_summary.latest_order_at,
        customer_summary.lifetime_order_count,

        customer_summary.lifetime_order_count > 1
            as is_repeat_customer

    from customer_summary

    inner join latest_customer_record
        on customer_summary.customer_unique_id
        = latest_customer_record.customer_unique_id

    left join geolocation
        on latest_customer_record.customer_zip_code_prefix
        = geolocation.geolocation_zip_code_prefix

    where latest_customer_record.row_number = 1

)

select *
from final