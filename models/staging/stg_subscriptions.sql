/*
===========================================================
 Staging Model: stg_subscriptions
===========================================================
Goal:This model cleans and standardizes subscription data.
===========================================================
*/

with source as (
    select * from {{ ref('subscriptions') }}
),
subscriptions_cleaned as (
    select
        subscription_id,
        lower(trim(subscription_type)) as subscription_type,
        school_id,
        lower(trim(billing_method)) as billing_method,
        lower(trim(status)) as status,
        cast(start_date as date) as start_date,
        cast(billed_until_date as date) as billed_until_date,
        case 
            when status = 'active' then true --flag whether the subscription is currently active
            else false 
        end as is_active
    from source
)

select * from subscriptions_cleaned