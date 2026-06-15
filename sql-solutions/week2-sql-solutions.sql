-- Problem: "Laptop vs. Mobile Viewership" (New York Times Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-20
-- Key concepts: CASE, SUM

-- My approach:
-- So based on the instruction, it wanted a SUM of the laptop views and a sum of mobile views which includes both a tablet and phone.
-- That's why I started with a SUM statement around the CASE statement. The laptop statement was pretty straightforward, since it only needed the data from one point.
-- The data for the mobile views was less straightforward because it required both tablet and phone, hence I had to use IN to select both of those data types.

SELECT 
    SUM(CASE WHEN device_type = 'laptop' THEN 1 ELSE 0 END) as laptop_views,
    SUM(CASE WHEN device_type IN ('tablet', 'phone') THEN 1 ELSE 0 END) as mobile_views
FROM viewership;



-- Problem: "Unfinished Parts" (Tesla Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-20
-- Key concepts: WHERE, ISNULL

-- My approach:
-- The critical bit of information in this question is that unfinished products have no finish data, thus that is the point that determines if a product is finished or not, not the step of assembly.
-- So I selected the tables they wished to see and made a WHERE statement for finish_date to determine which ones ISNULL.

SELECT part, assembly_step 
FROM parts_assembly
WHERE finish_date ISNULL;



-- Problem: "Average Post Hiatus" (Facebook Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-20
-- Key concepts: uses date functions + aggregation

-- My approach:
-- Ok, so I am really bad with calculating dates in SQL and need a lot more practice with it, because I just had to use the hints or I would not have understood what to do.
-- I figured out how to use the MIN and MAX functions, but then I was kind of clueless. Adding ::DATE was completely new for me, same with DATE_PART.

SELECT user_id, MAX(post_date::DATE) - MIN(post_date::DATE) AS days_between FROM posts
WHERE DATE_PART('year',post_date::date)=2021 
GROUP BY user_id
HAVING COUNT(post_id)>1;



-- Problem: "App Click-through Rate" (Facebook Easy)
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-20
-- Key concepts: CASE + aggregation

-- My approach:
-- Apparently using CASE statements and then having to divide the outcome, is not something I understand. The below SQL statement is as far as I have gotten during this exercise.

SELECT app_id,
  (CASE WHEN event_type = 'click' then 1 else 0 end) as event_click,
  (CASE WHEN event_type = 'impression' then 1 else 0 end) AS event_impression,
FROM events
GROUP BY app_id;



-- Problem: "Average Review Ratings" (Amazon Easy) 
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-20
-- Key concepts: GROUP BY + ROUND

-- My approach:
-- I have no clue on how to solve this without any hints, dates remain a mystery for me to solve. I tried adding ::MONTH to submit_date, but that only caused syntax errors.
-- The most furiating thing is, that I understand what the assignment wants from me, I just don't know how to get to the answer. I do understand the logic.



-- Problem: "Data Science Skills" (LinkedIn Easy) 
-- Platform: DataLemur
-- Difficulty: Easy
-- Date: 2026-04-20
-- Key concepts: WHERE, ORDER BY

-- My approach:
-- When I opened this assignment again, my code was still in the editor so I saw the solution immediately. 

