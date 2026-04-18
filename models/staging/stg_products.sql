/*
===========================================================
 Staging Model: stg_products
===========================================================
Goal: This model cleans and standardizes product catalog data.
===========================================================
*/

with source as (
    select * from {{ ref('products') }}
),
products_cleaned as (
    select
        product_id,
        trim(product_name) as product_name,
        lower(trim(billing_frequency)) as billing_frequency
    from source
)
select * from products_cleaned