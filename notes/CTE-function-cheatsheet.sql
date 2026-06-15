Imagine you have a spreadsheet.

Sheet 1: You calculate total sales per customer.
Sheet 2: You use Sheet 1's results to find the top 5 customers.

In SQL:
   Sheet 1 = CTE 1
   Sheet 2 = CTE 2 (or the final SELECT)


WITH step_one AS (
    -- A normal SELECT query. Nothing special. 
    -- Write it like you would any query.
    SELECT ...
    FROM ...
    WHERE ...
    GROUP BY ...
)

SELECT ...
FROM step_one   -- You use "step_one" exactly like a table name
WHERE ...

