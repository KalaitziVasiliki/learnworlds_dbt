# LearnWorlds — Analytics Engineer Take-Home (dbt Project)

## Overview

This project builds a layered dbt pipeline to calculate **Monthly Recurring Revenue (MRR)** for a SaaS business.
The final output provides MRR segmented by:
* `month`
* `use_case`
* `country`

---

## MRR Logic

Revenue is **amortized evenly across the billing period** of each invoice.

Example:
1,200 euros over 12 months → 100 euros MRR per month

---

## Data Model

### Staging (`stg_`)

Clean and standardize raw data
Models: `stg_invoices`, `stg_customers`, `stg_products`, `stg_subscriptions`, `stg_schools`

### Intermediate (`int_`)

Apply business logic

* `int_invoice_enriched` → joins all entities
* `int_mrr_expanded` → expands invoices into monthly revenue

### Mart (`financial_`)

Final model:

* `financial_mrr` → MRR by month, use_case, country

---

## Testing

* Schema tests: `not_null`, `unique`, `accepted_values`, `relationships`
* Grain validation: (`month + use_case + country`)
* Reconciliation test: ensures total invoiced ≈ total MRR

Negative values are allowed (credit notes) and validated via reconciliation.

---

## Assumptions

* Even monthly revenue distribution (no daily proration)
* Inclusive billing periods
* Negative invoices treated as adjustments
* All invoices included regardless of subscription status

---

## Outputs

Final dataset:

```
financial_mrr
```

CSV export:

```
exports/marts/financial_mrr.csv
```

---

## Project Structure

```
seeds/               → Raw data  
models/staging/      → Cleaning  
models/intermediate/ → Business logic  
models/marts/        → Final model  
tests/               → Data tests  
analyses/            → Validation & exploration  
exports/             → CSV outputs  
screenshots/         → dbt run & docs proof  
```

---

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


## How to Run

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

---

## Deliverables Coverage

| Requirement                      | Implementation                            |
| -------------------------------- | ----------------------------------------- |
| Source definitions & staging     | `seeds/` + `models/staging/`              |
| Final mart model                 | `models/marts/financial_mrr.sql`          |
| dbt tests                        | `schema.yml` across all layers            |
| README (decisions & assumptions) | This document                             |
| CSV export                       | `exports/marts/financial_mrr.csv`         |
| dbt build screenshots            | `screenshots/dbt_run.png`, `dbt_test.png` |
| dbt docs schema                  | `screenshots/dbt_docs_lineage.png`        |

---

## Design Notes

The project prioritizes:

* Clear layer separation
* Simplicity and readability
* Correct revenue allocation

---

## Future Improvements

* Add date dimension
* Introduce snapshots
* Support daily proration
* Optimize performance (incremental models)

---

