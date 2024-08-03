SELECT* FROM df_orders;
DROP TABLE df_orders;

-- Changing data type of table
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);

--SALES ANALYSIS

--Top 10 Highest Revenue-Generating Orders:
SELECT order_id, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY order_id
ORDER BY total_sales DESC
LIMIT 10;

--Monthly Sales Trend:
SELECT DATE_TRUNC('month', order_date) AS month, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY month
ORDER BY month;

--Top 10 Most Profitable Orders:
SELECT order_id, SUM(profit) AS total_profit
FROM df_orders
GROUP BY order_id
ORDER BY total_profit DESC
LIMIT 10;



--PRODUCT ANALYSIS

--Top 10 Highest Revenue-Generating Products:
SELECT product_id, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;

--Most Profitable Products:
SELECT product_id, SUM(profit) AS total_profit
FROM df_orders
GROUP BY product_id
ORDER BY total_profit DESC
LIMIT 10;

--Products with Highest Discount Given:
SELECT product_id, AVG(discount) AS avg_discount
FROM df_orders
GROUP BY product_id
ORDER BY avg_discount DESC
LIMIT 10;



--CUSTOMER SEGMENT ANALYSIS 

--Sales by Customer Segment:
SELECT segment, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY segment
ORDER BY total_sales DESC;

--Profit by Customer Segment:
SELECT segment, SUM(profit) AS total_profit
FROM df_orders
GROUP BY segment
ORDER BY total_profit DESC;



--REGIONAL ANALYSIS

--Sales by Region:
SELECT region, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY region
ORDER BY total_sales DESC;

--Profit by Region:
SELECT region, SUM(profit) AS total_profit
FROM df_orders
GROUP BY region
ORDER BY total_profit DESC;

--Top Cities by Sales:
SELECT city, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY city
ORDER BY total_sales DESC
LIMIT 10;

-- Find top 5 highest selling products in each region:
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id)
SELECT *
FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte) AS A
WHERE rn <= 5;



--TIME BASED ANALYSIS:

--Yearly Sales Comparison:
SELECT EXTRACT(YEAR FROM order_date) AS year, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY year
ORDER BY year;

--Quarterly Sales Trend:
SELECT EXTRACT(YEAR FROM order_date) AS year, EXTRACT(QUARTER FROM order_date) AS quarter, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY year, quarter
ORDER BY year, quarter;

--Sales Growth Rate by Month:
WITH monthly_sales AS (
    SELECT DATE_TRUNC('month', order_date) AS month, SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY month
)
SELECT month, total_sales, 
       LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
       (total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month) * 100 AS growth_rate
FROM monthly_sales;

-- Find month-over-month growth comparison for 2022 and 2023 sales:
WITH cte AS (
    SELECT EXTRACT(YEAR FROM order_date) AS order_year,
           EXTRACT(MONTH FROM order_date) AS order_month,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT order_month,
       SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte 
GROUP BY order_month
ORDER BY order_month;



--SHIPPING MODE ANALYSIS

--Sales by Shipping Mode:
SELECT ship_mode, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY ship_mode
ORDER BY total_sales DESC;

--Profit by Shipping Mode:
SELECT ship_mode, SUM(profit) AS total_profit
FROM df_orders
GROUP BY ship_mode
ORDER BY total_profit DESC;



--CATEGORY ANALYSIS

--Sales by Product Category:
SELECT category, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY category
ORDER BY total_sales DESC;

--Profit by Product Category:
SELECT category, SUM(profit) AS total_profit
FROM df_orders
GROUP BY category
ORDER BY total_profit DESC;

--Top Sub-Categories by Sales:
SELECT sub_category, SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY sub_category
ORDER BY total_sales DESC
LIMIT 10;

--Sub-Categories with Highest Profit:
SELECT sub_category, SUM(profit) AS total_profit
FROM df_orders
GROUP BY sub_category
ORDER BY total_profit DESC
LIMIT 10;

-- Identify the sub-category with the highest growth in profit from 2022 to 2023:
WITH cte AS (
    SELECT sub_category,
           EXTRACT(YEAR FROM order_date) AS order_year,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, EXTRACT(YEAR FROM order_date)), 
	cte2 AS (
    SELECT sub_category,
           SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
           SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte 
    GROUP BY sub_category)
SELECT *
FROM cte2
ORDER BY (sales_2023 - sales_2022) DESC
LIMIT 1;

-- For each category, find the month with the highest sales:
WITH cte AS (
    SELECT category,
           TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
           SUM(sale_price) AS sales 
    FROM df_orders
    GROUP BY category, TO_CHAR(order_date, 'YYYYMM')
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) AS a
WHERE rn = 1;









