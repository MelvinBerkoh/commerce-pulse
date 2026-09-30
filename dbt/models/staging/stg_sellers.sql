with source as (

    select *
    from {{ source('raw', 'sellers') }}

),

renamed_and_cast as (

    select
        seller_id,

        lpad(trim(seller_zip_code_prefix), 5, '0')
            as seller_zip_code_prefix,

        trim(seller_city) as seller_city,
        upper(trim(seller_state)) as seller_state

    from source

)

select *
from renamed_and_cast