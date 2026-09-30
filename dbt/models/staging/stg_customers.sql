with source as (

    select *
    from {{ source('raw', 'customers') }}

),

renamed_and_cast as (

    select
        customer_id,
        customer_unique_id,
        lpad(trim(customer_zip_code_prefix), 5, '0')
            as customer_zip_code_prefix,
        trim(customer_city) as customer_city,
        upper(trim(customer_state)) as customer_state

    from source

)

select *
from renamed_and_cast