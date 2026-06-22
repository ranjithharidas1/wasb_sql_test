-- =============================================================================
-- Task 4: Find manager approval cycles
-- =============================================================================
-- Detects cycles in the manager hierarchy where employees ultimately approve
-- each other's expenses. A cycle exists when following the manager_id chain
-- from an employee leads back to that same employee.
--
-- Approach: Use a recursive CTE to walk the manager chain from each employee.
-- If the chain returns to the starting employee, that employee is part of a
-- cycle. The cycle path is captured as a comma-separated list of employee_ids.
--
-- In the current dataset, the cycle is: 1 (Ian) -> 4 (Darren) -> 2 (Umberto) -> 1
-- Ian's manager is Darren, Darren's manager is Umberto, Umberto's manager is Ian.
-- =============================================================================

USE memory.default;

WITH RECURSIVE manager_chain AS (
    -- Base case: start from each employee, step to their manager
    SELECT
        e.employee_id                       AS start_id,
        e.manager_id                        AS current_id,
        ARRAY[e.employee_id]                AS visited
    FROM EMPLOYEE e

    UNION ALL

    -- Recursive step: follow the manager_id chain, stop if we revisit a node
    SELECT
        mc.start_id,
        e.manager_id,
        mc.visited || mc.current_id
    FROM manager_chain mc
    JOIN EMPLOYEE e ON mc.current_id = e.employee_id
    WHERE NOT CONTAINS(mc.visited, mc.current_id)
)
-- Select employees whose manager chain loops back to themselves
SELECT
    start_id                                AS employee_id,
    ARRAY_JOIN(visited || start_id, ',')    AS cycle
FROM manager_chain
WHERE current_id = start_id
ORDER BY employee_id;
