-- =============================================================================
-- Task 5: Calculate the largest expensors (> 1000 threshold)
-- =============================================================================
-- Reports employees whose total expensed amount exceeds 1000, along with
-- their manager's details. Ordered by total_expensed_amount descending.
--
-- Expense totals in the current dataset:
--   Alex Jacobson (3):   6.50*14 + 11.00*20 + 22.00*18 + 13.00*75 = 1682.00
--   Darren Poynton (4):  40.00 * 9  = 360.00
--   Andrea Ghibaudi (9): 300.00 * 1 = 300.00
--   Umberto Torrielli (2): 17.50 * 4 = 70.00
--
-- Only Alex Jacobson exceeds the 1000 threshold.
-- =============================================================================

USE memory.default;

SELECT
    emp.employee_id,
    CONCAT(emp.first_name, ' ', emp.last_name)  AS employee_name,
    emp.manager_id,
    CONCAT(mgr.first_name, ' ', mgr.last_name)  AS manager_name,
    expense_totals.total_expensed_amount
FROM (
    -- Aggregate each employee's expenses: unit_price * quantity per line item
    SELECT
        ex.employee_id,
        SUM(ex.unit_price * ex.quantity)         AS total_expensed_amount
    FROM EXPENSE ex
    GROUP BY ex.employee_id
    HAVING SUM(ex.unit_price * ex.quantity) > 1000
) expense_totals
JOIN EMPLOYEE emp ON expense_totals.employee_id = emp.employee_id
JOIN EMPLOYEE mgr ON emp.manager_id = mgr.employee_id
ORDER BY expense_totals.total_expensed_amount DESC;
