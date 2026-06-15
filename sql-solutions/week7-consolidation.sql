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

