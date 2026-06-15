--"Histogram of Tweets" (Twitter Easy)
--time: 2 min

WITH user_tweet_count AS (
SELECT user_id, COUNT(tweet_id) AS tweet_count
FROM tweets
WHERE EXTRACT(YEAR FROM tweet_date) = 2022
GROUP BY user_id
)
SELECT tweet_count, COUNT(user_id) as num_users
FROM user_tweet_count
GROUP BY tweet_count
ORDER BY tweet_count



--"App Click-through Rate" (Facebook Easy)
--time: 6 minutes

WITH event_counts AS (
SELECT app_id,
  SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) AS clicks,
  SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END) AS impressions
FROM events
WHERE DATE_PART('year', timestamp::DATE) = 2022
GROUP BY app_id
)
SELECT app_id,
  ROUND(100.0 * clicks / impressions, 2) AS ctr
FROM event_counts;



--"User's Third Transaction" (Uber Medium) 
--time: 7 minutes

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


------------------------------------------------------------------------------------------
--Step 3 (75 min): Re-do the Week 5 fill-in-the-blank exercises with correct PARTITION BY


--Exercise A: ROW_NUMBER basics
--ROW_NUMBER gives each row a unique number (1, 2, 3...) within its group.
--Scenario: Number each employee's salary ranking within their department.

SELECT 
    name,
    department,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department        -- Group by what? Each department separately
        ORDER BY salary DESC       -- Order by what? Highest salary first
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
            PARTITION BY customer_id            -- One ranking per ___
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

--Afternoon Block (12:30 – 15:00): Window Functions on pgexercises.com

--1&2: "Produce a list of member names, with each row numbered within ordered by join date"
SELECT
	ROW_NUMBER() OVER (ORDER BY joindate),
	firstname,
	surname
FROM cd.members

--3: "Output the facility id that has the highest number of slots booked, without using a LIMIT clause"
WITH fac_slots AS (
  SELECT 
    cd.bookings.facid,
    SUM(slots) AS total_slots
  FROM cd.bookings
  JOIN cd.facilities ON cd.bookings.facid = cd.facilities.facid
  GROUP BY cd.bookings.facid
),
ranked AS (
  SELECT 
    facid,
    total_slots,
    RANK() OVER (ORDER BY total_slots DESC) AS rank
  FROM fac_slots
)
SELECT facid, total_slots
FROM ranked
WHERE rank = 1

--4: "Rank members by (rounded) hours used"
WITH member_hours AS (
  SELECT 
    cd.members.firstname,
    cd.members.surname,
    ROUND(SUM(cd.bookings.slots) / 2, -1) AS hours
  FROM cd.bookings
  JOIN cd.members ON cd.bookings.memid = cd.members.memid
  GROUP BY firstname, surname
),
ranked AS (
  SELECT
    firstname,
    surname,
    hours,
    RANK() OVER (ORDER BY hours DESC) AS rank
  FROM member_hours
)
SELECT firstname, surname, hours, rank
FROM ranked
ORDER BY rank, surname, firstname

--5: "Find the top three revenue generating facilities"
WITH fac_revenue AS (
  SELECT 
    cd.facilities.name,
    SUM(CASE WHEN cd.bookings.memid = 0 THEN guestcost * slots ELSE membercost * slots END) AS revenue
  FROM cd.bookings
  JOIN cd.facilities ON cd.bookings.facid = cd.facilities.facid
  GROUP BY cd.facilities.name
),
ranked AS (
  SELECT
    name,
    RANK() OVER (ORDER BY revenue DESC) AS rank
  FROM fac_revenue
)
SELECT name, rank
FROM ranked
WHERE rank <= 3
ORDER BY name, rank

------------------------------------------------------------------------------------------
--Tuesday — ROW_NUMBER and DENSE_RANK From Scratch

--Problem 1: DataLemur — "User's Third Transaction" (Uber Medium)
--From memory. No looking at old solutions. Target: 5 minutes.
--Sentence: "I want to number transactions within each user"
--Paper plan:

--CTE: Number each transaction for each user then order by transaction date
--Final: Select the third transaction for each user

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


--Problem 2: DataLemur — "Odd and Even Measurements" (Google Medium)
--Search for it on DataLemur.
--Paper plan:

--CTE: Number each measurement within each day using ROW_NUMBER
--Final: Use CASE to sum odd-numbered and even-numbered measurements per day

--Sentence for the CTE: "I want to number MEASUREMENTS within each DAY"

WITH num_measurement AS (
  SELECT
    DATE_TRUNC('day', measurement_time) AS measurement_day,
    ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('day', measurement_time) ORDER BY measurement_time) AS measurement_num,
    measurement_value
  FROM measurements
)
SELECT
  measurement_day,
  SUM(CASE WHEN measurement_num % 2 = 1 THEN measurement_value END) AS odd_sum,
  SUM(CASE WHEN measurement_num % 2 = 0 THEN measurement_value END) AS even_sum
FROM num_measurement
GROUP BY measurement_day


------------------------------------------------------------------------------------------
--Wednesday — LAG: The Scaffolded Way

-- "Previous month's revenue for each product"
LAG(revenue, 1) OVER (PARTITION BY product_id ORDER BY month)
--  ↑ what to look back at    ↑ within each product   ↑ in time order

-- Template:
WITH with_previous AS (
    SELECT 
        columns_you_need,
        the_value_column,
        LAG(the_value_column, 1) OVER (
            PARTITION BY group_column 
            ORDER BY time_column
        ) AS prev_value
    FROM your_table
)

SELECT 
    columns_you_need,
    the_value_column,
    prev_value,
    ROUND(100.0 * (the_value_column - prev_value) / prev_value, 2) AS growth_pct
FROM with_previous
WHERE prev_value IS NOT NULL;

--Exercise A: Basic LAG — monthly comparison
--Scenario: "Show each month's revenue alongside last month's revenue."
--Sentence: "I want to see the PREVIOUS revenue, ordered by month" (no PARTITION BY needed — only one group)

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(amount) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT 
    month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month) AS prev_month_revenue
FROM monthly_revenue;


--Exercise B: LAG with PARTITION BY
--Scenario: "For each product, show this year's revenue and last year's revenue."
--Sentence: "I want to see the PREVIOUS annual_revenue within each PRODUCT, ordered by YEAR"

WITH yearly_product_revenue AS (
    SELECT 
        product_id,
        EXTRACT(YEAR FROM order_date) AS year,
        SUM(amount) AS annual_revenue
    FROM orders
    GROUP BY product_id, EXTRACT(YEAR FROM order_date)
),

with_previous AS (
    SELECT 
        product_id,
        year,
        annual_revenue,
        LAG(annual_revenue, 1) OVER (
            PARTITION BY product_id      -- within each ___
            ORDER BY year          -- in ___ order
        ) AS prev_year_revenue
    FROM yearly_product_revenue
)

SELECT 
    product_id,
    year,
    annual_revenue,
    prev_year_revenue,
    ROUND(100.0 * (annual_revenue - prev_year_revenue) / prev_year_revenue, 2) AS yoy_growth
FROM with_previous
WHERE prev_year_revenue IS NOT NULL;