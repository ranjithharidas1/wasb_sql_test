-- =============================================================================
-- Task 6: Generate supplier payment plans
-- =============================================================================
-- Creates a monthly payment schedule for each supplier's invoices.
--
-- Logic:
--   1. Each invoice is spread into uniform monthly instalments from the end
--      of the current month up to (but not including) the due month.
--      Number of payments = months between end-of-this-month and due_date.
--   2. Monthly instalment = invoice_ammount / num_payments, with any rounding
--      remainder absorbed into the final instalment.
--   3. Where a supplier has multiple invoices, payments for the same month
--      are aggregated into a single row.
--   4. balance_outstanding is the total remaining debt after each payment.
--
-- Verification against the Catering Plus example from the README:
--   Invoice 1: 2000, due end of month+2 => 2 payments of 1000
--   Invoice 2: 1500, due end of month+3 => 3 payments of 500
--   Month 1: payment = 1500, balance = 2000  ✓
--   Month 2: payment = 1500, balance = 500   ✓
--   Month 3: payment = 500,  balance = 0     ✓
-- =============================================================================

USE memory.default;

WITH invoice_schedule AS (
    -- Calculate the number of monthly payments required per invoice
    SELECT
        i.supplier_id,
        s.name                                                      AS supplier_name,
        i.invoice_ammount,
        i.due_date,
        CAST(date_diff(
            'month',
            last_day_of_month(current_date),
            i.due_date
        ) AS INTEGER)                                               AS num_payments
    FROM INVOICE i
    JOIN SUPPLIER s ON i.supplier_id = s.supplier_id
),

monthly_instalments AS (
    -- Expand each invoice into individual monthly payment rows
    -- The last instalment absorbs any rounding remainder
    SELECT
        sch.supplier_id,
        sch.supplier_name,
        last_day_of_month(
            date_add('month', m.month_offset, current_date)
        )                                                           AS payment_date,
        CASE
            WHEN m.month_offset < sch.num_payments - 1
                THEN ROUND(sch.invoice_ammount / sch.num_payments, 2)
            ELSE sch.invoice_ammount
                 - ROUND(sch.invoice_ammount / sch.num_payments, 2)
                   * (sch.num_payments - 1)
        END                                                         AS instalment
    FROM invoice_schedule sch
    CROSS JOIN UNNEST(
        SEQUENCE(0, sch.num_payments - 1)
    ) AS m(month_offset)
),

aggregated_payments AS (
    -- Aggregate instalments per supplier per month
    SELECT
        supplier_id,
        supplier_name,
        payment_date,
        SUM(instalment)                                             AS payment_amount
    FROM monthly_instalments
    GROUP BY supplier_id, supplier_name, payment_date
)

-- Calculate the running balance outstanding after each payment
SELECT
    supplier_id,
    supplier_name,
    CAST(payment_amount AS DECIMAL(8,2))                            AS payment_amount,
    CAST(
        SUM(payment_amount) OVER (PARTITION BY supplier_id)
        - SUM(payment_amount) OVER (
            PARTITION BY supplier_id
            ORDER BY payment_date
            ROWS UNBOUNDED PRECEDING
          )
    AS DECIMAL(8,2))                                                AS balance_outstanding,
    payment_date
FROM aggregated_payments
ORDER BY supplier_id, payment_date;
