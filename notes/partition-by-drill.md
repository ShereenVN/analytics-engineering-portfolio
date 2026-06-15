Scenario 1: "Find each department's highest-paid employee"
Sentence: "I want to rank SALARY within each DEPARTMENT"
Answer: ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC)

Scenario 2: "Find each customer's most recent order"
Sentence: "I want to rank ORDER within each CUSTOMER"
Answer: ROW_NUMBER() OVER (PARTITION BY customer ORDER BY order DESC)

Scenario 3: "Find the 3rd most expensive product in each category"
Sentence: "I want to rank PRICE within each CATEGORY"
Answer: ROW_NUMBER() OVER (PARTITION BY CATEGORY ORDER BY PRICE DESC)

Scenario 4: "Rank students by GPA within each graduating class"
Sentence: "I want to rank GPA within each CLASS"
Answer: ROW_NUMBER() OVER (PARTITION BY CLASS ORDER BY GPA DESC)

Scenario 5: "Find each store's best-selling day"
Sentence: "I want to rank SALES within each STORE"
Answer: ROW_NUMBER() OVER (PARTITION BY STORE ORDER BY SALES DESC)

Scenario 6: "Find the oldest employee in each team"
Sentence: "I want to rank AGE within each TEAM"
Answer: ROW_NUMBER() OVER (PARTITION BY TEAM ORDER BY AGE DESC)

Scenario 7: "Rank countries by total population within each continent"
Sentence: "I want to rank POPULATION within each CONTINENT"
Answer: DENSE_RANK() OVER (PARTITION BY CONTINENT ORDER BY POPULATION DESC)

Scenario 8: "Get each user's previous login date"
Sentence: "I want to see the PREVIOUS login_date within each USER"
Answer: LAG(LOGIN_DATE, 1) OVER (PARTITION BY USER ORDER BY LOGIN_DATE)