with products as (

    select *
    from {{ ref('stg_products') }}

),

categories as (

    select *
    from {{ ref('stg_product_categories') }}

),

final as (

    select
        products.product_id,
        products.product_category_name,

        coalesce(
            categories.product_category_name_english,

            case
                when products.product_category_name = 'pc_gamer'
                    then 'pc_gamer'

                when products.product_category_name =
                    'portateis_cozinha_e_preparadores_de_alimentos'
                    then 'portable_kitchen_and_food_preparation_devices'

                when products.product_category_name is null
                    then 'unknown'

                else products.product_category_name
            end
        ) as product_category_name_english,

        products.product_name_length,
        products.product_description_length,
        products.product_photo_count,
        products.product_weight_g,
        products.product_length_cm,
        products.product_height_cm,
        products.product_width_cm

    from products

    left join categories
        on products.product_category_name
        = categories.product_category_name

)

select *
from final