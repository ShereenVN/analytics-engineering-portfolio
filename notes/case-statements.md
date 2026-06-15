-- CASE turns row-level values into columns or categories
-- Pattern 1: Categorizing data
SELECT
    name,
    population,
    CASE
        WHEN population > 1000000000 THEN 'huge'
        WHEN population > 100000000 THEN 'large'
        WHEN population > 10000000 THEN 'medium'
        ELSE 'small'
    END AS country_size
FROM world;

-- Pattern 2: CASE inside COUNT or SUM (this is what tripped you up)
-- This is how "Laptop vs. Mobile Viewership" works
SELECT
    COUNT(CASE WHEN device_type = 'laptop' THEN 1 END) AS laptop_views,
    COUNT(CASE WHEN device_type = 'mobile' THEN 1 END) AS mobile_views
FROM viewership;

-- Pattern 3: CASE inside SUM
SELECT
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) AS completed_revenue,
    SUM(CASE WHEN status = 'refunded' THEN amount ELSE 0 END) AS refunded_revenue
FROM orders;


Why does COUNT(CASE WHEN ... THEN 1 END) work?

CASE returns 1 when the condition is true, and NULL when it's not (because there's no ELSE)
COUNT ignores NULLs
So you're counting only the rows where the condition is true


So, when you want to make a case, that doesn't need an else, you use THEN 1 END.
Otherwise you use ELSE 0 END, or another form of ELSE that's required for that query to determine if something is false.
A case is essentially looking at what's true, and if it's not, THEN it's 0, and that's the END.
I guess that is how I could read a CASE statement, to properly understand how it works.