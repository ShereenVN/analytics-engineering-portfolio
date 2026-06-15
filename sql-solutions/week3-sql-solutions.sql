-- Problem: "Average Review Ratings" (Amazon Easy) 
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-27
-- Key concepts: GROUP BY + ROUND

-- My approach:
-- First I extracted the month from the submit date and got the product ID printed. Then I used avg on stars to determine the average stars, which prompted me to add group by.
-- Then I had to round the average stars by 2 decimals, but I put the round around avg_stars instead of the avg(stars), then fixed that when I encountered the error. Lastly I ordered the results by month and product ID.


SELECT EXTRACT(MONTH FROM submit_date) AS mnth, product_id, ROUND(avg(stars),2) AS avg_stars 
FROM reviews
GROUP BY EXTRACT(MONTH FROM submit_date), product_id
ORDER BY mnth, product_id;



-- Problem: "Average Post Hiatus" (Facebook Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-27
-- Key concepts: uses date functions + aggregation

-- My approach:
-- I grabbed the user_id, then did max post date minus min post date and stored them as days_between, then I used date_part to extract the year and then grouped by user_id and finished with it having a count post_id more than one.


SELECT user_id, MAX(post_date::DATE) - MIN(post_date::DATE) AS days_between 
FROM posts
WHERE DATE_PART('year',post_date::date) = 2021 
GROUP BY user_id
HAVING COUNT(post_id) > 1;



-- Problem: "App Click-through Rate" (Facebook Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-27
-- Key concepts: CASE + aggregation

-- My approach:
-- So I used the code I had already written last week and the instructions you provided me. I added SUM to CASE and divided them. Then multiplied by 100.0, added a ROUND around it, with 2 decimals
-- Then I added a WHERE statement with DATE_PART to extract the year.

SELECT app_id,
ROUND(100.0 * SUM(CASE WHEN event_type = 'click' then 1 else 0 end)
  / SUM(CASE WHEN event_type = 'impression' then 1 else 0 end),2) AS CTR
FROM events
WHERE DATE_PART('year', timestamp::DATE) = 2022
GROUP BY app_id;



-- Problem: "Pharmacy Analytics (Part 3)" (CVS Easy) 
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-27
-- Key concepts: uses SUM with CASE for conditional totals

-- My approach:
-- There's no CASE in this question, it's literally a sum of total sales per manufacturer, in a fancy display.

SELECT manufacturer, 
       CONCAT('$', ROUND(SUM(total_sales) / 1000000), ' million') AS total_sales
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer ASC



-- Problem: "Sending vs. Opening Snaps" (Snapchat Medium) 
-- Platform: DataLemur
-- Difficulty: Medium
-- Date: 2026-04-27
-- Key concepts: percentage calculation with CASE

-- My approach:
-- So first, we need to calculate how much time users spend on either sending or opening snaps. That's SUM+CASE, twice. 
-- One for Sending and one for Opening. Then we need to divide that by 100.0 and then group by age group.

SELECT 
  ab.age_bucket,
  ROUND(SUM(CASE WHEN activity_type = 'send' THEN time_spent END) 
    / SUM(CASE WHEN activity_type IN ('send', 'open') THEN time_spent END) * 100.0, 2) AS send_pct,
  ROUND(SUM(CASE WHEN activity_type = 'open' THEN time_spent END) 
    / SUM(CASE WHEN activity_type IN ('send', 'open') THEN time_spent END) * 100.0, 2) AS open_pct
FROM activities a
JOIN age_breakdown ab ON a.user_id = ab.user_id
GROUP BY ab.age_bucket



-- Problem: "Signup Activation Rate" (TikTok Medium)
-- Platform: DataLemur
-- Difficulty: Medium
-- Date: 2026-04-29
-- Key concepts: JOIN and calculating percentage

-- My approach:
-- The actual solution was already written in the code editor, so I only had to build a CTE around it.

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



