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

## How to Run

```bash
dbt seed
dbt run
dbt test
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

