with source as (

    select *
    from {{ source('raw', 'products') }}

),

renamed_and_cast as (

    select
        product_id,

        nullif(trim(product_category_name), '')
            as product_category_name,

        cast(
            cast(product_name_lenght as numeric)
            as integer
        ) as product_name_length,

        cast(
            cast(product_description_lenght as numeric)
            as integer
        ) as product_description_length,

        cast(
            cast(product_photos_qty as numeric)
            as integer
        ) as product_photo_count,

        cast(product_weight_g as numeric(12, 2))
            as product_weight_g,

        cast(product_length_cm as numeric(12, 2))
            as product_length_cm,

        cast(product_height_cm as numeric(12, 2))
            as product_height_cm,

        cast(product_width_cm as numeric(12, 2))
            as product_width_cm

    from source

)

select *
from renamed_and_cast