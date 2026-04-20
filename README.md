# LearnWorlds Take-Home Assignment — Analytics Engineer 

## Overview
Joining a BI team at a SaaS company that sells online learning software. The business sells subscriptions to schools, which fall into distinct use cases: B2B course sellers, B2C course sellers, customer training, corporate training, and government/NGOs. Leadership wants to track **Monthly Recurring Revenue (MRR)** over time, broken down by school use case.
The final output provides MRR broken down by:
* Calendar month
* School use case
* Customer country


## MRR Calculation Logic
Revenue is **amortized across the billing period** of each invoice and here is an example: The invoice is 1,200 euros for the full period of 12 months -> MRR contribution: 100 euros/month


## Data Modeling Approach
The project follows a layered dbt architecture:

  ### Staging Layer (`stg_`)
  * Minimal transformations:
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
  Business logic and joins are applied.
    #### `int_invoice_enriched`
      Combine all relevant entities:
      * Customers → country
      * Subscriptions → school_id
      * Schools → use_case
      * Products → billing_frequency
    #### `int_mrr_expanded` 
      Transformation:
      * Expand each invoice into monthly records
      * Distribute revenue evenly across billing periods

  ###  Mart Layer (`financial_`)
    #### `financial_mrr`
    Final fact table with grain:
      * `month`
      * `use_case`
      * `country`
    Metric:
      * `mrr_usd`


## Assumptions
  ### 1. Inclusive Month Counting
    Start and end months are both included: Jan to Dec = 12 months
  ### 2. Even Revenue Distribution
    Revenue is split evenly per month
  ### 3. Credit Notes (Negative Invoices)
    * Treated as revenue adjustments
    * Amortized across the same billing period
    * Included in final MRR
  ### 4. Subscription Status
    All invoices are included regardless of subscription status.


## Data Quality & Testing
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
  The project includes CSV exports for all layers of the pipeline, located in the `exports/` folder.
  These exports serve multiple purposes:
  * Validation of transformations across layers
  * Debugging intermediate results
  * Delivering the final mart output (`financial_mrr`)
  Folder structure:
  * `exports/staging/`
  * `exports/intermediate/`
  * `exports/marts/`
    

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
* The final mart is intentionally simple, so it can be easily consumed by users and tools
* Readability and transparency were prioritized over complex optimizations, ensuring that each transformation step is easy to understand


## Future Improvements
If this project were extended into a production environment, the following improvements would be considered:
* Introduce a proper date dimension table for more flexible time-based analysis
* Implement subscription snapshots to better track lifecycle changes over time
* Expand reconciliation testing to cover more edge cases
* Optimize performance for larger datasets (e.g. incremental models, partitioning)
