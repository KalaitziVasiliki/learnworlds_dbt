##Data Exports: Exports are generated for all layers:
##- `exports/staging/`
##- `exports/intermediate/`
##- `exports/marts/`

import duckdb
import pandas as pd
import os

#Connect to DuckDB
con = duckdb.connect("dev.duckdb", read_only=True)

#Create folders if not exist
os.makedirs("exports/staging", exist_ok=True)
os.makedirs("exports/intermediate", exist_ok=True)
os.makedirs("exports/marts", exist_ok=True)


def export_table(query, path):
    df = con.execute(query).df()
    df.to_csv(path, index=False)
    print(f"✅ Exported -> {path}")


#=========================================================
#STAGING
#=========================================================
export_table("select * from stg_invoices", "exports/staging/stg_invoices.csv")
export_table("select * from stg_customers", "exports/staging/stg_customers.csv")
export_table("select * from stg_products", "exports/staging/stg_products.csv")
export_table("select * from stg_subscriptions", "exports/staging/stg_subscriptions.csv")
export_table("select * from stg_schools", "exports/staging/stg_schools.csv")

#=========================================================
#INTERMEDIATE
#=========================================================
export_table("select * from int_invoice_enriched", "exports/intermediate/int_invoice_enriched.csv")
export_table("select * from int_mrr_expanded", "exports/intermediate/int_mrr_expanded.csv")

#=========================================================
#MART
#=========================================================
export_table("select * from financial_mrr", "exports/marts/financial_mrr.csv")

con.close()