with source as (

    select *
    from {{ source('raw', 'product_category_translation') }}

),

renamed as (

    select
        trim(product_category_name)
            as product_category_name,

        trim(product_category_name_english)
            as product_category_name_english

    from source

)

select *
from renamed