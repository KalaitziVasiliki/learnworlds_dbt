/*
===========================================================
 Intermediate Model: int_invoice_enriched
===========================================================
Goal: This model enriches invoice data by joining it with customer, subscription, school, and product dimensions.
Transformations:
    - Filter out invalid invoice records
    - Join multiple dimensions to create a denormalized dataset
    - Adds business context (country, use_case, billing_frequency)
Grain:One row per invoice

Note:
    - LEFT JOINS are used to ensure that no invoice records are dropped due to missing dimensional data.
    - Maintaining all invoices is critical for the revenue accuracy and correct MRR calculations.
===========================================================
*/

with invoices as (
    select * 
    from {{ ref('stg_invoices') }}
    where invalid_date_range = false
),
customers as (
    select * from {{ ref('stg_customers') }}
),
subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),
schools as (
    select * from {{ ref('stg_schools') }}
),
products as (
    select * from {{ ref('stg_products') }}
),
joined as (
    select  
        i.invoice_id,
        i.subscription_id,
        i.customer_id,
        i.product_id,
        i.invoice_date,
        i.billing_start_date,
        i.billing_end_date,
        i.amount_usd,
        c.country,
        s.school_id,
        s.subscription_type,
        s.status as subscription_status,
        sch.use_case,
        p.billing_frequency
    from invoices i
    left join customers c
        on i.customer_id = c.customer_id
    left join subscriptions s
        on i.subscription_id = s.subscription_id
    left join schools sch
        on s.school_id = sch.school_id
    left join products p
        on i.product_id = p.product_id
)

select * from joined