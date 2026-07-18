-- ==========================================================
-- Czech Banking Analytics
-- 01_database_setup.sql
-- ==========================================================

-- Create the project database
CREATE DATABASE czech_banking_db;


-- ==========================================================
-- After creating the database:
-- 1. Connect to czech_banking_db
-- 2. Import all CSV files using DBeaver
--
-- account.csv
-- client.csv
-- disp.csv
-- district.csv
-- loan.csv
-- card.csv
-- order.csv
-- trans.csv
-- ==========================================================


-- Rename tables for easier querying

ALTER TABLE "order"
RENAME TO orders;

ALTER TABLE trans
RENAME TO transactions;


-- Check whether all tables are imported

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;


-- Check the number of records in each table

SELECT 'account' AS table_name, COUNT(*) AS total_rows
FROM account

UNION ALL

SELECT 'client', COUNT(*)
FROM client

UNION ALL

SELECT 'disp', COUNT(*)
FROM disp

UNION ALL

SELECT 'district', COUNT(*)
FROM district

UNION ALL

SELECT 'loan', COUNT(*)
FROM loan

UNION ALL

SELECT 'card', COUNT(*)
FROM card

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'transactions', COUNT(*)
FROM transactions;