with source as (

    select *
    from {{ source('raw', 'geolocation') }}

),

renamed_and_cast as (

    select
        lpad(trim(geolocation_zip_code_prefix), 5, '0')
            as geolocation_zip_code_prefix,

        cast(geolocation_lat as numeric(10, 7))
            as latitude,

        cast(geolocation_lng as numeric(10, 7))
            as longitude,

        trim(geolocation_city) as geolocation_city,
        upper(trim(geolocation_state)) as geolocation_state

    from source

)

select *
from renamed_and_cast