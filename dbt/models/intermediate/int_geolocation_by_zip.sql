with geolocation as (

    select *
    from {{ ref('stg_geolocation') }}

),

coordinates as (

    select
        geolocation_zip_code_prefix,

        avg(latitude)
            as latitude,

        avg(longitude)
            as longitude

    from geolocation

    group by geolocation_zip_code_prefix

),

location_counts as (

    select
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,

        count(*) as location_count

    from geolocation

    group by
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state

),

ranked_locations as (

    select
        *,

        row_number() over (
            partition by geolocation_zip_code_prefix

            order by
                location_count desc,
                geolocation_state,
                geolocation_city
        ) as location_rank

    from location_counts

),

representative_location as (

    select
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state

    from ranked_locations

    where location_rank = 1

),

final as (

    select
        coordinates.geolocation_zip_code_prefix,
        coordinates.latitude,
        coordinates.longitude,
        representative_location.geolocation_city,
        representative_location.geolocation_state

    from coordinates

    inner join representative_location
        on coordinates.geolocation_zip_code_prefix
        = representative_location.geolocation_zip_code_prefix

)

select *
from final