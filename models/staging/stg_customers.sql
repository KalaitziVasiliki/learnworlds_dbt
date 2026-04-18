/*
===========================================================
 Staging Model: stg_customers
===========================================================
Goal: This model cleans and standardizes raw customer data.
===========================================================
*/

with source as (
    -- Load raw customer data from seed/source table
    select * from {{ ref('customers') }}
),

customers_cleaned as (
    select
        customer_id,
        trim(company_name) as company_name,
        lower(trim(country)) as country,
        lower(trim(default_billing_method)) as default_billing_method
    from source
)
select * from customers_cleaned