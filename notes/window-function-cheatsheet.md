-- GROUP BY collapses rows (5 departments → 5 rows)
SELECT department, AVG(salary) FROM employees GROUP BY department;

-- Window function KEEPS all rows but adds the calculation
SELECT 
    name,
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) AS dept_avg_salary
FROM employees;
-- This returns EVERY employee row, but with their department's average added

-- 1. ROW_NUMBER: unique number per row within each group
ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC)
-- Always gives 1, 2, 3, 4... (no ties)

-- 2. RANK: allows ties, but skips numbers
RANK() OVER (PARTITION BY department ORDER BY salary DESC)
-- Can give 1, 2, 2, 4 (two people tied for 2nd, no 3rd)

-- 3. DENSE_RANK: allows ties, no gaps
DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC)
-- Gives 1, 2, 2, 3 (two people tied for 2nd, next is 3rd)

-- 4. LAG: look at the PREVIOUS row's value
LAG(salary, 1) OVER (PARTITION BY department ORDER BY hire_date)
-- "What was the salary of the person hired before me in my department?"

-- 5. LEAD: look at the NEXT row's value
LEAD(salary, 1) OVER (PARTITION BY department ORDER BY hire_date)
-- "What is the salary of the person hired after me in my department?"

A window function does a calculation across rows WITHOUT collapsing them. The syntax is always:
FUNCTION_NAME() OVER (
    PARTITION BY column_to_group_by    -- like GROUP BY but keeps rows
    ORDER BY column_to_sort_by         -- determines the order
)


The pattern you'll use most often in analytics engineering:
-- "Give me the top N items per group"

-- Step 1: Calculate what you need + add a rank
WITH ranked AS (
    SELECT 
        customer_id,
        product,
        amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY amount DESC
        ) AS purchase_rank
    FROM purchases
)

-- Step 2: Filter to top N
SELECT customer_id, product, amount
FROM ranked
WHERE purchase_rank <= 3;