# Exploratory Analysis
    This folder contains exploratory queries and visualizations used to:
        * Validate MRR calculations
        * Understand revenue distribution
        * Perform sanity checks
    The analyses are not part of the core dbt pipeline, but were used to:
        * Validate transformation logic
        * Ensure data consistency
        * Support business understanding

## Included Analysis (`full_mrr_analysis.py`)
    This script consolidates all exploratory queries, visualizations, and validation checks into a single reproducible workflow using DuckDB and Python.
    It combines:
    * SQL-based validation queries
    * Data inspection
    * Visual analysis

### Included Visualizations
    -- MRR over time: MRR shows a consistent upward trajectory throughout 2023 and most of 2024, increasing from approximately 15K 
        to  ~25K USD. However, a sharp drop occurs in early 2025, with MRR declining rapidly below 10K and continuing downward.
            Interpretation:
                * The growth phase indicates successful acquisition and expansion
                * The sharp decline strongly suggests:
                * Subscription expirations (especially annual contracts)
                * Increased churn
                * Lack of renewals

    -- MRR by use case: Revenue is evenly distributed across use cases:
            * Highest contributors:
            * b2b_course_sellers (~117K)
            * customer_training (~115K)
            * Lowest (but still strong):
            * government_ngos (~102K)
            Interpretation:
                * The business is well-diversified
                * No over-reliance on a single segment
                * Strong foundation for scalable growth

    -- Revenue by billing frequency: 
            * Monthly: ~251K (largest share)
            * Annual: ~191K
            * Quarterly: ~102K
            Interpretation:
                * Monthly = flexibility but higher churn risk
                * Annual = stronger commitment, more stable revenue

    -- Top countries by MRR:
            * United Kingdom (~75K)
            * Netherlands (~64K)
            * India (~61K)
            * France (~57K)
            * Germany (~54K)
            Interpretation:
                * Revenue is globally distributed
                * Strong presence in Europe + emerging markets
                * No concentration risk


### Validation & Data Checks
    * Reconciliation check (MRR vs invoiced revenue)
    * Credit notes impact
    * Invoice → MRR expansion validation
    * Detection of invalid date ranges
    * Identification of long billing periods
    * Inspection of high-value MRR records


## How to Run the Analysis
Before running the analysis, ensure that the dbt pipeline has been executed:
```bash
dbt run
```
Then run:
```bash
python analyses/full_analysis.py
```


## Requirements
Make sure the following Python packages are installed:
```bash
pip install duckdb pandas matplotlib
```


## Notes
* The script connects to the local DuckDB database (`dev.duckdb`)
* It reads from the final mart (`financial_mrr`) and intermediate models
* Visualizations are generated using matplotlib
* Queries are executed directly against dbt-built tables