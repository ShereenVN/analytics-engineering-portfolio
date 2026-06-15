--Exercise A: "Histogram of Tweets" (Twitter Easy)
--The question: How many users posted 1 tweet, 2 tweets, 3 tweets, etc. in 2022?
--This needs two steps:

--Step 1: Count how many tweets each user posted in 2022
--Step 2: Group those counts to make a histogram

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


--Exercise B: "Duplicate Job Listings" (LinkedIn Easy)
--The question: How many companies have posted duplicate job listings (same title AND description)?
--Step 1: Count listings per company per title per description.
--Step 2: Find companies where any count > 1.

WITH listing_counts AS (
SELECT 
  company_id, 
  title, 
  description, 
  COUNT(job_id) AS listing_count
FROM job_listings
GROUP BY company_id, title, description
)
SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM listing_counts
WHERE listing_count > 1


-- Exercise C: "Cards Issued Difference" (JPMorgan Easy)
-- You already solved this one WITHOUT a CTE. Now rewrite it WITH a CTE, just for practice.

WITH card_stats AS (
SELECT 
  card_name, 
  MAX(issued_amount) AS max_issued,
  MIN(issued_amount) AS min_issued
FROM monthly_cards_issued
GROUP BY card_name
)
SELECT card_name,
  max_issued - min_issued as difference
FROM card_stats
ORDER BY difference DESC;


-- Exercise D: "App Click-through Rate" (Facebook Easy)
-- You solved this too. Rewrite it with a CTE to separate the counting from the division:

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


------------------------------------------------------------------------------------------------

--1. Read the problem
--2. Ask: "What do I need to calculate first?"
--3. Write that as a standalone query. Run it.
--4. Ask: "Now what do I do with those results?"
--5. Wrap Step 3 in WITH...AS, write the final SELECT


-- Problem 1: "Histogram of Tweets" (Twitter Easy)
-- Step 1: calculates tweet count per user for 2022
-- Step 2: counts how many users have each tweet count

WITH user_tweet_count AS (
SELECT user_id, COUNT(tweet_id) AS tweet_count
FROM tweets
WHERE EXTRACT(YEAR FROM tweet_date) = 2022
GROUP BY user_id
)
SELECT tweet_count, COUNT(user_id) AS num_users
FROM user_tweet_count
GROUP BY tweet_count
ORDER BY tweet_count

-- Time: 3 minutes



--Problem 2: "Teams Power Users" (Microsoft Easy)
--Step 1: calculates messages sent in august of 2022
--Step 2: displays the users and total messages they sent and limits by 2

WITH teams_message_count AS (
SELECT sender_id, count(message_id) as message_count
FROM messages
WHERE EXTRACT(MONTH FROM sent_date) = '8'
  AND EXTRACT(YEAR FROM sent_date) = '2022'
group by sender_id
)
SELECT sender_id, message_count
FROM teams_message_count
order by message_count desc
Limit 2;



--Problem 3: "Pharmacy Analytics (Part 1)" (CVS Easy)
--Step 1: Calculates total sales and profit per drug
--Step 2: Displays the top 3 most profitable drugs sold and how much profit they made

WITH drug_profit AS (
SELECT drug,
  total_sales - cogs AS total_profit
FROM pharmacy_sales
)
SELECT drug, total_profit
FROM drug_profit
ORDER BY total_profit DESC
LIMIT 3;



--Problem 4: "User's Third Transaction" (Uber Medium)
--Step 1: calculates each user's transaction, numbered in order
--Step 2: filter to only the 3rd transaction

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



--Problem 5: "Signup Activation Rate" (TikTok Medium)
--Step 1: All e-mails and texts IDs that have a signup action of confirmed
--Step 2: Calculate through signup actions / email id what the activation rate is 

WITH email_texts AS (
  SELECT 
    emails.email_id,
    texts.signup_action
  FROM emails
  LEFT JOIN texts
    ON emails.email_id = texts.email_id
    AND texts.signup_action = 'Confirmed'
)
SELECT 
  ROUND(COUNT(signup_action)::DECIMAL / COUNT(email_id), 2) AS activation_rate
FROM email_texts



----------------------------------------------------------------------------------------------
--Chained CTE's
-- Template for chained CTEs:
WITH first_step AS (
    -- query 1
),  -- COMMA here, NOT a semicolon

second_step AS (
    -- query 2, which can use "first_step" as a table
    SELECT ... FROM first_step ...
)

-- Final query, which can use both "first_step" and "second_step"
SELECT ... FROM second_step ...



--Exercise A: Build a two-step query manually
--Scenario: "Find the top-spending customer for each product category."

WITH customer_spending AS (
  SELECT
    customer_id,
    category,
    SUM(amount) AS total_spent
  FROM orders
  GROUP BY customer_id, category;
),
ranked AS (
  SELECT
    customer_id,
    category,
    total_spent,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_spent DESC) AS spending_rank
  FROM customer_spending;
)
SELECT customer_id, category, total_spent
FROM ranked
WHERE spending_rank = 1;



--Exercise B: "Top 5 Artists" (Spotify Medium) — DataLemur
--Step 1: JOIN artists + songs + global_song_rank. Filter to rank <=10. Count appearances per artist.
--Step 2: DENSE_RANK artists by their appearance count.
--Step 3: Filter ro rank <= 5.
--Btw, the Spotify "top 5 artist" isn't on DataLemur anymore, it's now "Spotify Streaming History"

WITH artist_appearances AS (
  SELECT
    a.artist_name,
    COUNT(*) AS top_10_count
  FROM artist a
  JOIN songs s ON a.artist_id = a.artist_id
  JOIN global_song_rank g ON s.song_id = g.song_id
  WHERE g.rank <= 10
  GROUP BY a.artist_name
),

ranked_artists AS (
  SELECT
    artist_name,
    top_10_count,
    DENSE_RANK() OVER (ORDER BY top_10_count DESC) AS artist_rank
  FROM artist_appearances
)

SELECT artist_name, artist_rank
FROM ranked_artists
WHERE artist_rank <= 5
ORDER BY artist_rank, artist_name;



--Exercise C: "International Call Percentage" (Verizon Medium)
--Step 1: Join phone_calls with phone_info TWICE (once for caller, once for receiver) to get both countries
--Step 2: Flag each call as international (caller country != receiver country)
--Step 3: Calculate percentage of international calls.

WITH call_info AS (
SELECT 
  phone_calls.caller_id, 
  phone_calls.receiver_id,
  caller_info.country_id AS caller_country,
  receiver_info.country_id AS receiver_country
FROM phone_calls 
JOIN phone_info AS caller_info ON phone_calls.caller_id = caller_info.caller_id
JOIN phone_info AS receiver_info ON phone_calls.receiver_id = receiver_info.caller_id
),
international_calls AS (
SELECT
  *
FROM call_info
WHERE caller_country != receiver_country
)
SELECT
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM call_info), 1) AS international_call_pct
FROM international_calls