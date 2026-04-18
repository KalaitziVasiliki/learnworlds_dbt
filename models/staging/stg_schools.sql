/*
===========================================================
 Staging Model: stg_schools
===========================================================
Goal:This model cleans and standardizes school-related data.
===========================================================
*/

with source as (
    select * from {{ ref('schools') }}
),
schools_cleaned as (
    select
        school_id,
        trim(school_name) as school_name,
        lower(trim(use_case)) as use_case
    from source
)

select * from schools_cleaned