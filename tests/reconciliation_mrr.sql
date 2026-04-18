/*
============================================================================================================================
Goal: This is a reconciliation test to ensure that total invoiced revenue matches the aggregated MRR after transformation
============================================================================================================================
*/

with invoices as (
    select
        sum(amount_usd) as total_invoiced
    from {{ ref('stg_invoices') }}
),
mrr as (
    select
        sum(mrr_usd) as total_mrr
    from {{ ref('financial_mrr') }}
)
select *
from invoices, mrr
where abs(total_invoiced - total_mrr) > 1