Scenario: You're building a data warehouse for a webshop that sells electronics.

On paper or in a markdown file (notes/star-schema-exercise.md), design:

1. Identify the fact table:


What is the main event/transaction? (orders)
What measures would you track? (revenue, quantity, discount, etc.)
What is the grain? (one row per order line item)


2. Identify the dimension tables:


Who bought it? → dim_customers (customer_id, name, email, city, country, signup_date)
What was bought? → dim_products (product_id, name, category, brand, price)
When was it bought? → dim_dates (date_key, date, day_of_week, month, quarter, year, is_weekend)
Where was it shipped? → dim_locations (location_id, city, country, region)

                    dim_customers
                         |
dim_products --- fct_order_items --- dim_dates
                         |
                    dim_locations


-- fct_order_items (fact table)
-- order_id, order_line_id, customer_id (FK), product_id (FK), 
-- date_key (FK), location_id (FK),
-- quantity, unit_price, discount_amount, total_amount

-- dim_customers (dimension table)
-- customer_id (PK), customer_name, email, city, country, signup_date

-- dim_products (dimension table)
-- product_id (PK), product_name, category, subcategory, brand, list_price

-- dim_dates (dimension table)
-- date_key (PK), full_date, day_of_week, month_name, month_number, 
-- quarter, year, is_weekend, is_holiday