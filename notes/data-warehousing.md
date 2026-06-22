# Data Warehousing Notes

## OLTP vs OLAP
- OLTP (Online Transaction Processing): Designed for day to day operation and many small fast reads and writes, data is highly normalized.
- OLAP (Online Analytical Processing): Designed for analysis and reporting, optimized for complex queries across large amounts of data, data is denormalized.
- Key difference: OLTP is for writing data. OLAP is for reading data.

## ETL vs ELT
- ETL (Extract, Transform, Load): Transforms before loading in to the warehouse
- ELT (Extract, Load, Transform): Transforms inside of the warehouse
- Why ELT is the modern approach: Cloud warehouse made storage and compute cheap and scalable, raw data is always preserved.
- Where dbt fits: dbt is the "T" in ELT

## Dimensional Modeling
- What is it: A technique for structuring data in a warehouse to make it easy to query and analyze
- Who invented it: Ralph Kimball

## Star Schema
- What it looks like: A star, one table in the center and a singular table attached to it without branches
- Center: fact table (events/transactions)
- Points: dimension tables (descriptive info)

## Fact Tables
- What they contain: measurable events
- Examples: sales, clicks, transactions
- Grain: ...

## Dimension Tables
- What they contain: context about the events in the fact table
- Examples: customer details, product details, dates