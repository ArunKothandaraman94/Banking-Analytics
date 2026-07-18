---------------------------------------------------------
--1. Account table
select *
from account;

--check table structure
select column_name,data_type
from information_schema.columns
where table_name = 'account';

--count records
select *
from account a 

--check for null values
select count(*),count(account_id) as account_id,
       count(district_id) as  district_id,
       count(frequency) as frequency,
       count(account_open_date) as account_open_date
from account a 

--check for dublicate account id
select account_id, count(*) as cnt
from account a 
group by 1
having count(*)>1


--2.Client table-------------------------------------------------------------


-- View sample data
SELECT *
FROM client
LIMIT 10;


-- Check column data types
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'client'
ORDER BY ordinal_position;


-- Check total clients
SELECT COUNT(*) AS total_clients
FROM client;


-- Check for missing values
SELECT
    COUNT(*) AS total_rows,
    COUNT(client_id) AS client_id_count,
    COUNT(birth_number) AS birth_number_count,
    COUNT(district_id) AS district_id_count
FROM client;


-- Check duplicate client IDs
SELECT
    client_id,
    COUNT(*) AS duplicate_count
FROM client
GROUP BY client_id
HAVING COUNT(*) > 1;

--sperate the client birth number
select client_id,birth_number,district_id,1900+birth_year as birth_year,
       case when birth_month > 50 then birth_month-50 else birth_month end actual_birth_month ,
       case when birth_month > 50 then 'female' else 'male' end as gender,
       birth_day
from(
select client_id,birth_number,district_id,
	   substring(birth_number::text,1,2)::integer as birth_year,
	   substring(birth_number::text,3,2)::integer as birth_month,
	   substring(birth_number::text,5,2)::integer as birth_day
from client
)a
;
--final cleaned data of client table
DROP TABLE IF EXISTS client_clean;
create table client_clean as 
select *, make_date(birth_year,birth_month,birth_day) as birth_date
from(
select client_id,district_id,birth_year,
		 case when birth_month > 50 then birth_month-50 else birth_month end as birth_month, 
		 birth_day,
	     case when birth_month > 50 then 'female' else 'male' end as gender
from(
select client_id,birth_number,district_id,
	   1900+substring(birth_number::text,1,2)::integer as birth_year,
	   substring(birth_number::text,3,2)::integer as birth_month,
	   substring(birth_number::text,5,2)::integer as birth_day
from client 
    )as a
    )as b
 ;

select *
from client_clean;


--------------------------------------------------------------------------------------------
--3 DISP TABLE
--check sample data
select *
from disp d ;

--check column names and data types
select column_name, data_type
from information_schema.columns
where table_name = 'disp';

SELECT COUNT(*) AS total_dispositions
FROM disp;

-- Check for null values
SELECT
    COUNT(*) AS total_rows,
    COUNT(disp_id) AS disp_id_count,
    COUNT(client_id) AS client_id_count,
    COUNT(account_id) AS account_id_count,
    COUNT(type) AS type_count
FROM disp;

-- Check duplicate disposition IDs
SELECT
    disp_id,
    COUNT(*) AS duplicate_count
FROM disp
GROUP BY disp_id
HAVING COUNT(*) > 1;

-- See the different relationship types
SELECT
    type,
    COUNT(*) AS total_records
FROM disp
GROUP BY type
ORDER BY total_records DESC;


------------------------------------------------------------------------
-- 4. CARD TABLE

-- View sample records
SELECT *
FROM card
LIMIT 10;


-- Check column names and data types
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'card'
ORDER BY ordinal_position;


-- Count total cards
SELECT COUNT(*) AS total_cards
FROM card;


-- Check for null values
SELECT
    COUNT(*) AS total_rows,
    COUNT(card_id) AS card_id_count,
    COUNT(disp_id) AS disp_id_count,
    COUNT(type) AS card_type_count,
    COUNT(issued) AS issued_date_count
FROM card;


-- Check duplicate card IDs
SELECT
    card_id,
    COUNT(*) AS duplicate_count
FROM card
GROUP BY card_id
HAVING COUNT(*) > 1;


-- Check card types
SELECT
    type,
    COUNT(*) AS total_cards
FROM card
GROUP BY type
ORDER BY total_cards DESC;

--final cleaned data of card table
create table card_clean as 
select card_id, disp_id,type,
       to_date('19'||left(issued,6),'yyyymmdd') as issued_date
from card;

select *
from card_clean;

--------------------------------------------------------------------
--5.Loan table

--sample data
SELECT *
FROM loan
LIMIT 10;

--check table structure
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'loan'
ORDER BY ordinal_position;

--count records
SELECT COUNT(*) AS total_loans
FROM loan;

--check null values
SELECT
    COUNT(*) AS total_rows,
    COUNT(loan_id) AS loan_id_count,
    COUNT(account_id) AS account_id_count,
    COUNT(date) AS loan_date_count,
    COUNT(amount) AS amount_count,
    COUNT(duration) AS duration_count,
    COUNT(payments) AS payments_count,
    COUNT(status) AS status_count
FROM loan;

--check duplicate loan id
SELECT
    loan_id,
    COUNT(*) AS duplicate_count
FROM loan
GROUP BY loan_id
HAVING COUNT(*) > 1;

--cheack loan status
SELECT
    status,
    COUNT(*) AS total_loans
FROM loan
GROUP BY status
ORDER BY total_loans DESC;

---
SELECT
    loan_id,
    date
FROM loan
LIMIT 10;

--change date format to yyyymmdd


create table loan_clean as 
select loan_id,
       account_id, 
	   TO_DATE('19'|| date::text,'YYYYMMDD') as loan_date,
	   amount,
	   duration,
	   payments,
	   status
from loan ;

----------------------------------------------------------------------------
--6.Tranasctions table -

--Step 1 - Explore the table
select *
from transactions 
limit 10 ;

--Step 2 - Check structure
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'transactions'
ORDER BY ordinal_position;

--Step 3 - Count records
SELECT COUNT(*)
FROM transactions;

--Step 4 - Check NULL values
SELECT
    COUNT(*) AS total_rows,
    COUNT(trans_id) AS trans_id_count,
    COUNT(account_id) AS account_id_count,
    COUNT(date) AS date_count,
    COUNT(type) AS type_count,
    COUNT(operation) AS operation_count,
    COUNT(amount) AS amount_count,
    COUNT(balance) AS balance_count,
    COUNT(k_symbol) AS k_symbol_count,
    COUNT(bank) AS bank_count,
    COUNT(account) AS account_count
FROM transactions;

--Step 5 - Check duplicate transaction IDs
SELECT
    trans_id,
    COUNT(*)
FROM transactions
GROUP BY trans_id
HAVING COUNT(*) > 1;



DROP TABLE IF EXISTS transactions_clean;

CREATE TABLE transactions_clean AS

SELECT
    trans_id,
    account_id,
    TO_DATE('19'||date::TEXT,'YYYYMMDD') AS transaction_date,
    type,
    operation,
    amount,
    balance,
    k_symbol,
    bank,
    account
FROM transactions;

select *
from transactions_clean;

------------------------------------------------------------------------------------
--7.Orders Table
SELECT *
FROM orders
LIMIT 10;

--Step 2 - Check structure
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;

--Step 3 - Check NULL values
SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_count,
    COUNT(account_id) AS account_id_count,
    COUNT(bank_to) AS bank_to_count,
    COUNT(account_to) AS account_to_count,
    COUNT(amount) AS amount_count,
    COUNT(k_symbol) AS k_symbol_count
FROM orders;

--step4 - Check duplicates
SELECT
    order_id,
    COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--8.District
DROP TABLE IF EXISTS district_clean;

CREATE TABLE district_clean AS

SELECT
    a1 AS district_id,
    a2 AS district_name,
    a3 AS region,
    a4 AS population,
    a5 AS municipalities_lt_500,
    a6 AS municipalities_500_1999,
    a7 AS municipalities_2000_9999,
    a8 AS municipalities_ge_10000,
    a9 AS number_of_cities,
    a10 AS urban_population_percent,
    a11 AS average_salary,
    a12 AS unemployment_rate_1995,
    a13 AS unemployment_rate_1996,
    a14 AS entrepreneurs_per_1000,
    a15 AS crimes_1995,
    a16 AS crimes_1996
FROM district;

select *
from district_clean;

