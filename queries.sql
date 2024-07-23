-- Ensure following files are run:
-- get_dataset.bat (extract orders.csv.zip after this)
-- schema.sql
-- data_setup.py

-- get rows
SELECT * FROM orders LIMIT 100;

-- QUESTIONS

-- Q1: find top 10 highest reveue generating products 
SELECT TOP 10 product_id, SUM(sale_price) AS sales
FROM orders
GROUP BY product_id
ORDER BY sales DESC


-- Q2: find top 5 highest selling products in each region
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM orders
    GROUP BY region, product_id
)
SELECT * FROM (
    SELECT *
    , ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
    from cte
) A
where rn<=5


-- Q3: find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
    SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month,
    SUM(sale_price) AS sales
    from orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month
, SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022
, SUM(CASE WHEN order_year=2023 THEN sales else 0 END) as sales_2023
from cte 
GROUP BY order_month
ORDER BY order_month


-- Q4: for each category which month had highest sales 
WITH cte AS (
    SELECT category, FORMAT(order_date,'yyyyMM') AS order_year_month
    , SUM(sale_price) AS sales 
    FROM orders
    GROUP BY category, FORMAT(order_date,'yyyyMM')
)
SELECT * FROM (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) A
WHERE rn=1


-- Q5: which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT sub_category, YEAR(order_date) AS order_year,
    SUM(sale_price) AS sales
    FROM orders
    GROUP BY sub_category, YEAR(order_date)
)
, cte2 AS (
    SELECT sub_category
    , SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022
    , sum(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte 
    GROUP BY sub_category
)
SELECT TOP 1 *, (sales_2023-sales_2022)
FROM cte2
ORDER BY (sales_2023-sales_2022) DESC;