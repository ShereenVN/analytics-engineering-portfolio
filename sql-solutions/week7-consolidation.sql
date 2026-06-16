--Monday — JOINs, CASE, and Date Functions

--Problem 1: "Final Account Balance" (Paypal Easy)
SELECT 
  account_id,
  SUM(CASE WHEN transaction_type = 'Deposit' THEN amount ELSE -amount END) as final_balance
  FROM transactions
GROUP BY account_id;


--Problem 2: "Pharmacy Analytics (Part 2)" (CVS Easy)
WITH drug_losses AS (
  SELECT
    manufacturer,
    drug,
    total_sales - cogs AS profit
  FROM pharmacy_sales
  WHERE total_sales - cogs < 0
)
SELECT
  manufacturer,
  COUNT(drug) AS drug_count,
  ABS(SUM(profit)) AS total_loss
FROM drug_losses
GROUP BY manufacturer
ORDER BY total_loss DESC


--Problem 3: "Patient Support Analysis" (UnitedHealth Easy)
WITH policy_calls AS (
SELECT
  policy_holder_id,
  COUNT(case_id) AS call_count
  FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id) >= 3
)
SELECT
  COUNT(policy_holder_id) AS policy_holder_count
FROM policy_calls;


--Problem 4: "Cities With Completed Trades" (Robinhood Easy)
SELECT
  users.city,
  COUNT(trades.order_id) AS total_orders
FROM trades
JOIN users ON trades.user_id = users.user_id
WHERE trades.status = 'Completed'
GROUP BY users.city
ORDER BY total_orders DESC
LIMIT 3;


--Problem 5: "Average Deal Size" (Salesforce Easy)
--This problem was removed from DataLemur, so I cannot solve this, as the medium version of this assignment is behind a paywall.


------------------------------------------------------------------------------------------------------------------------------------
--Tuesday — CTEs + Window Functions: Medium Difficulty

--Problem 1: "Top Three Salaries" (FAANG Medium)
--Step 1: A CTE to join employees and departments, then use dense rank to rank salaries within each department.
--Step 2: Filter to only keep rank <= 3, then sort by department, salary descending and name alphabetically.

WITH ranked_salaries AS (
  SELECT
    department.department_name,
    employee.name,
    employee.salary,
    DENSE_RANK() OVER (PARTITION BY department.department_name ORDER BY employee.salary DESC) as salary_rank
  FROM employee
  JOIN department
  ON department.department_id = employee.department_id
  GROUP BY department.department_name, employee.salary, employee.name
)
SELECT
    department_name,
    name,
    salary
FROM ranked_salaries
WHERE salary_rank <= 3;


--Problem 2: "Tweets' Rolling Averages" (Twitter Medium)
SELECT
  user_id,
  tweet_date,
  ROUND(AVG(tweet_count) OVER (
    PARTITION BY user_id
    ORDER BY tweet_date
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 2) AS rolling_avg_3d
FROM tweets;


--Problem 3: "Supercloud Customer" (Microsoft Medium)
--Step 1: So first we have a CTE with customer IDs andproduct categories.
--Step 2: Then we have a CTE which only outputs the number of distinct categories.
--Step 3: The final query then becomes which of the customers from CTE 1 are equal to CTE 2 when it comes to DISTINCT product categories

WITH sales_list AS (
  SELECT
    customer_contracts.customer_id,
    COUNT(DISTINCT product_category) AS sales_category
  FROM customer_contracts
  JOIN products ON products.product_id = customer_contracts.product_id
  GROUP BY customer_contracts.customer_id
), 
nbr_categories AS (
  SELECT 
    COUNT(DISTINCT product_category) AS num_category
  FROM products
)
SELECT
  customer_id
FROM sales_list, nbr_categories
WHERE sales_category = num_category


--Problem 4: "Card Launch Success" (JPMorgan Medium)
WITH all_dates AS (
  SELECT
    card_name,
    issued_amount,
    MAKE_DATE(issue_year, issue_month, 1) AS release_date
  FROM monthly_cards_issued
),
launch_dates AS (
  SELECT
    card_name,
    MIN(release_date) AS launch_date
  FROM all_dates
  GROUP BY card_name
)
SELECT
  all_dates.card_name,
  all_dates.issued_amount
FROM all_dates
JOIN launch_dates ON all_dates.card_name = launch_dates.card_name
AND all_dates.release_date = launch_dates.launch_date
ORDER BY issued_amount DESC