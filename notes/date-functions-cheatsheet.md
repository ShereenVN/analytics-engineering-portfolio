-- Function 1: EXTRACT - Pull out a part of a date:

-- EXTRACT gets a specific part from a date
-- This is the same thing as DATE_PART, just different syntax

SELECT EXTRACT(YEAR FROM '2024-03-15'::DATE);     -- Result: 2024
SELECT EXTRACT(MONTH FROM '2024-03-15'::DATE);    -- Result: 3
SELECT EXTRACT(DAY FROM '2024-03-15'::DATE);      -- Result: 15
SELECT EXTRACT(DOW FROM '2024-03-15'::DATE);      -- Result: 5 (Friday, 0=Sunday)

-- DATE_PART does the same thing with different syntax:
SELECT DATE_PART('year', '2024-03-15'::DATE);     -- Result: 2024
SELECT DATE_PART('month', '2024-03-15'::DATE);    -- Result: 3

-- Pick one and stick with it. I recommend EXTRACT because the syntax is clearer.

-- timestamp vs date
SELECT '2024-03-15 14:30:00'::TIMESTAMP;  -- 2024-03-15 14:30:00
SELECT '2024-03-15 14:30:00'::DATE;       -- 2024-03-15 (time removed)



-- Function 2: DATE_TRUNC - Round down to a time period

-- DATE_TRUNC rounds a date DOWN to the start of a period
SELECT DATE_TRUNC('month', '2024-03-15'::DATE);   -- Result: 2024-03-01
SELECT DATE_TRUNC('year', '2024-03-15'::DATE);    -- Result: 2024-01-01
SELECT DATE_TRUNC('week', '2024-03-15'::DATE);    -- Result: 2024-03-11 (Monday)

-- USE CASE: "Group sales by month"
-- Instead of: GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
-- You can do: GROUP BY DATE_TRUNC('month', sale_date)
-- This is cleaner and gives you a proper date to display



-- Function 3: Date arithmetic — Adding and subtracting

-- Add/subtract days
SELECT '2024-03-15'::DATE + 7;                    -- Result: 2024-03-22
SELECT '2024-03-15'::DATE - 7;                    -- Result: 2024-03-08

-- Subtract two dates to get days between
SELECT '2024-03-15'::DATE - '2024-03-01'::DATE;   -- Result: 14

-- Add intervals for months/years
SELECT '2024-03-15'::DATE + INTERVAL '1 month';   -- Result: 2024-04-15
SELECT '2024-03-15'::DATE + INTERVAL '1 year';    -- Result: 2025-03-15
SELECT '2024-03-15'::DATE + INTERVAL '1 day';     -- Result: 2024-03-16



-- Function 4: TO_CHAR — Format a date as text

-- TO_CHAR converts a date to formatted text
SELECT TO_CHAR('2024-03-15'::DATE, 'Month');       -- Result: 'March'
SELECT TO_CHAR('2024-03-15'::DATE, 'Day');         -- Result: 'Friday'
SELECT TO_CHAR('2024-03-15'::DATE, 'MM-YYYY');     -- Result: '03-2024'
SELECT TO_CHAR('2024-03-15'::DATE, 'DD/MM/YYYY');  -- Result: '15/03/2024'



-- Function 5: CURRENT_DATE / NOW()

SELECT CURRENT_DATE;                               -- Today's date
SELECT NOW();                                      -- Current timestamp
SELECT CURRENT_DATE - INTERVAL '30 days';          -- 30 days ago