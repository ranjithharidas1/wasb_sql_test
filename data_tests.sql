-- =============================================================================
-- Data Tests: Validation queries for the SExI database
-- =============================================================================
-- Each test returns a status of 'PASS' or 'FAIL' with a description.
-- Run these after executing all create_*.sql files to verify data integrity
-- and correctness of the analytical queries.
-- =============================================================================

USE memory.default;

-- =============================================================================
-- SECTION 1: EMPLOYEE table tests
-- =============================================================================

-- Test 1.1: Correct row count (9 employees in the CSV)
SELECT
    'Test 1.1: EMPLOYEE row count = 9' AS test_name,
    CASE WHEN COUNT(*) = 9 THEN 'PASS' ELSE 'FAIL' END AS result
FROM EMPLOYEE;

-- Test 1.2: No NULL employee_ids
SELECT
    'Test 1.2: No NULL employee_ids' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM EMPLOYEE
WHERE employee_id IS NULL;

-- Test 1.3: No NULL manager_ids (every employee has a manager in this dataset)
SELECT
    'Test 1.3: No NULL manager_ids' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM EMPLOYEE
WHERE manager_id IS NULL;

-- Test 1.4: All employee_ids are unique
SELECT
    'Test 1.4: employee_ids are unique' AS test_name,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT employee_id) THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM EMPLOYEE;

-- Test 1.5: All manager_ids reference a valid employee
SELECT
    'Test 1.5: All manager_ids reference valid employees' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM EMPLOYEE e
WHERE NOT EXISTS (
    SELECT 1 FROM EMPLOYEE m WHERE m.employee_id = e.manager_id
);

-- =============================================================================
-- SECTION 2: EXPENSE table tests
-- =============================================================================

-- Test 2.1: Correct row count (7 receipt items across all files)
SELECT
    'Test 2.1: EXPENSE row count = 7' AS test_name,
    CASE WHEN COUNT(*) = 7 THEN 'PASS' ELSE 'FAIL' END AS result
FROM EXPENSE;

-- Test 2.2: All expense employee_ids exist in EMPLOYEE table
SELECT
    'Test 2.2: All expense employee_ids are valid' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM EXPENSE ex
WHERE NOT EXISTS (
    SELECT 1 FROM EMPLOYEE e WHERE e.employee_id = ex.employee_id
);

-- Test 2.3: All unit_prices are positive
SELECT
    'Test 2.3: All unit_prices are positive' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM EXPENSE
WHERE unit_price <= 0;

-- Test 2.4: All quantities are positive
SELECT
    'Test 2.4: All quantities are positive' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM EXPENSE
WHERE quantity <= 0;

-- Test 2.5: Alex Jacobson's total expenses equal 1682.00
SELECT
    'Test 2.5: Alex Jacobson total = 1682.00' AS test_name,
    CASE
        WHEN SUM(unit_price * quantity) = CAST(1682.00 AS DECIMAL(8,2))
        THEN 'PASS' ELSE 'FAIL'
    END AS result
FROM EXPENSE
WHERE employee_id = 3;

-- =============================================================================
-- SECTION 3: SUPPLIER and INVOICE table tests
-- =============================================================================

-- Test 3.1: Correct supplier count (5 unique suppliers)
SELECT
    'Test 3.1: SUPPLIER row count = 5' AS test_name,
    CASE WHEN COUNT(*) = 5 THEN 'PASS' ELSE 'FAIL' END AS result
FROM SUPPLIER;

-- Test 3.2: Correct invoice count (6 invoices)
SELECT
    'Test 3.2: INVOICE row count = 6' AS test_name,
    CASE WHEN COUNT(*) = 6 THEN 'PASS' ELSE 'FAIL' END AS result
FROM INVOICE;

-- Test 3.3: All invoice supplier_ids exist in SUPPLIER table
SELECT
    'Test 3.3: All invoice supplier_ids are valid' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM INVOICE i
WHERE NOT EXISTS (
    SELECT 1 FROM SUPPLIER s WHERE s.supplier_id = i.supplier_id
);

-- Test 3.4: All due_dates are the last day of their respective month
SELECT
    'Test 3.4: All due_dates are last day of month' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL'
    END AS result
FROM INVOICE
WHERE due_date <> last_day_of_month(due_date);

-- Test 3.5: All due_dates are in the future
SELECT
    'Test 3.5: All due_dates are after today' AS test_name,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM INVOICE
WHERE due_date <= current_date;

-- Test 3.6: Supplier IDs are assigned in alphabetical order of name
SELECT
    'Test 3.6: Supplier IDs match alphabetical ordering' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL'
    END AS result
FROM (
    SELECT
        supplier_id,
        ROW_NUMBER() OVER (ORDER BY name) AS expected_id
    FROM SUPPLIER
) ranked
WHERE supplier_id <> expected_id;

-- Test 3.7: Total invoice value matches source data (20000)
SELECT
    'Test 3.7: Total invoice amount = 20000' AS test_name,
    CASE
        WHEN SUM(invoice_ammount) = CAST(20000.00 AS DECIMAL(8,2))
        THEN 'PASS' ELSE 'FAIL'
    END AS result
FROM INVOICE;

-- =============================================================================
-- SECTION 4: Manager cycle detection tests
-- =============================================================================

-- Test 4.1: Exactly 3 employees are in a cycle (Ian, Umberto, Darren)
WITH RECURSIVE manager_chain AS (
    SELECT
        e.employee_id AS start_id,
        e.manager_id  AS current_id,
        ARRAY[e.employee_id] AS visited
    FROM EMPLOYEE e
    UNION ALL
    SELECT
        mc.start_id,
        e.manager_id,
        mc.visited || mc.current_id
    FROM manager_chain mc
    JOIN EMPLOYEE e ON mc.current_id = e.employee_id
    WHERE NOT CONTAINS(mc.visited, mc.current_id)
)
SELECT
    'Test 4.1: Exactly 3 employees in cycle' AS test_name,
    CASE WHEN COUNT(*) = 3 THEN 'PASS' ELSE 'FAIL' END AS result
FROM manager_chain
WHERE current_id = start_id;

-- Test 4.2: The cycle members are employees 1, 2, and 4
WITH RECURSIVE manager_chain AS (
    SELECT
        e.employee_id AS start_id,
        e.manager_id  AS current_id,
        ARRAY[e.employee_id] AS visited
    FROM EMPLOYEE e
    UNION ALL
    SELECT
        mc.start_id,
        e.manager_id,
        mc.visited || mc.current_id
    FROM manager_chain mc
    JOIN EMPLOYEE e ON mc.current_id = e.employee_id
    WHERE NOT CONTAINS(mc.visited, mc.current_id)
)
SELECT
    'Test 4.2: Cycle members are {1, 2, 4}' AS test_name,
    CASE
        WHEN ARRAY_SORT(ARRAY_AGG(start_id)) = ARRAY[CAST(1 AS TINYINT), CAST(2 AS TINYINT), CAST(4 AS TINYINT)]
        THEN 'PASS' ELSE 'FAIL'
    END AS result
FROM manager_chain
WHERE current_id = start_id;

-- =============================================================================
-- SECTION 5: Largest expensors query tests
-- =============================================================================

-- Test 5.1: Only 1 employee exceeds the 1000 threshold
SELECT
    'Test 5.1: 1 employee exceeds 1000 threshold' AS test_name,
    CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT employee_id
    FROM EXPENSE
    GROUP BY employee_id
    HAVING SUM(unit_price * quantity) > 1000
) overbudget;

-- Test 5.2: The offender is employee_id 3 (Alex Jacobson)
SELECT
    'Test 5.2: Offender is employee_id = 3' AS test_name,
    CASE WHEN employee_id = 3 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT employee_id
    FROM EXPENSE
    GROUP BY employee_id
    HAVING SUM(unit_price * quantity) > 1000
) overbudget;

-- =============================================================================
-- SECTION 6: Payment plan tests
-- =============================================================================

-- Test 6.1: Each supplier's final balance is 0 (all invoices fully paid)
WITH invoice_schedule AS (
    SELECT
        i.supplier_id,
        s.name AS supplier_name,
        i.invoice_ammount,
        CAST(date_diff('month', last_day_of_month(current_date), i.due_date) AS INTEGER) AS num_payments
    FROM INVOICE i
    JOIN SUPPLIER s ON i.supplier_id = s.supplier_id
),
monthly_instalments AS (
    SELECT
        sch.supplier_id,
        last_day_of_month(date_add('month', m.month_offset, current_date)) AS payment_date,
        CASE
            WHEN m.month_offset < sch.num_payments - 1
                THEN ROUND(sch.invoice_ammount / sch.num_payments, 2)
            ELSE sch.invoice_ammount
                 - ROUND(sch.invoice_ammount / sch.num_payments, 2) * (sch.num_payments - 1)
        END AS instalment
    FROM invoice_schedule sch
    CROSS JOIN UNNEST(SEQUENCE(0, sch.num_payments - 1)) AS m(month_offset)
)
SELECT
    'Test 6.1: All suppliers end with 0 balance' AS test_name,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL'
    END AS result
FROM (
    SELECT supplier_id, SUM(instalment) AS total_paid
    FROM monthly_instalments
    GROUP BY supplier_id
) paid
JOIN (
    SELECT supplier_id, SUM(invoice_ammount) AS total_owed
    FROM INVOICE
    GROUP BY supplier_id
) owed ON paid.supplier_id = owed.supplier_id
WHERE paid.total_paid <> owed.total_owed;

-- Test 6.2: Catering Plus has exactly 3 payment months
WITH invoice_schedule AS (
    SELECT
        i.supplier_id,
        i.invoice_ammount,
        CAST(date_diff('month', last_day_of_month(current_date), i.due_date) AS INTEGER) AS num_payments
    FROM INVOICE i
    WHERE i.supplier_id = 1
),
monthly_instalments AS (
    SELECT
        sch.supplier_id,
        last_day_of_month(date_add('month', m.month_offset, current_date)) AS payment_date,
        CASE
            WHEN m.month_offset < sch.num_payments - 1
                THEN ROUND(sch.invoice_ammount / sch.num_payments, 2)
            ELSE sch.invoice_ammount
                 - ROUND(sch.invoice_ammount / sch.num_payments, 2) * (sch.num_payments - 1)
        END AS instalment
    FROM invoice_schedule sch
    CROSS JOIN UNNEST(SEQUENCE(0, sch.num_payments - 1)) AS m(month_offset)
)
SELECT
    'Test 6.2: Catering Plus has 3 payment months' AS test_name,
    CASE
        WHEN COUNT(DISTINCT payment_date) = 3 THEN 'PASS' ELSE 'FAIL'
    END AS result
FROM monthly_instalments;
