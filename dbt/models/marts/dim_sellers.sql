with sellers as (

    select *
    from {{ ref('stg_sellers') }}

),

geolocation as (

    select *
    from {{ ref('int_geolocation_by_zip') }}

),

final as (

    select
        sellers.seller_id,
        sellers.seller_zip_code_prefix,
        sellers.seller_city,
        sellers.seller_state,

        geolocation.latitude,
        geolocation.longitude

    from sellers

    left join geolocation
        on sellers.seller_zip_code_prefix
        = geolocation.geolocation_zip_code_prefix

)

select *
from final