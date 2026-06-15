--Exercise A: ROW_NUMBER basics
--ROW_NUMBER gives each row a unique number (1, 2, 3...) within its group.
--Scenario: Number each employee's salary ranking within their department.

SELECT 
    name,
    department,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY salary        -- Group by what? Each department separately
        ORDER BY department DESC       -- Order by what? Highest salary first
    ) AS salary_rank
FROM employees;



--Exercise B: ROW_NUMBER in a CTE — "Get the top 1 per group"
--This is the most common real-world pattern: "Get the most recent ___ per ___" or "Get the highest ___ per ___."
--Scenario: Find each customer's most expensive purchase.

WITH ranked_purchases AS (
    SELECT 
        customer_id,
        product_name,
        amount,
        purchase_date,
        ROW_NUMBER() OVER (
            PARTITION BY amount            -- One ranking per ___
            ORDER BY amount DESC           -- Most expensive first
        ) AS purchase_rank
    FROM purchases
)

SELECT customer_id, product_name, amount, purchase_date
FROM ranked_purchases
WHERE purchase_rank = 1;  -- Only the top one



--Exercise C: DENSE_RANK — "Top N with ties"
--DENSE_RANK is like ROW_NUMBER, but when two rows have the same value, they get the same rank, and the next rank is not skipped.

--ROW_NUMBER:  1, 2, 3, 4, 5    (always unique, even for ties)
--RANK:        1, 2, 2, 4, 5    (ties get same rank, next rank is SKIPPED)
--DENSE_RANK:  1, 2, 2, 3, 4    (ties get same rank, next rank is NOT skipped)

--When to use which:
--ROW_NUMBER: "Give me exactly the top 3 rows" (even if there are ties)
--DENSE_RANK: "Give me all items that are in the top 3 ranks" (might return more than 3 rows if there are ties)

--Scenario: Rank products by total sales. Products with the same sales should share a rank.

WITH product_sales AS (
    SELECT 
        product_name,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY product_name
),

ranked AS (
    SELECT 
        product_name,
        total_sales,
        DENSE_RANK() OVER (
            ORDER BY total_sales DESC    -- Rank by what? Highest sales first
        ) AS sales_rank
    FROM product_sales
)

SELECT product_name, total_sales, sales_rank
FROM ranked
WHERE sales_rank <= 3;  -- Top 3 ranks



--Exercise D: DataLemur — "User's Third Transaction" (Uber Medium)
--You solved this last week with scaffolding. Now fill in this template from memory:

WITH numbered AS (
SELECT 
  user_id,
  spend,
  transaction_date,
  ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date) AS txn_number
FROM transactions
)
SELECT user_id, spend, transaction_date
FROM numbered
WHERE txn_number = 3;



