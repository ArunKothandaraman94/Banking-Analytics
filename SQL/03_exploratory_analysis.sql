-- SECTION 1 : DATABASE OVERVIEW

SELECT 'Customers' AS category, COUNT(*) AS total
FROM client_clean

UNION ALL

SELECT 'Accounts', COUNT(*)
FROM account

UNION ALL

SELECT 'Transactions', COUNT(*)
FROM transactions_clean

UNION all


SELECT 'Loans', COUNT(*)
FROM loan_clean

UNION ALL

SELECT 'Cards', COUNT(*)
FROM card_clean

UNION ALL

SELECT 'Orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'Districts', COUNT(*)
FROM district_clean

UNION ALL

SELECT 'Dispositions', COUNT(*)
FROM disp

ORDER BY category;


---SECTION 2 — CUSTOMER ANALYSIS


--Query 1 — Total Male vs Female Customers
select gender,count(*) as total_customers  
from client_clean 
group by 1;


--Query 2 — Customers by District
select district_id ,count(distinct client_id) as customers
from client_clean cc 
group by 1

--Query 3 — Top 10 Districts by Customers (with district names)

select *
from(
select *, rank() over (order by customers_cnt desc) as rank
from(
select c.district_id,d.district_name, count(distinct c.client_id) as customers_cnt
from client_clean c
left join district_clean d on d.district_id  = c.district_id 
group by 1,2
order by 1 
)
)
where rank<=10
order by rank 

--Query 4 - Average Customer Age
select ROUND(avg(extract(year from age(current_date,birth_date))),2) as average_age
from client_clean;

--Query 5 - Customer Age Group Distribution
select age_category,count(distinct client_id) as cnt_of_customers
from(
select *, 
       case when age>60 then 'above 60' 
            when age>=45 and age<=60 then '45-60'
            else 'below 45' end as age_category
from(
            select client_id,
       extract(year from age(current_date,birth_date)) as age
from client_clean 
) as t
)
group by 1
;

--Section 3 — Account Analysis-------------

--Query 1 - Accounts by Frequency type
SELECT
    CASE
        WHEN frequency = 'POPLATEK MESICNE' THEN 'Monthly'
        WHEN frequency = 'POPLATEK TYDNE' THEN 'Weekly'
        WHEN frequency = 'POPLATEK PO OBRATU' THEN 'After transaction'
        ELSE frequency
    END AS statement_frequency,
    COUNT(*) AS total_accounts
FROM account
GROUP BY statement_frequency
ORDER BY total_accounts DESC;

--Query 2 - Accounts opened by year
select extract(year from account_open_date) as year, count(distinct account_id) as accounts
from account
group by 1


-- Query 3 — Accounts by District

SELECT
    a.district_id,
    d.district_name,
    COUNT(DISTINCT a.account_id) AS total_accounts
FROM account a
LEFT JOIN district_clean d
    ON a.district_id = d.district_id
GROUP BY
    a.district_id,
    d.district_name
ORDER BY total_accounts DESC;


-- Query 4 — Top 10 Districts by Number of Accounts

SELECT
    district_id,
    district_name,
    total_accounts,
    district_rank
FROM (
    SELECT
        district_id,
        district_name,
        total_accounts,
        RANK() OVER (
            ORDER BY total_accounts DESC
        ) AS district_rank
    FROM (
        SELECT
            a.district_id,
            d.district_name,
            COUNT(DISTINCT a.account_id) AS total_accounts
        FROM account a
        LEFT JOIN district_clean d
            ON a.district_id = d.district_id
        GROUP BY
            a.district_id,
            d.district_name
    ) AS account_summary
) AS ranked_accounts
WHERE district_rank <= 10
ORDER BY district_rank;


-- Query 5 — Average Number of Accounts per District

SELECT
    ROUND(AVG(total_accounts), 2) AS average_accounts_per_district
FROM (
    SELECT
        district_id,
        COUNT(DISTINCT account_id) AS total_accounts
    FROM account
    GROUP BY district_id
) AS district_accounts;


-- Query 6 — Account Opening Trend by Year

SELECT
    EXTRACT(YEAR FROM account_open_date) AS opening_year,
    COUNT(DISTINCT account_id) AS total_accounts
FROM account
GROUP BY opening_year
ORDER BY opening_year;


-- Query 7 — Account Opening Trend by Year and Month

SELECT
    DATE_TRUNC('month', account_open_date)::date AS opening_month,
    COUNT(DISTINCT account_id) AS total_accounts
FROM account
GROUP BY opening_month
ORDER BY opening_month;

-- ==========================================================
-- SECTION 4 : LOAN ANALYSIS
-- ==========================================================


-- Query 1 — Loan Status Distribution

SELECT
    CASE
        WHEN status = 'A' THEN 'Completed - paid successfully'
        WHEN status = 'B' THEN 'Completed - payment problems'
        WHEN status = 'C' THEN 'Active - payments on time'
        WHEN status = 'D' THEN 'Active - customer in debt'
        ELSE 'Unknown'
    END AS loan_status,
    COUNT(*) AS total_loans
FROM loan_clean
GROUP BY status
ORDER BY total_loans DESC;



-- Query 2 — Loan Amount Summary

SELECT
    COUNT(*) AS total_loans,
    SUM(amount) AS total_loan_amount,
    ROUND(AVG(amount), 2) AS average_loan_amount,
    MIN(amount) AS minimum_loan_amount,
    MAX(amount) AS maximum_loan_amount
FROM loan_clean;



-- Query 3 — Loans Issued by Year

SELECT
    EXTRACT(YEAR FROM loan_date) AS loan_year,
    COUNT(*) AS total_loans,
    SUM(amount) AS total_loan_amount,
    ROUND(AVG(amount), 2) AS average_loan_amount
FROM loan_clean
GROUP BY loan_year
ORDER BY loan_year;



-- Query 4 — Loan Amount by District

SELECT
    d.district_name,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.amount) AS total_loan_amount,
    ROUND(AVG(l.amount), 2) AS average_loan_amount
FROM loan_clean l
JOIN account a
    ON l.account_id = a.account_id
JOIN district_clean d
    ON a.district_id = d.district_id
GROUP BY d.district_name
ORDER BY total_loan_amount DESC;



-- Query 5 — Risky Loan Percentage

SELECT
    COUNT(*) AS total_loans,

    COUNT(case WHEN status IN ('B', 'D') THEN 1 END) AS risky_loans,

    ROUND(100.0 * COUNT(case WHEN status IN ('B', 'D') THEN 1 END) / NULLIF(COUNT(*), 0),2) AS risky_loan_percentage

FROM loan_clean;

-- ==========================================================
-- SECTION 5 : CARD ANALYSIS
-- ==========================================================

-- Query 1 — Card Type Distribution

SELECT
    type AS card_type,
    COUNT(*) AS total_cards
FROM card_clean
GROUP BY type
ORDER BY total_cards DESC;


-- Query 2 — Cards Issued by Year

SELECT
    EXTRACT(YEAR FROM issued_date) AS issued_year,
    COUNT(*) AS total_cards
FROM card_clean
GROUP BY issued_year
ORDER BY issued_year;


-- Query 3 — Card Type by Gender

SELECT
    c.type AS card_type,
    cl.gender,
    COUNT(*) AS total_cards
FROM card_clean c
JOIN disp d
    ON c.disp_id = d.disp_id
JOIN client_clean cl
    ON d.client_id = cl.client_id
GROUP BY
    c.type,
    cl.gender
ORDER BY
    c.type,
    cl.gender;


-- Query 4 — Card Distribution by District

SELECT
    dc.district_name,
    COUNT(c.card_id) AS total_cards
FROM card_clean c
JOIN disp d
    ON c.disp_id = d.disp_id
JOIN client_clean cl
    ON d.client_id = cl.client_id
JOIN district_clean dc
    ON cl.district_id = dc.district_id
GROUP BY
    dc.district_name
ORDER BY total_cards DESC;


-- Query 5 — Average Customer Age by Card Type

SELECT
    c.type AS card_type,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, cl.birth_date))),2) AS average_age,
    COUNT(*) AS total_customers
FROM card_clean c
JOIN disp d
    ON c.disp_id = d.disp_id
JOIN client_clean cl
    ON d.client_id = cl.client_id
GROUP BY c.type
ORDER BY average_age DESC;

-- ==========================================================
-- SECTION 6 : TRANSACTION ANALYSIS
-- ==========================================================

-- Query 1 — Transaction Type Distribution

SELECT
    type AS transaction_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount)::numeric, 2) AS total_amount
FROM transactions_clean
GROUP BY type
ORDER BY total_transactions DESC;


-- Query 2 — Transaction Amount by Operation

SELECT
    operation,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount)::numeric, 2) AS total_amount,
    ROUND(AVG(amount)::numeric, 2) AS average_transaction_amount
FROM transactions_clean
GROUP BY operation
ORDER BY total_amount DESC;


-- Query 3 — Monthly Transaction Trend

SELECT
    EXTRACT(YEAR FROM transaction_date) AS transaction_year,
    EXTRACT(MONTH FROM transaction_date) AS transaction_month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount)::numeric, 2) AS total_transaction_amount
FROM transactions_clean
GROUP BY transaction_year, transaction_month
ORDER BY transaction_year, transaction_month;


-- Query 4 — Top 10 Accounts by Transaction Amount

SELECT
    account_id,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount)::numeric, 2) AS total_transaction_amount
FROM transactions_clean
GROUP BY account_id
ORDER BY total_transaction_amount DESC
LIMIT 10;


-- Query 5 — Account Balance Summary

SELECT
    ROUND(AVG(balance)::numeric, 2) AS average_balance,
    ROUND(MIN(balance)::numeric, 2) AS minimum_balance,
    ROUND(MAX(balance)::numeric, 2) AS maximum_balance
FROM transactions_clean;


-- SECTION 7 : DISTRICT ANALYSIS

-- Query 1 — Top 10 Districts by Average Salary

SELECT
    district_id,
    district_name,
    average_salary
FROM district_clean
ORDER BY average_salary DESC
LIMIT 10;


-- Query 2 — Top 10 Districts by Population

SELECT
    district_id,
    district_name,
    population
FROM district_clean
ORDER BY population DESC
LIMIT 10;


-- Query 3 — Districts with Highest Unemployment Rate

SELECT
    district_id,
    district_name,
    unemployment_rate_1996
FROM district_clean
ORDER BY unemployment_rate_1996 DESC
LIMIT 10;


-- Query 4 — Districts with Highest Crime Rate

SELECT
    district_id,
    district_name,
    crimes_1996,
    population,
    ROUND(
        (crimes_1996 * 1000.0 / NULLIF(population, 0))::numeric,
        2
    ) AS crimes_per_1000_people
FROM district_clean
ORDER BY crimes_per_1000_people DESC
LIMIT 10;


-- Query 5 — District Economic Summary

SELECT
    ROUND(AVG(average_salary)::numeric, 2) AS average_district_salary,
    ROUND(AVG(unemployment_rate_1996)::numeric, 2) AS average_unemployment_rate,
    SUM(population) AS total_population,
    SUM(crimes_1996) AS total_crimes
FROM district_clean;


-- SECTION 8 : ADVANCED JOIN ANALYSIS

-- Query 1 — Average Loan Amount by Gender

SELECT
    c.gender,
    COUNT(l.loan_id) AS total_loans,
    ROUND(AVG(l.amount)::numeric,2) AS average_loan_amount,
    ROUND(SUM(l.amount)::numeric,2) AS total_loan_amount
FROM loan_clean l
JOIN account a
    ON l.account_id = a.account_id
JOIN disp d
    ON a.account_id = d.account_id
JOIN client_clean c
    ON d.client_id = c.client_id
GROUP BY c.gender
ORDER BY total_loan_amount DESC;


-- Query 2 — Average Transaction Amount by Gender

SELECT
    c.gender,
    COUNT(t.trans_id) AS total_transactions,
    ROUND(AVG(t.amount)::numeric,2) AS average_transaction_amount,
    ROUND(SUM(t.amount)::numeric,2) AS total_transaction_amount
FROM transactions_clean t
JOIN account a
    ON t.account_id = a.account_id
JOIN disp d
    ON a.account_id = d.account_id
JOIN client_clean c
    ON d.client_id = c.client_id
GROUP BY c.gender
ORDER BY total_transaction_amount DESC;


-- Query 3 — Customers Having Both Loan and Card

SELECT
    COUNT(DISTINCT c.client_id) AS customers_with_loan_and_card
FROM client_clean c
JOIN disp d
    ON c.client_id = d.client_id
JOIN account a
    ON d.account_id = a.account_id
JOIN loan_clean l
    ON a.account_id = l.account_id
JOIN card_clean cd
    ON d.disp_id = cd.disp_id;


-- Query 4 — Top 10 Customers by Transaction Amount

SELECT
    c.client_id,
    c.gender,
    ROUND(SUM(t.amount)::numeric,2) AS total_transaction_amount
FROM client_clean c
JOIN disp d
    ON c.client_id = d.client_id
JOIN account a
    ON d.account_id = a.account_id
JOIN transactions_clean t
    ON a.account_id = t.account_id
GROUP BY
    c.client_id,
    c.gender
ORDER BY total_transaction_amount DESC
LIMIT 10;


-- Query 5 — District with Highest Average Loan Amount

SELECT
    dc.district_name,
    ROUND(AVG(l.amount)::numeric,2) AS average_loan_amount
FROM loan_clean l
JOIN account a
    ON l.account_id = a.account_id
JOIN district_clean dc
    ON a.district_id = dc.district_id
GROUP BY dc.district_name
ORDER BY average_loan_amount DESC
LIMIT 10;

-- ==========================================================
-- SECTION 9 : WINDOW FUNCTION ANALYSIS
-- ==========================================================

-- Query 1 — Rank Accounts by Total Transaction Amount

SELECT
    account_id,
    total_transaction_amount,
    RANK() OVER (
        ORDER BY total_transaction_amount DESC
    ) AS account_rank
FROM (
    SELECT
        account_id,
        ROUND(SUM(amount)::numeric, 2) AS total_transaction_amount
    FROM transactions_clean
    GROUP BY account_id
) AS account_summary
ORDER BY account_rank;


-- Query 2 — Top 3 Accounts in Each District

SELECT
    district_id,
    district_name,
    account_id,
    total_transaction_amount,
    district_rank
FROM (
    SELECT
        district_id,
        district_name,
        account_id,
        total_transaction_amount,
        RANK() OVER (
            PARTITION BY district_id
            ORDER BY total_transaction_amount DESC
        ) AS district_rank
    FROM (
        SELECT
            a.district_id,
            d.district_name,
            t.account_id,
            ROUND(SUM(t.amount)::numeric, 2) AS total_transaction_amount
        FROM transactions_clean t
        JOIN account a
            ON t.account_id = a.account_id
        JOIN district_clean d
            ON a.district_id = d.district_id
        GROUP BY
            a.district_id,
            d.district_name,
            t.account_id
    ) AS district_account_summary
) AS ranked_accounts
WHERE district_rank <= 3
ORDER BY district_id, district_rank;


-- Query 3 — Running Total of Monthly Transaction Amount

SELECT
    transaction_month,
    monthly_transaction_amount,

    SUM(monthly_transaction_amount) OVER (
        ORDER BY transaction_month
    ) AS running_transaction_amount

FROM (
    SELECT
        DATE_TRUNC('month', transaction_date)::date AS transaction_month,
        ROUND(SUM(amount)::numeric, 2) AS monthly_transaction_amount
    FROM transactions_clean
    GROUP BY transaction_month
) AS monthly_summary
ORDER BY transaction_month;


-- Query 4 — Previous Month Transaction Amount Using LAG

SELECT
    transaction_month,
    monthly_transaction_amount,

    LAG(monthly_transaction_amount) OVER (
        ORDER BY transaction_month
    ) AS previous_month_amount

FROM (
    SELECT
        DATE_TRUNC('month', transaction_date)::date AS transaction_month,
        ROUND(SUM(amount)::numeric, 2) AS monthly_transaction_amount
    FROM transactions_clean
    GROUP BY transaction_month
) AS monthly_summary
ORDER BY transaction_month;


-- Query 5 — Month-over-Month Transaction Growth

SELECT
    transaction_month,
    monthly_transaction_amount,
    previous_month_amount,

    ROUND(
        (
            (monthly_transaction_amount - previous_month_amount)
            * 100.0
            / NULLIF(previous_month_amount, 0)
        )::numeric,
        2
    ) AS growth_percentage

FROM (
    SELECT
        transaction_month,
        monthly_transaction_amount,

        LAG(monthly_transaction_amount) OVER (
            ORDER BY transaction_month
        ) AS previous_month_amount

    FROM (
        SELECT
            DATE_TRUNC('month', transaction_date)::date AS transaction_month,
            ROUND(SUM(amount)::numeric, 2) AS monthly_transaction_amount
        FROM transactions_clean
        GROUP BY transaction_month
    ) AS monthly_summary
) AS growth_summary
ORDER BY transaction_month;