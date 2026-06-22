-- =============================================================================
-- Task 2: Create the EXPENSE table
-- =============================================================================
-- Loads expense receipts from finance/receipts_from_last_night/ into SExI.
-- Employee names are resolved to their employee_id from the EMPLOYEE table.
--
-- Source receipts and their mappings:
--   drinkies.txt            -> Alex Jacobson   (employee_id = 3)  6.50  x 14
--   drinks.txt              -> Alex Jacobson   (employee_id = 3)  11.00 x 20
--   drinkss.txt             -> Alex Jacobson   (employee_id = 3)  22.00 x 18
--   duh_i_think_i_got_..    -> Alex Jacobson   (employee_id = 3)  13.00 x 75
--   i_got_lost_on_the_..    -> Andrea Ghibaudi (employee_id = 9)  300.00 x 1
--   ubers.txt               -> Darren Poynton  (employee_id = 4)  40.00 x 9
--   we_stopped_for_a_..     -> Umberto Torrielli (employee_id = 2) 17.50 x 4
-- =============================================================================

USE memory.default;

CREATE TABLE EXPENSE AS
SELECT
    employee_id,
    unit_price,
    quantity
FROM (
    VALUES
        -- drinkies.txt: Alex Jacobson - "Drinks, lots of drinks"
        (CAST(3 AS TINYINT), CAST(6.50  AS DECIMAL(8,2)), CAST(14 AS TINYINT)),
        -- drinks.txt: Alex Jacobson - "More Drinks"
        (CAST(3 AS TINYINT), CAST(11.00 AS DECIMAL(8,2)), CAST(20 AS TINYINT)),
        -- drinkss.txt: Alex Jacobson - "So Many Drinks!"
        (CAST(3 AS TINYINT), CAST(22.00 AS DECIMAL(8,2)), CAST(18 AS TINYINT)),
        -- duh_i_think_i_got_too_many.txt: Alex Jacobson - "I bought everyone in the bar a drink!"
        (CAST(3 AS TINYINT), CAST(13.00 AS DECIMAL(8,2)), CAST(75 AS TINYINT)),
        -- i_got_lost_on_the_way_home_and_now_im_in_mexico.txt: Andrea Ghibaudi - "Flights from Mexico back to New York"
        (CAST(9 AS TINYINT), CAST(300.00 AS DECIMAL(8,2)), CAST(1  AS TINYINT)),
        -- ubers.txt: Darren Poynton - "Ubers to get us all home"
        (CAST(4 AS TINYINT), CAST(40.00 AS DECIMAL(8,2)), CAST(9  AS TINYINT)),
        -- we_stopped_for_a_kebabs.txt: Umberto Torrielli - "I had too much fun and needed something to eat"
        (CAST(2 AS TINYINT), CAST(17.50 AS DECIMAL(8,2)), CAST(4  AS TINYINT))
) AS t(employee_id, unit_price, quantity);
