# LearnWorlds — Analytics Engineer Take-Home (dbt Project)

## Overview
This project implements a layered data warehouse using dbt to calculate **Monthly Recurring Revenue (MRR)** for a SaaS business.
The final output provides MRR broken down by:
* Calendar month
* School use case
* Customer country
The pipeline transforms raw transactional data (invoices, subscriptions, customers, products, schools) into a clean, analytics-ready mart.


## Data Modeling Approach
The project follows a layered dbt architecture:

  ### Staging Layer (`stg_`)
  * Mirrors raw seed tables
  * Applies minimal transformations:
    * Type casting
    * Column standardization
    * Basic cleaning (trim, lowercase)
    Models:
    * `stg_invoices`
    * `stg_customers`
    * `stg_products`
    * `stg_subscriptions`
    * `stg_schools`

  ###  Intermediate Layer (`int_`)
  Applies business logic and joins.

    #### `int_invoice_enriched`
      Combines all relevant entities:
      * Customers → country
      * Subscriptions → school_id
      * Schools → use_case
      * Products → billing_frequency

    #### `int_mrr_expanded` 
      Core transformation:
      * Expands each invoice into monthly records
      * Distributes revenue evenly across billing periods

  ###  Mart Layer (`financial_`)
    #### `financial_mrr`
    Final fact table with grain:
      * `month`
      * `use_case`
      * `country`
    Metric:
      * `mrr_usd`


## MRR Calculation Logic
Revenue is **amortized across the billing period** of each invoice.
Example: The invoice is 1,200 euros for the full period of 12 months
  -> MRR contribution: 100 euros/month

  ### Steps:
  1. Generate all months between `billing_start_date` and `billing_end_date`
  2. Count number of months (**inclusive**)
  3. Divide invoice amount evenly
  4. Assign revenue to each month

  This ensures consistency across:
  * Monthly billing
  * Quarterly billing
  * Annual billing


## Assumptions
  ### 1. Inclusive Month Counting
  Start and end months are both included: Jan to Dec = 12 months

  ### 2. Even Revenue Distribution
  Revenue is split evenly per month (no daily-level proration)

  ### 3. Credit Notes (Negative Invoices)
  * Treated as revenue adjustments
  * Amortized across the same billing period
  * Included in final MRR

  ### 4. Subscription Status
  All invoices are included regardless of subscription status.


## Data Quality & Testing
The project includes:

  ### Schema Tests
  * `not_null`
  * `unique`
  * `accepted_values`

  ### Model-Level Tests
  * Unique grain:
    * `month + use_case + country`
    
  ### Reconciliation Test
  A custom dbt data test is implemented to ensure **revenue consistency across the pipeline**.
  It validates that the total invoiced revenue ≈ total MRR after transformation.
  This guarantees that no revenue is lost during transformation abd the final mart reflects true financial totals.

  ### Excluded Tests
  I intentionally did not enforce strict constraints on amount_usd (e.g. positivity), since negative values represent valid credit notes. Instead, correctness is validated through reconciliation.

## Output & Data Exports
  The final model:
  ```
  financial_mrr
  ```
  Provides:
  * Monthly recurring revenue
  * Segmented by use case and geography
  * Ready for BI and reporting

  The project includes CSV exports for all layers of the pipeline, located in the `exports/` folder.
  These exports serve multiple purposes:
  * Validation of transformations across layers
  * Debugging intermediate results
  * Delivering the final mart output (`financial_mrr`)

  Folder structure:
  * `exports/staging/`
  * `exports/intermediate/`
  * `exports/marts/`
  Note:
  In a production environment, typically only curated mart outputs would be exposed, while intermediate layers would remain internal.


## Structure
  ```
  seeds/                 : Raw CSV input files  
  models/staging/        : Data cleaning  
  models/intermediate/   : Business logic  
  models/marts/          : Final analytical models  
  models/utilities/      : Helper models (e.g. date spine)  
  tests/                 : Data tests  
  analyses/              : Exploratory queries  
  exports/               : CSV exports of models (for validation & deliverables)
    ├── staging/         : Staging layer outputs  
    ├── intermediate/    : Intermediate layer outputs  
    └── marts/           : Final mart outputs  
  ```

## Setup & Installation
  ### Prerequisites
  * Python 3.9+
  * dbt
  * DuckDB

  Install dbt:
  ```bash
  pip install dbt-duckdb
  ```

  ### Optional: Virtual Environment
  ```bash
  python -m venv venv
  venv\Scripts\activate
  ```

  ### Install Dependencies
  ```bash
  pip install dbt-duckdb
  ```


## Execution Steps

  ### 1. Load Seed Data
  ```bash
  dbt seed
  ```

  ### 2. Run Staging
  ```bash
  dbt run --select staging
  ```

  ### 3. Run Intermediate
  ```bash
  dbt run --select intermediate
  ```

  ### 4. Run Marts
  ```bash
  dbt run --select marts
  ```

  ### 5. Run Full Pipeline
  ```bash
  dbt run
  ```

  ### 6. Run Tests
  ```bash
  dbt test
  ```

  ### 7. Generate Docs
  ```bash
  dbt docs generate
  dbt docs serve
  ```

  Open:
  ```
  http://localhost:8080
  ```


## Design Decisions
The project was designed with simplicity and clarity in mind, aiming to reflect how a real-world dbt project would be structured under time constraints.
* A layered approach (staging → intermediate → marts) was used to keep transformations organized and maintainable
* Business logic is centralized in the intermediate layer, making it easier to debug and extend
* The final mart is intentionally simple and analytics-friendly, so it can be easily consumed by BI tools or stakeholders
* Readability and transparency were prioritized over complex optimizations, ensuring that each transformation step is easy to understand


## Future Improvements
If this project were extended into a production environment, the following improvements would be considered:
* Introduce a proper date dimension table for more flexible time-based analysis
* Implement subscription snapshots to better track lifecycle changes over time
* Expand reconciliation testing to cover more edge cases and ensure stronger financial guarantees
* Support daily-level proration for more precise revenue allocation
* Optimize performance for larger datasets (e.g. incremental models, partitioning)


## Final Thoughts
This project reflects how I would approach building a clear, reliable, and maintainable MRR pipeline under time constraints.
The focus was on correctness, simplicity, and transparency—ensuring that each step of the transformation is easy to understand and validate. At the same time, I aimed to incorporate realistic practices such as layered modeling, data quality checks, and reconciliation logic.