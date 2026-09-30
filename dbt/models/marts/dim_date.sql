with bounds as (

    select
        min(purchased_at)::date as min_date,
        max(purchased_at)::date as max_date

    from {{ ref('stg_orders') }}

),

date_spine as (

    select
        generate_series(
            min_date,
            max_date,
            interval '1 day'
        )::date as date_day

    from bounds

),

final as (

    select
        date_day,

        extract(year from date_day)::integer
            as year,

        extract(quarter from date_day)::integer
            as quarter,

        extract(month from date_day)::integer
            as month,

        trim(to_char(date_day, 'Month'))
            as month_name,

        extract(day from date_day)::integer
            as day,

        extract(isodow from date_day)::integer
            as day_of_week,

        trim(to_char(date_day, 'Day'))
            as day_name,

        extract(isodow from date_day) in (6, 7)
            as is_weekend

    from date_spine

)

select *
from final