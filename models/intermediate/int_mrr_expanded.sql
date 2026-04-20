/*
===========================================================
 Intermediate Model: int_mrr_expanded
===========================================================
Goal:This model transforms invoice data into monthly revenue contributions by expanding each invoice across its billing period.
Transformations:
- Calculate the number of months per invoice
- Expand each invoice into multiple rows (one per month)
- Allocate revenue evenly across the billing period
Grain: One row per invoice per month
===========================================================
*/

with base as (
    select * from {{ ref('int_invoice_enriched') }}
),
calc as (
    select
        *,
        (
            (year(billing_end_date) - year(billing_start_date)) * 12 +
            (month(billing_end_date) - month(billing_start_date)) + 1
        ) as num_months         -- use year/month difference + 1 to include both start and end month
    from base
),
expanded as (
    select
        b.invoice_id,
        b.country,
        b.use_case,
        date_trunc(
            'month',
            b.billing_start_date + (r * interval '1 month')
        ) as month,      -- generate one row per month within billing period
        b.amount_usd,
        b.num_months
    from calc b
    cross join range(0, 100) as t(r)  -- generate sequence of integers to expand rows having a 'safe' upper bound of 100- for maximum billing duration
    -- Keep only required number of months per invoice
    where r < b.num_months
),
final as (
    select
        invoice_id,
        country,
        use_case,
        month,
        amount_usd / num_months as monthly_amount
    from expanded
)

select * from final
