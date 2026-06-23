-- =============================================================================
-- Task 3: Create the SUPPLIER and INVOICE tables
-- =============================================================================
-- Loads supplier invoices from finance/invoices_due/ into SExI.
--
-- SUPPLIER table: supplier_id assigned alphabetically by company name:
--   1 = Catering Plus
--   2 = Dave's Discos
--   3 = Entertainment tonight
--   4 = Ice Ice Baby
--   5 = Party Animals
--
-- INVOICE table: due_date is set to the last day of the month, calculated
-- relative to the current date using the "N months from now" specification
-- from each invoice file.
--
-- Note: The column name "invoice_ammount" preserves the spelling from the
-- task specification (intentional typo retained for compatibility).
-- =============================================================================

USE memory.default;

-- Drop in dependency order (INVOICE references SUPPLIER)
DROP TABLE IF EXISTS INVOICE;
DROP TABLE IF EXISTS SUPPLIER;

-- Create the SUPPLIER reference table (IDs assigned alphabetically)
CREATE TABLE SUPPLIER (
    supplier_id TINYINT,
    name        VARCHAR
);

INSERT INTO SUPPLIER VALUES
    (CAST(1 AS TINYINT), 'Catering Plus'),
    (CAST(2 AS TINYINT), 'Dave''s Discos'),
    (CAST(3 AS TINYINT), 'Entertainment tonight'),
    (CAST(4 AS TINYINT), 'Ice Ice Baby'),
    (CAST(5 AS TINYINT), 'Party Animals');

-- Create the INVOICE table with due dates as last day of the target month
CREATE TABLE INVOICE (
    supplier_id     TINYINT,
    invoice_ammount DECIMAL(8, 2),
    due_date        DATE
);

INSERT INTO INVOICE VALUES
    -- brilliant_bottles.txt: Catering Plus - Champagne, Whiskey, Vodka, etc. (2 months)
    (CAST(1 AS TINYINT), CAST(2000.00 AS DECIMAL(8,2)),
        last_day_of_month(date_add('month', 2, current_date))),
    -- crazy_catering.txt: Catering Plus - Pizzas, Burgers, Hotdogs, etc. (3 months)
    (CAST(1 AS TINYINT), CAST(1500.00 AS DECIMAL(8,2)),
        last_day_of_month(date_add('month', 3, current_date))),
    -- disco_dj.txt: Dave's Discos - Dave, Dave Equipment (1 month)
    (CAST(2 AS TINYINT), CAST(500.00  AS DECIMAL(8,2)),
        last_day_of_month(date_add('month', 1, current_date))),
    -- excellent_entertainment.txt: Entertainment tonight (3 months)
    (CAST(3 AS TINYINT), CAST(6000.00 AS DECIMAL(8,2)),
        last_day_of_month(date_add('month', 3, current_date))),
    -- fantastic_ice_sculptures.txt: Ice Ice Baby - Ice Luge, sculpture (6 months)
    (CAST(4 AS TINYINT), CAST(4000.00 AS DECIMAL(8,2)),
        last_day_of_month(date_add('month', 6, current_date))),
    -- awesome_animals.txt: Party Animals - Zebra, Lion, Giraffe, Hippo (3 months)
    (CAST(5 AS TINYINT), CAST(6000.00 AS DECIMAL(8,2)),
        last_day_of_month(date_add('month', 3, current_date)));
