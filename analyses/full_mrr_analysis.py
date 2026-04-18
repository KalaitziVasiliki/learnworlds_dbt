import duckdb
import pandas as pd
import matplotlib.pyplot as plt

# Connect to DuckDB
con = duckdb.connect("dev.duckdb", read_only=True)


# =========================================================
# HELPERS
# =========================================================

def run_query(title, query, show=True):
    print(f"\n--- {title} ---")
    df = con.execute(query).df()
    if show:
        print(df.head(10))
    return df


def run_bar(df, x, y, title):
    plt.figure()
    plt.bar(df[x].astype(str), df[y])
    plt.title(title)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()


def run_line(df, x, y, title):
    plt.figure()
    plt.plot(df[x], df[y])
    plt.title(title)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()


# =========================================================
# 1. MRR OVER TIME
# =========================================================

df_mrr_time = run_query("MRR Over Time", """
select
    month,
    sum(mrr_usd) as total_mrr
from financial_mrr
group by month
order by month
""")

run_line(df_mrr_time, "month", "total_mrr", "MRR Over Time")


# =========================================================
# 2. MRR BY USE CASE
# =========================================================

df_use_case = run_query("MRR by Use Case", """
select
    use_case,
    sum(mrr_usd) as total_mrr
from financial_mrr
group by use_case
order by total_mrr desc
""")

run_bar(df_use_case, "use_case", "total_mrr", "MRR by Use Case")


# =========================================================
# 3. BILLING ANALYSIS
# =========================================================

df_billing = run_query("Revenue by Billing Frequency", """
select
    billing_frequency,
    count(*) as total_invoices,
    sum(amount_usd) as total_revenue,
    avg(amount_usd) as avg_invoice_amount
from int_invoice_enriched
group by billing_frequency
order by total_revenue desc
""")

run_bar(df_billing, "billing_frequency", "total_revenue", "Revenue by Billing Frequency")


# =========================================================
# 4. TOP COUNTRIES
# =========================================================

df_country = run_query("Top 10 Countries by MRR", """
select
    country,
    sum(mrr_usd) as total_mrr
from financial_mrr
group by country
order by total_mrr desc
limit 10
""")

run_bar(df_country, "country", "total_mrr", "Top 10 Countries by MRR")


# =========================================================
# 5. CREDIT NOTES
# =========================================================

run_query("Credit Notes Impact", """
select
    count(*) as negative_invoices,
    sum(amount_usd) as total_negative_amount
from stg_invoices
where amount_usd < 0
""")


# =========================================================
# 6. VALIDATION
# =========================================================

df_total_mrr = run_query("Total MRR", """
select sum(mrr_usd) as total_mrr
from financial_mrr
""")

df_total_inv = run_query("Total Invoiced", """
select sum(amount_usd) as total_invoiced
from stg_invoices
""")

print("\n--- RECONCILIATION ---")
print("Total MRR:", round(df_total_mrr["total_mrr"][0], 2))
print("Total Invoiced:", round(df_total_inv["total_invoiced"][0], 2))


run_query("Reconciliation Difference", """
select
    (select sum(amount_usd) from stg_invoices) -
    (select sum(mrr_usd) from financial_mrr) as difference
""")


# =========================================================
# 7. EDGE CASES
# =========================================================

run_query("Long Billing Periods", """
select
    invoice_id,
    billing_start_date,
    billing_end_date,
    amount_usd
from int_invoice_enriched
where billing_end_date - billing_start_date >= 365
order by amount_usd desc
limit 10
""")

run_query("Invalid Date Ranges", """
select *
from stg_invoices
where billing_end_date < billing_start_date
""")


# =========================================================
# 8. MRR DISTRIBUTION
# =========================================================

run_query("Invoice → MRR Expansion Check", """
select
    invoice_id,
    count(*) as months_generated,
    sum(monthly_amount) as total_allocated
from int_mrr_expanded
group by invoice_id
order by months_generated desc
limit 10
""")


# =========================================================
# 9. DEBUG / INSPECTION
# =========================================================

run_query("Top MRR Rows", """
select *
from financial_mrr
order by mrr_usd desc
limit 5
""")


con.close()