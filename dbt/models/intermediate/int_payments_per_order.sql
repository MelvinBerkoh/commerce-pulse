with payments as (

    select *
    from {{ ref('stg_order_payments') }}

),

aggregated as (

    select
        order_id,

        count(*) as payment_record_count,

        count(distinct payment_type)
            as payment_type_count,

        sum(payment_value)
            as total_payment_value,

        max(payment_installments)
            as max_payment_installments,

        string_agg(
            distinct payment_type,
            ', '
            order by payment_type
        ) as payment_types

    from payments

    group by order_id

)

select *
from aggregated