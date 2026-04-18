/*
===========================================================
 Staging Model: stg_invoices
===========================================================
Goal: This model cleans and standardizes raw invoice data.
===========================================================
*/

with source as (
    select * from {{ ref('invoices') }}
),

invoices_cleaned as (
    select
        invoice_id,
        customer_id,
        subscription_id,
        product_id,
        cast(invoice_date as date) as invoice_date,
        cast(billing_start_date as date) as billing_start_date,
        cast(billing_end_date as date) as billing_end_date,
        cast(amount_usd as numeric) as amount_usd,
        case 
            when billing_end_date < billing_start_date then true 
            else false 
        end as invalid_date_range
    from source
)
select * from invoices_cleaned