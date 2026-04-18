/*
=====================================================================================================================================================
 Mart Model: financial_mrr
=====================================================================================================================================================
Goal: This model aggregates monthly recurring revenue (MRR) by key business dimensions. Represents the final, business-ready output of the pipeline.
Transformations:
- Aggregate monthly revenue contributions
- Group data by time and business dimensions
- Round values for financial reporting consistency
Grain:One row per:
        - month
        - use_case
        - country
=====================================================================================================================================================
*/

with base as (
    select * from {{ ref('int_mrr_expanded') }}
),
final as (
    select
        month,
        use_case,
        country,
        round(sum(monthly_amount), 2) as mrr_usd -- MRR aggregation rounded to 2 decimals for consistency
    from base
    group by 1,2,3
)

select * from final