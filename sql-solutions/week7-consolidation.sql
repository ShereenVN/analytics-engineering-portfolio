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



------------------------------------------------------------------------------------------------------------------------------------
--Wednesday — LAG + Mixed Concepts 

--Problem 1: "Y-on-Y Growth Rate" (Wayfair Hard)
--Step 1: Calculate the total spend per product per year.
--Step 2: Add previous year's spend using LAG
--Step 3: Calculate the growth percentage

WITH total_spend_per_year AS (
  SELECT
    EXTRACT(YEAR FROM transaction_date) AS d_year,
    product_id,
    SUM(spend) AS total_spend
  FROM user_transactions
  GROUP BY product_id, d_year
),
total_spend_prev_year AS (
  SELECT
    d_year,
    product_id,
    total_spend,
    LAG(total_spend) OVER (PARTITION BY product_id ORDER BY d_year) AS prev_year
  FROM total_spend_per_year
)
SELECT
  d_year AS year,
  product_id,
  total_spend AS curr_year_spend,
  prev_year AS prev_year_spend,
  ROUND((total_spend-prev_year) / prev_year *100, 2) AS yoy_rate
FROM total_spend_prev_year
ORDER BY product_id, d_year;


--Problem 2: "Server Utilization Time" (Amazon Hard)
--Step 1: Pair each start time with its corresponding stop time per server
--Step 2: Calculate uptime per session
--Step 3: SUM all durations and convert to full days

WITH session_time AS (
  SELECT
    server_id,
    status_time,
    session_status,
    LEAD(status_time) OVER (PARTITION BY server_id ORDER BY status_time) AS server_session
  FROM server_utilization
),
uptime_session AS (
  SELECT
    server_id,
    status_time,
    server_session,
    EXTRACT(EPOCH FROM (server_session - status_time)) AS uptime
  FROM session_time
  WHERE session_status = 'start'
)
SELECT
  FLOOR(SUM(uptime)/86400) AS total_uptime_days
FROM uptime_session;


--Problem 3: "Histogram of Users and Purchases" (Walmart Medium)
--Step 1: Find the most recent transaction date per user
--Step 2: Calculate the number of products bought on that specific date

WITH recent_transaction AS (
  SELECT
    user_id,
    MAX(transaction_date) AS recent_date
  FROM user_transactions
  GROUP BY user_id
)
SELECT
  recent_date,
  recent_transaction.user_id,
  COUNT(user_transactions.product_id) AS purchase_count
FROM recent_transaction
JOIN user_transactions ON recent_transaction.user_id = user_transactions.user_id
AND user_transactions.transaction_date = recent_transaction.recent_date
GROUP BY recent_date, recent_transaction.user_id
ORDER BY recent_date


--https://pgexercises.com/questions/aggregates/countmembers.html
--Question
--Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members. 

SELECT
	COUNT(memid) OVER () AS count,
	firstname,
	surname
FROM cd.members
ORDER BY joindate



------------------------------------------------------------------------------------------------------------------------------------
--Thursday — The Hard Ones

--Problem 1: "Median Google Search Frequency" (Google Hard)
--Step 1: CTE that created an expanded list of all searches for the amount of users.
--Step 2: Calculate the median using 50th percentile and then use decimals to round it to one decimal.

WITH expanded AS (
  SELECT searches
  FROM search_frequency
  JOIN GENERATE_SERIES(1, num_users) ON true
)
SELECT ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY searches)::DECIMAL, 1) AS median
FROM expanded


--Problem 2: "Active User Retention" (Facebook Hard)
--Step 1: A CTE to calculate the activities in july
--Step 2: A CTE to calculate the activities in june
--Step 3: Select distinct users that are in both CTE's.

WITH activity_july AS (
  SELECT
    DISTINCT user_id
  FROM user_actions
  WHERE EXTRACT(MONTH FROM event_date) = 7
  AND EXTRACT(YEAR FROM event_date) = 2022
),
activity_june AS (
  SELECT
    DISTINCT user_id
  FROM user_actions
  WHERE EXTRACT(MONTH FROM event_date) = 6
  AND EXTRACT(YEAR FROM event_date) = 2022
)
SELECT
  7 AS month,
  COUNT(DISTINCT activity_july.user_id) AS monthly_active_users
FROM activity_july
JOIN activity_june ON activity_july.user_id = activity_june.user_id


--Problem 3: "International Call Percentage" (Verizon Medium)
-- Already completed this and the code is still in Datalemur.



------------------------------------------------------------------------------------------------------------------------------------
--Friday — Full Challenge Day


--Problem 1: "Second Highest Salary" (FAANG Medium)
--Step 1: Rank the salaries in a CTE
--Step 2: Select the second highest salary by filtering for rank 2

WITH ranked_salary AS (
  SELECT
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS rank_salary
  FROM employee
)
SELECT
 salary AS second_highest_salary
FROM ranked_salary
WHERE rank_salary = 2


