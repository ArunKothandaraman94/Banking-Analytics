# -*- coding: utf-8 -*-
"""
Created on Fri Jul 17 21:22:17 2026

@author: aruns
"""

# ==========================================================
# Czech Banking Analytics
# 01 - Data Loading
# ==========================================================

import pandas as pd

pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)

# -----------------------------
# Load Cleaned Datasets
# -----------------------------

client = pd.read_csv(r"D:\kaggle datasets\1999 Czech Financial Dataset\client_clean.csv")
# Convert birth_date to datetime
client["birth_date"] = pd.to_datetime(client["birth_date"])

# Calculate age
today = pd.Timestamp.today()

reference_date = pd.Timestamp("1999-12-31")

client["age"] = (
    ((reference_date - client["birth_date"]).dt.days / 365.25)
    .round()
    .astype(int)
)


loan = pd.read_csv(r"D:\kaggle datasets\1999 Czech Financial Dataset\loan_clean.csv")
transactions = pd.read_csv(r"D:\kaggle datasets\1999 Czech Financial Dataset\transactions_clean.csv")
card = pd.read_csv(r"D:\kaggle datasets\1999 Czech Financial Dataset\card_clean.csv")
district = pd.read_csv(r"D:\kaggle datasets\1999 Czech Financial Dataset\district_clean.csv")

# Original Tables

account = pd.read_csv(r"D:\kaggle datasets\1999 Czech Financial Dataset\account.csv")
disp = pd.read_csv(r"D:\kaggle datasets\1999 Czech Financial Dataset\disp.csv")

# -----------------------------
# Preview all datasets
# -----------------------------

datasets = {
    "Client": client,
    "Loan": loan,
    "Transactions": transactions,
    "Card": card,
    "District": district,
    "Account": account,
    "Disposition": disp
}

for name, df in datasets.items():

    print("\n" + "="*60)
    print(name)
    print("="*60)

    print("Shape:", df.shape)
    print("\nColumns:")
    print(df.columns.tolist())

    print("\nData Types:")
    print(df.dtypes)

    print("\nMissing Values:")
    print(df.isnull().sum())

    print("\nFirst 5 Rows:")
    print(df.head())
    
    
# ==========================================================
# Czech Banking Analytics
# 02 - Exploratory Data Analysis
# ==========================================================

import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 150)

# ==========================================================
# 1. Load datasets
# ==========================================================

folder_path = r"D:\kaggle datasets\1999 Czech Financial Dataset"

client = pd.read_csv(folder_path + r"\client_clean.csv")
loan = pd.read_csv(folder_path + r"\loan_clean.csv")
transactions = pd.read_csv(folder_path + r"\transactions_clean.csv")
card = pd.read_csv(folder_path + r"\card_clean.csv")
district = pd.read_csv(folder_path + r"\district_clean.csv")
account = pd.read_csv(folder_path + r"\account.csv")
disp = pd.read_csv(folder_path + r"\disp.csv")

print("All datasets loaded successfully.")

# ==========================================================
# 2. Convert date columns
# ==========================================================

client["birth_date"] = pd.to_datetime(
    client["birth_date"],
    errors="coerce"
)

loan["loan_date"] = pd.to_datetime(
    loan["loan_date"],
    errors="coerce"
)

transactions["transaction_date"] = pd.to_datetime(
    transactions["transaction_date"],
    errors="coerce"
)

card["issued_date"] = pd.to_datetime(
    card["issued_date"],
    errors="coerce"
)

# ==========================================================
# 3. Correct customer age
# ==========================================================

# Dataset covers the period up to 1999.
# Age is calculated as of 1999, not the current year.

client["birth_year"] = pd.to_numeric(
    client["birth_year"],
    errors="coerce"
)

client["age"] = 1999 - client["birth_year"]

# Remove impossible age values if any exist
client.loc[
    (client["age"] < 0) | (client["age"] > 100),
    "age"
] = pd.NA

print("\nCustomer age corrected successfully.")

# ==========================================================
# 4. Remove duplicate card records
# ==========================================================

print("\nCard rows before cleaning:", len(card))
print("Unique card IDs before cleaning:", card["card_id"].nunique())
print(
    "Duplicate card rows:",
    card.duplicated(subset="card_id").sum()
)

card = (
    card
    .drop_duplicates(subset="card_id", keep="first")
    .reset_index(drop=True)
)

print("Card rows after cleaning:", len(card))
print("Unique card IDs after cleaning:", card["card_id"].nunique())

# ==========================================================
# 5. Dataset overview
# ==========================================================

datasets = {
    "Client": client,
    "Loan": loan,
    "Transactions": transactions,
    "Card": card,
    "District": district,
    "Account": account,
    "Disposition": disp
}

for name, dataframe in datasets.items():

    print("\n" + "=" * 60)
    print(name.upper())
    print("=" * 60)

    print("\nShape:")
    print(dataframe.shape)

    print("\nColumns:")
    print(dataframe.columns.tolist())

    print("\nData Types:")
    print(dataframe.dtypes)

    print("\nMissing Values:")
    print(dataframe.isnull().sum())

    print("\nFirst 5 Rows:")
    print(dataframe.head())

# ==========================================================
# 6. Customer analysis
# ==========================================================

print("\n" + "=" * 60)
print("CUSTOMER ANALYSIS")
print("=" * 60)

print("\nCustomer Gender Distribution:")
print(client["gender"].value_counts())

print("\nCustomer Gender Percentage:")
print(
    client["gender"]
    .value_counts(normalize=True)
    .mul(100)
    .round(2)
)

print("\nCustomer Age Statistics:")
print(client["age"].describe())

client["age_group"] = pd.cut(
    client["age"],
    bins=[0, 29, 45, 60, 100],
    labels=[
        "Below 30",
        "30-45",
        "46-60",
        "Above 60"
    ],
    include_lowest=True
)

print("\nCustomer Age Group Distribution:")
print(
    client["age_group"]
    .value_counts()
    .sort_index()
)

print("\nTop 10 Districts by Number of Customers:")
print(
    client.groupby("district_id")
    .size()
    .reset_index(name="customer_count")
    .sort_values("customer_count", ascending=False)
    .head(10)
)

# ==========================================================
# 7. Account analysis
# ==========================================================

print("\n" + "=" * 60)
print("ACCOUNT ANALYSIS")
print("=" * 60)

print("\nAccount Statement Frequency:")
print(account["frequency"].value_counts())

print("\nAccount Statement Frequency Percentage:")
print(
    account["frequency"]
    .value_counts(normalize=True)
    .mul(100)
    .round(2)
)

print("\nDisposition Type Distribution:")
print(disp["type"].value_counts())

print("\nNumber of Clients per Account:")
print(
    disp.groupby("account_id")["client_id"]
    .count()
    .value_counts()
    .sort_index()
)

# ==========================================================
# 8. Loan analysis
# ==========================================================

print("\n" + "=" * 60)
print("LOAN ANALYSIS")
print("=" * 60)

print("\nLoan Status Distribution:")
print(loan["status"].value_counts())

print("\nLoan Status Percentage:")
print(
    loan["status"]
    .value_counts(normalize=True)
    .mul(100)
    .round(2)
)

print("\nLoan Amount Statistics:")
print(loan["amount"].describe())

print("\nLoan Duration Distribution:")
print(
    loan["duration"]
    .value_counts()
    .sort_index()
)

print("\nLoan Summary by Status:")
print(
    loan.groupby("status")
    .agg(
        number_of_loans=("loan_id", "count"),
        total_loan_amount=("amount", "sum"),
        average_loan_amount=("amount", "mean"),
        average_monthly_payment=("payments", "mean")
    )
    .round(2)
    .sort_values(
        "total_loan_amount",
        ascending=False
    )
)

# ==========================================================
# 9. Transaction analysis
# ==========================================================

print("\n" + "=" * 60)
print("TRANSACTION ANALYSIS")
print("=" * 60)

print("\nTransaction Type Distribution:")
print(transactions["type"].value_counts())

print("\nTransaction Type Percentage:")
print(
    transactions["type"]
    .value_counts(normalize=True)
    .mul(100)
    .round(2)
)

print("\nTransaction Amount Statistics:")
print(transactions["amount"].describe())

print("\nTransaction Summary by Type:")
print(
    transactions.groupby("type")
    .agg(
        transaction_count=("trans_id", "count"),
        total_amount=("amount", "sum"),
        average_amount=("amount", "mean"),
        maximum_amount=("amount", "max")
    )
    .round(2)
    .sort_values(
        "total_amount",
        ascending=False
    )
)

print("\nTransaction Summary by Operation:")
print(
    transactions.groupby(
        "operation",
        dropna=False
    )
    .agg(
        transaction_count=("trans_id", "count"),
        total_amount=("amount", "sum"),
        average_amount=("amount", "mean")
    )
    .round(2)
    .sort_values(
        "total_amount",
        ascending=False
    )
)

transactions["transaction_year"] = (
    transactions["transaction_date"].dt.year
)

print("\nTransactions by Year:")
print(
    transactions.groupby("transaction_year")
    .agg(
        transaction_count=("trans_id", "count"),
        total_transaction_amount=("amount", "sum")
    )
    .round(2)
)

# ==========================================================
# 10. Card analysis
# ==========================================================

print("\n" + "=" * 60)
print("CARD ANALYSIS")
print("=" * 60)

print("\nCard Type Distribution:")
print(card["type"].value_counts())

print("\nCard Type Percentage:")
print(
    card["type"]
    .value_counts(normalize=True)
    .mul(100)
    .round(2)
)

card["issued_year"] = card["issued_date"].dt.year

print("\nCards Issued by Year:")
print(
    card["issued_year"]
    .value_counts()
    .sort_index()
)

print("\nCard Type by Issued Year:")
print(
    pd.crosstab(
        card["issued_year"],
        card["type"]
    )
)

# ==========================================================
# 11. District analysis
# ==========================================================

print("\n" + "=" * 60)
print("DISTRICT ANALYSIS")
print("=" * 60)

print("\nTop 10 Districts by Population:")
print(
    district[
        [
            "district_name",
            "region",
            "population"
        ]
    ]
    .sort_values(
        "population",
        ascending=False
    )
    .head(10)
)

print("\nTop 10 Districts by Average Salary:")
print(
    district[
        [
            "district_name",
            "region",
            "average_salary"
        ]
    ]
    .sort_values(
        "average_salary",
        ascending=False
    )
    .head(10)
)

print("\nTop 10 Districts by Unemployment Rate:")
print(
    district[
        [
            "district_name",
            "region",
            "unemployment_rate_1996"
        ]
    ]
    .sort_values(
        "unemployment_rate_1996",
        ascending=False
    )
    .head(10)
)

print("\nTop 10 Districts by Crime Rate Count:")
print(
    district[
        [
            "district_name",
            "region",
            "crimes_1996"
        ]
    ]
    .sort_values(
        "crimes_1996",
        ascending=False
    )
    .head(10)
)

# ==========================================================
# 12. Executive summary
# ==========================================================

total_customers = client["client_id"].nunique()
total_accounts = account["account_id"].nunique()
total_loans = loan["loan_id"].nunique()
total_cards = card["card_id"].nunique()
total_transactions = transactions["trans_id"].nunique()

total_loan_amount = loan["amount"].sum()
average_loan_amount = loan["amount"].mean()

total_transaction_amount = transactions["amount"].sum()
average_transaction_amount = transactions["amount"].mean()

risky_loans = loan["status"].isin(["B", "D"]).sum()

risky_loan_percentage = (
    risky_loans / total_loans * 100
)

successful_loans = loan["status"].isin(["A", "C"]).sum()

successful_loan_percentage = (
    successful_loans / total_loans * 100
)

print("\n" + "=" * 60)
print("EXECUTIVE SUMMARY")
print("=" * 60)

print(f"Total Customers              : {total_customers:,}")
print(f"Total Accounts               : {total_accounts:,}")
print(f"Total Loans                  : {total_loans:,}")
print(f"Total Cards                  : {total_cards:,}")
print(f"Total Transactions           : {total_transactions:,}")

print(f"Total Loan Amount            : {total_loan_amount:,.2f}")
print(f"Average Loan Amount          : {average_loan_amount:,.2f}")

print(
    f"Total Transaction Amount     : "
    f"{total_transaction_amount:,.2f}"
)

print(
    f"Average Transaction Amount   : "
    f"{average_transaction_amount:,.2f}"
)

print(f"Successful Loans             : {successful_loans:,}")
print(
    f"Successful Loan Percentage   : "
    f"{successful_loan_percentage:.2f}%"
)

print(f"Risky Loans                  : {risky_loans:,}")
print(
    f"Risky Loan Percentage        : "
    f"{risky_loan_percentage:.2f}%"
)

# ==========================================================
# 13. Export cleaned Python datasets
# ==========================================================

client.to_csv(
    folder_path + r"\client_python_clean.csv",
    index=False
)

card.to_csv(
    folder_path + r"\card_python_clean.csv",
    index=False
)

print("\nFiles exported successfully:")
print("client_python_clean.csv")
print("card_python_clean.csv")

print("\nExploratory analysis completed successfully.")


#---
import matplotlib.pyplot as plt
# ==========================================================
# Customer Age Distribution
# ==========================================================

plt.figure(figsize=(10,6))

plt.hist(client["age"].dropna(), bins=15, edgecolor="black")

plt.title("Customer Age Distribution")
plt.xlabel("Age")
plt.ylabel("Number of Customers")

plt.grid(axis="y", alpha=0.3)

plt.tight_layout()
plt.show()

# ==========================================================
# Loan Status Distribution
# ==========================================================

loan["status"].value_counts().plot(
    kind="bar",
    figsize=(8,6)
)

plt.title("Loan Status Distribution")
plt.xlabel("Loan Status")
plt.ylabel("Number of Loans")

plt.grid(axis="y", alpha=0.3)

plt.tight_layout()
plt.show()

# ==========================================================
# Transactions by Year
# ==========================================================

transactions["transaction_year"] = transactions["transaction_date"].dt.year

transactions.groupby("transaction_year")["trans_id"].count().plot(
    kind="line",
    marker="o",
    figsize=(10,6)
)

plt.title("Transactions by Year")
plt.xlabel("Year")
plt.ylabel("Number of Transactions")

plt.grid(alpha=0.3)

plt.tight_layout()
plt.show()

# ==========================================================
# Card Type Distribution
# ==========================================================

card["type"].value_counts().plot(
    kind="bar",
    figsize=(8,6)
)

plt.title("Card Type Distribution")
plt.xlabel("Card Type")
plt.ylabel("Number of Cards")

plt.grid(axis="y", alpha=0.3)

plt.tight_layout()
plt.show()

# ==========================================================
# Czech Banking Analytics
# 04 - Business Insights
# ==========================================================

print("\n" + "="*70)
print("BUSINESS INSIGHTS")
print("="*70)

# ----------------------------------------------------------
# Insight 1
# ----------------------------------------------------------

print("\n1. Customer Demographics")
print("- Majority of customers fall between the working-age population.")
print("- This indicates the bank primarily serves active income earners.")
print("- Products such as loans and premium banking services can be targeted to this segment.")

# ----------------------------------------------------------
# Insight 2
# ----------------------------------------------------------

print("\n2. Loan Portfolio")
print("- Most loans are classified under successful repayment categories (A and C).")
print("- Only a small percentage belong to risky loan categories (B and D).")
print("- Overall loan portfolio appears financially healthy.")

# ----------------------------------------------------------
# Insight 3
# ----------------------------------------------------------

print("\n3. Transaction Activity")
print("- The bank processes a very high number of customer transactions.")
print("- Regular transaction activity indicates strong customer engagement.")
print("- Transaction data can be used to identify customer behavior and cross-selling opportunities.")

# ----------------------------------------------------------
# Insight 4
# ----------------------------------------------------------

print("\n4. Card Products")
print("- Classic cards represent the largest share of issued cards.")
print("- Premium card adoption remains comparatively low.")
print("- The bank can increase revenue by promoting premium card upgrades.")

# ----------------------------------------------------------
# Insight 5
# ----------------------------------------------------------

print("\n5. Regional Performance")
print("- Districts with higher population also have a larger customer base.")
print("- High-income districts provide opportunities for premium financial products.")
print("- Marketing campaigns can be prioritized based on district demographics.")

# ----------------------------------------------------------
# Insight 6
# ----------------------------------------------------------

print("\n6. Business Recommendation")
print("- Focus marketing on working-age customers.")
print("- Improve monitoring of risky loans.")
print("- Increase premium card adoption through targeted offers.")
print("- Expand lending in high-income districts.")
print("- Use transaction history for personalized product recommendations.")

print("END OF BUSINESS INSIGHTS")
