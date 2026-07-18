-- ==========================================================
-- 04_BUSINESS_QUESTIONS.SQL
-- ==========================================================


-- Query 1 — Which districts have the highest total transaction value?

SELECT
    d.district_name,
    COUNT(t.trans_id) AS total_transactions,
    ROUND(SUM(t.amount)::numeric, 2) AS total_transaction_amount
FROM transactions_clean t
JOIN account a
    ON t.account_id = a.account_id
JOIN district_clean d
    ON a.district_id = d.district_id
GROUP BY d.district_name
ORDER BY total_transaction_amount DESC
LIMIT 10;


-- Query 2 — Which districts have the highest risky loan percentage?

SELECT
    d.district_name,
    COUNT(l.loan_id) AS total_loans,

    COUNT(
        CASE
            WHEN l.status IN ('B', 'D') THEN 1
        END
    ) AS risky_loans,

    ROUND(
        (
            100.0 *
            COUNT(
                CASE
                    WHEN l.status IN ('B', 'D') THEN 1
                END
            )
            / NULLIF(COUNT(l.loan_id), 0)
        )::numeric,
        2
    ) AS risky_loan_percentage

FROM loan_clean l
JOIN account a
    ON l.account_id = a.account_id
JOIN district_clean d
    ON a.district_id = d.district_id
GROUP BY d.district_name
HAVING COUNT(l.loan_id) >= 5
ORDER BY risky_loan_percentage DESC;


-- Query 3 — Who are the top 10 high-value customers?

SELECT
    c.client_id,
    c.gender,
    d.district_name,
    COUNT(t.trans_id) AS total_transactions,
    ROUND(SUM(t.amount)::numeric, 2) AS total_transaction_amount
FROM client_clean c
JOIN disp dp
    ON c.client_id = dp.client_id
JOIN account a
    ON dp.account_id = a.account_id
JOIN transactions_clean t
    ON a.account_id = t.account_id
JOIN district_clean d
    ON c.district_id = d.district_id
GROUP BY
    c.client_id,
    c.gender,
    d.district_name
ORDER BY total_transaction_amount DESC
LIMIT 10;


-- Query 4 — Which card type is associated with the highest average account balance?

SELECT
    cd.type AS card_type,
    COUNT(DISTINCT cd.card_id) AS total_cards,
    ROUND(AVG(t.balance)::numeric, 2) AS average_balance
FROM card_clean cd
JOIN disp dp
    ON cd.disp_id = dp.disp_id
JOIN transactions_clean t
    ON dp.account_id = t.account_id
GROUP BY cd.type
ORDER BY average_balance DESC;


-- Query 5 — Which customer age group has the highest average loan amount?

SELECT
    customer_age_group,
    COUNT(loan_id) AS total_loans,
    ROUND(AVG(amount)::numeric, 2) AS average_loan_amount,
    ROUND(SUM(amount)::numeric, 2) AS total_loan_amount
FROM (
    SELECT
        l.loan_id,
        l.amount,

        CASE
            WHEN EXTRACT(YEAR FROM AGE(l.loan_date, c.birth_date)) < 30
                THEN 'Below 30'
            WHEN EXTRACT(YEAR FROM AGE(l.loan_date, c.birth_date))
                 BETWEEN 30 AND 45
                THEN '30-45'
            WHEN EXTRACT(YEAR FROM AGE(l.loan_date, c.birth_date))
                 BETWEEN 46 AND 60
                THEN '46-60'
            ELSE 'Above 60'
        END AS customer_age_group

    FROM loan_clean l
    JOIN account a
        ON l.account_id = a.account_id
    JOIN disp dp
        ON a.account_id = dp.account_id
    JOIN client_clean c
        ON dp.client_id = c.client_id

    WHERE dp.type = 'OWNER'
) AS loan_customer_data
GROUP BY customer_age_group
ORDER BY average_loan_amount DESC;


-- ==========================================================
-- 05_BUSINESS_QUESTIONS_PART2.SQL
-- ==========================================================


-- Query 1 — Which districts generate the highest average transaction amount?

SELECT
    d.district_name,
    COUNT(t.trans_id) AS total_transactions,
    ROUND(AVG(t.amount)::numeric,2) AS average_transaction_amount
FROM transactions_clean t
JOIN account a
    ON t.account_id = a.account_id
JOIN district_clean d
    ON a.district_id = d.district_id
GROUP BY d.district_name
ORDER BY average_transaction_amount DESC
LIMIT 10;



-- Query 2 — Which customers have both a loan and a premium (Gold) card?

SELECT
    c.client_id,
    c.gender,
    d.district_name,
    cd.type AS card_type,
    l.amount AS loan_amount
FROM client_clean c
JOIN disp dp
    ON c.client_id = dp.client_id
JOIN account a
    ON dp.account_id = a.account_id
JOIN loan_clean l
    ON a.account_id = l.account_id
JOIN card_clean cd
    ON dp.disp_id = cd.disp_id
JOIN district_clean d
    ON c.district_id = d.district_id
WHERE cd.type = 'gold'
ORDER BY loan_amount DESC;



-- Query 3 — Which districts have the highest average account balance?

SELECT
    d.district_name,
    ROUND(AVG(t.balance)::numeric,2) AS average_balance
FROM transactions_clean t
JOIN account a
    ON t.account_id = a.account_id
JOIN district_clean d
    ON a.district_id = d.district_id
GROUP BY d.district_name
ORDER BY average_balance DESC
LIMIT 10;



-- Query 4 — Which accounts have both the highest balance and highest loan amount?

SELECT
    a.account_id,
    ROUND(MAX(t.balance)::numeric,2) AS highest_balance,
    MAX(l.amount) AS loan_amount
FROM account a
JOIN transactions_clean t
    ON a.account_id = t.account_id
JOIN loan_clean l
    ON a.account_id = l.account_id
GROUP BY a.account_id
ORDER BY highest_balance DESC, loan_amount DESC
LIMIT 10;



-- Query 5 — Customer Financial Summary

SELECT
    c.client_id,
    c.gender,
    d.district_name,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    COUNT(DISTINCT cd.card_id) AS total_cards,
    ROUND(SUM(t.amount)::numeric,2) AS total_transaction_amount
FROM client_clean c
JOIN disp dp
    ON c.client_id = dp.client_id
JOIN account a
    ON dp.account_id = a.account_id
JOIN district_clean d
    ON c.district_id = d.district_id
LEFT JOIN loan_clean l
    ON a.account_id = l.account_id
LEFT JOIN card_clean cd
    ON dp.disp_id = cd.disp_id
LEFT JOIN transactions_clean t
    ON a.account_id = t.account_id
GROUP BY
    c.client_id,
    c.gender,
    d.district_name
ORDER BY total_transaction_amount DESC
LIMIT 20;