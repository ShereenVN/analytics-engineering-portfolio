-- Problem: Histogram of Tweets (Twitter)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-08
-- Key concepts: GROUP BY, COUNT, subquery

-- My approach:
-- So I was stuck on the fact that I thought one user had 3 tweets, and I should have looked at the year. But I also need more practice with the subquery, because that's not something I fully grasp yet.

SELECT tweet_count, COUNT(user_id) AS num_users
FROM (
  SELECT user_id, COUNT(tweet_id) AS tweet_count
  FROM tweets
  WHERE EXTRACT(YEAR FROM tweet_date) = 2022
  GROUP BY user_id
) AS user_tweet_counts
GROUP BY tweet_count
ORDER BY tweet_count


-- Problem: "Teams Power Users" (Microsoft Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-08
-- Key concepts: Filtering + aggregation

-- My approach:
-- First we collect the sender_id's, and message_id's and we filter them by month and 
-- year with extract and group them by sender_id. Then we count the message_id's as message_count, order by message_count desc and limit the output by 2.

SELECT sender_id, count(message_id) as message_count
FROM messages
WHERE EXTRACT(MONTH FROM sent_date) = '8'
  AND EXTRACT(YEAR FROM sent_date) = '2022'
group by sender_id
order by message_count desc
Limit 2;


-- Problem: "Duplicate Job Listings" (LinkedIn Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-08
-- Key concepts: GROUP BY + HAVING

-- My approach:
-- So I used the hints on this because I have never use CTE's, so I am looking forward to learn more abou that.

WITH job_count_cte AS (
  SELECT 
    company_id, 
    title, 
    description, 
    COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY company_id, title, description
)

SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM job_count_cte
WHERE job_count > 1;


-- Problem: "Cards Issued Difference" (JPMorgan Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-08
-- Key concepts: MIN/MAX aggregation

-- My approach:
-- I used the hint to show me how the query looked like and then just filled in the blanks based on the assignment.

SELECT 
  card_name, 
  MAX(issued_amount) - MIN(issued_amount) AS difference 
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC;


-- Problem: "Compressed Mean" (Alibaba Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-08
-- Key concepts: Weighted calculation

-- My approach:
-- I used the hint to show me how the query looked like and then just filled in the blanks based on the assignment.

SELECT 
  ROUND(
    SUM(item_count::DECIMAL*order_occurrences)/SUM(order_occurrences)
    ,1) AS mean -- Fill in the required number of decimals
FROM items_per_order;


-- Problem: "Second Day Confirmation" (TikTok Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-16
-- Key concepts: Subquery/CTE with date logic

-- My approach:
-- I used the hint to show me how the query looked like and then just filled in the blanks based on the assignment.

SELECT DISTINCT emails.user_id
FROM emails 
JOIN texts
  ON emails.email_id = texts.email_id
WHERE texts.action_date = emails.signup_date + INTERVAL '1 day'
  AND texts.signup_action = 'Confirmed';


-- Problem: "Signup Activation Rate" (TikTok Medium)
-- Platform: DataLemur
-- Difficulty: Medium
-- Date: 2026-04-16
-- Key concepts: CTE with join

-- My approach:
-- I used the hint to show me how the query looked like and then just filled in the blanks based on the assignment.

SELECT 
  ROUND(COUNT(texts.email_id)::DECIMAL
    /COUNT(DISTINCT emails.email_id),2) AS activation_rate
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND texts.signup_action = 'Confirmed';  