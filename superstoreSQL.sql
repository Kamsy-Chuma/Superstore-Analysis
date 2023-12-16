SELECT *
FROM superstore

-- -- PRODUCT -- --

-- Finding the product(s) that generated the most revenue
SELECT TOP 10
	[Product Name],
	SUM(Revenue) AS total_revenue,
	SUM(Quantity) AS total_qty
FROM
	superstore
GROUP BY
	[Product Name]
ORDER BY
	total_revenue DESC;

-- Finding the product(s) that generated the least revenue
SELECT TOP 10
	[Product Name],
	SUM(Revenue) AS total_revenue
FROM
	superstore
GROUP BY
	[Product Name]
ORDER BY
	total_revenue;

-- Profit
SELECT TOP 10
	[Product Name],
	SUM(Profit) AS total_profit
FROM
	superstore
GROUP BY
	[Product Name]
ORDER BY
	total_profit DESC;

-- There are a lot of products that incurred losses.
-- We can classify them to see what categories these products belong to
SELECT Category, COUNT(*) AS total, SUM(total_profit) AS total_profit
FROM (
SELECT TOP 300
	[Product Name],
	Category,
	SUM(Profit) AS total_profit
FROM
	superstore
GROUP BY
	[Product Name], Category
ORDER BY
	total_profit) summary
GROUP BY Category;

-- Which product was purchased the most
SELECT TOP 10
	[Product Name],
	SUM(Quantity) AS total_quantity
FROM
	superstore
GROUP BY
	[Product Name]
ORDER BY
	total_quantity DESC;

-- Which product was purchased the least
SELECT TOP 10
	[Product Name],
	SUM(Quantity) AS total_quantity
FROM
	superstore
GROUP BY
	[Product Name]
ORDER BY
	total_quantity;

-- What product costs more?
SELECT DISTINCT
	[Product Name],
	Price/Quantity AS price_per_unit
FROM
	superstore
ORDER BY
	price_per_unit DESC;


-- BRIDGE BETWEEN(PRODUCT &  REGION) --

-- Region:
SELECT
	Region,
	[Product Name],
	SUM(Quantity) AS total_qty,
	SUM(Revenue) AS total_rev
FROM
	superstore
WHERE
	[Product Name] LIKE 'Canon imageCLASS 2200%'
GROUP BY
	Region,
	[Product Name]
ORDER BY
	total_rev DESC;

-- State:
SELECT
	State,
	[Product Name],
	SUM(Quantity) AS total_qty,
	SUM(Revenue) AS total_revenue
FROM
	superstore
WHERE
	[Product Name] LIKE 'Canon imageCLASS 2200%'
GROUP BY
	State,
	[Product Name]
ORDER BY
	total_revenue DESC;


-- -- REGION -- --

-- What Region generated the most revenue?
SELECT
	Region,
	ROUND(SUM(Revenue), 2) AS total_revenue
FROM
	superstore
GROUP BY
	Region
ORDER BY 
	total_revenue DESC;

-- Which product was purchased more in each region?
-- Top 5 in each region
SELECT * 
FROM (
	SELECT
		Region,
		[Product Name],
		ROUND(SUM(Quantity), 2) AS total_qty,
		ROW_NUMBER() OVER (PARTITION BY Region ORDER BY ROUND(SUM(Quantity), 2) DESC) AS row_num
	FROM
		superstore
	GROUP BY
		Region,
		[Product Name]
) purchase
WHERE row_num <= 5;

-- Total purchases per region
SELECT 
	Region,
	SUM(Quantity) AS total_qty,
	MAX([Order Date]) AS last_purchase_date
FROM
	superstore
GROUP BY 
	Region
ORDER BY
	total_qty DESC;

-- Later, work on getting the purchasing frequency

-- -- STATE -- --

-- What State generated the most revenue?
SELECT
	State,
	ROUND(SUM(Revenue), 2) AS total_revenue
FROM
	superstore
GROUP BY
	State
ORDER BY 
	total_revenue DESC;

-- Total Quantity per State
SELECT 
	State,
	SUM(Quantity) AS total_qty
FROM
	superstore
GROUP BY 
	State
ORDER BY
	total_qty DESC;

-- What products do CALIFORNIA and NEW YORK purchase more?
SELECT SUM(Price) AS total_price FROM (
SELECT TOP 5
	State,
	[Product Name],
	Quantity,
	Price,
	Revenue
FROM
	superstore
WHERE
	State = 'California'
ORDER BY
	Revenue DESC) base;

SELECT SUM(Price) AS total_price FROM (
SELECT TOP 5
	State,
	[Product Name],
	Quantity,
	Price,
	Revenue
FROM
	superstore
WHERE
	State = 'New York'
ORDER BY
	Revenue DESC) base

SELECT
	State,
	AVG(Revenue) AS avg_revenue
FROM
	superstore
WHERE
	State IN ('California', 'New York')
GROUP BY
	State

-- BRIDGE BETWEEN PRODUCT AND CATEGORY --
-- What Category and sub-category does the best performing product belong to?
SELECT
	[Product Name],
	Category,
	[Sub-Category]
FROM (
	SELECT TOP 10
		[Product Name],
		Category,
		[Sub-Category],
		SUM(Revenue) AS total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(Revenue) DESC) AS row_num
	FROM
		superstore
	GROUP BY
		[Product Name],
		Category,
		[Sub-Category]
	ORDER BY
		total_revenue DESC
) total
WHERE
	row_num = 1;

-- How often do people buy "Copiers" and how much revenue has it generated?
SELECT
	[Sub-Category],
	SUM(Quantity) AS total_qty,
	SUM(Revenue) AS total_revenue
FROM
	superstore
WHERE
	[Sub-Category] = 'Copiers'
GROUP BY
	[Sub-Category]
ORDER BY
	total_qty DESC;

-- Compared to other Sub-Categories, how does it perform
SELECT
	[Sub-Category],
	SUM(Quantity) AS total_qty,
	ROUND(SUM(Revenue), 2) AS total_revenue
FROM
	superstore
GROUP BY
	[Sub-Category]
ORDER BY
	total_revenue DESC;

-- Profits:
SELECT
	[Sub-Category],
	ROUND(SUM(Profit), 2) AS total_profit
FROM
	superstore
GROUP BY
	[Sub-Category]
ORDER BY
	total_profit DESC;

-- -- CATEGORY -- --
-- Best and Least Performing Categories
SELECT
	Category,
	ROUND(SUM(Revenue), 2) AS total_revenue,
	SUM(Quantity) AS total_qty
FROM
	superstore
GROUP BY
	Category
ORDER BY 
	total_revenue DESC;


-- Which Category drives the most profit? (Before and After Discounts)
SELECT
	Category,
	SUM(Price - Cost) AS init_profit,
	ROUND(SUM(Profit), 2) AS total_profit
FROM
	superstore
GROUP BY
	Category
ORDER BY 
	total_profit DESC;

-- PROFITS
-- Total of profits and sales, for both discounts and non_discounts
SELECT SUM(Cost) AS total_cost, SUM(Price) init_sales, SUM(Price - Cost) AS init_profit, SUM(Profit) AS profit_aft_dis, SUM(Revenue) AS sales_aft_dis
FROM superstore;

-- Finding profit_margin in percentage for non_discounted products
WITH non_discounted AS (
SELECT SUM(sales_non_discounted) AS total_sales, SUM(profit_non_discounted) AS total_profit
FROM(
SELECT Category, SUM(Revenue) AS sales_non_discounted, SUM(Profit) AS profit_non_discounted
FROM superstore
WHERE Discount = 0
GROUP BY Category) base
)
SELECT ROUND(total_profit/total_sales * 100, 2) AS profit_margin
FROM non_discounted;

-- Finding profit_margin in percentage for discounted products
WITH discounted AS (
SELECT SUM(sales_discounted) AS total_sales, SUM(profit_discounted) AS total_profit
FROM(
SELECT Category, SUM(Revenue) AS sales_discounted, SUM(Profit) AS profit_discounted
FROM superstore
WHERE Discount > 0
GROUP BY Category) base
)
SELECT ROUND(total_profit/total_sales * 100, 2) AS profit_margin
FROM discounted;

-- How many times were each category ordered?
SELECT
	Category,
	COUNT(*) AS total_count
FROM
	superstore
GROUP BY
	Category
ORDER BY 
	total_count DESC;

-- Highest Product amount per Category per unit cost
SELECT
	Category,
	MIN(cost_per_unit) AS minimum,
	MAX(cost_per_unit) AS maximum
FROM (
	SELECT
		Category,
		ROUND(Cost/Quantity, 2) AS cost_per_unit,
		ROW_NUMBER() OVER (PARTITION BY Category ORDER BY ROUND(Cost/Quantity, 2) DESC) AS row_num
	FROM
		superstore
) highest
GROUP BY
	Category;

--Average cost per unit per category
SELECT
	Category,
	ROUND(AVG(Cost/Quantity), 2) avg_cost_per_unit
FROM 
	superstore
GROUP BY
	Category

-- Best and least performing sub-categories in each category
SELECT
	Category,
	[Sub-category],
	ROUND(SUM(Quantity), 2) AS total_qty,
	ROUND(SUM(Cost), 2) AS total_cost,
	ROUND(SUM(Revenue), 2) AS total_revenue,
	ROUND(SUM(Profit), 2) AS total_profit
FROM
	superstore
GROUP BY
	Category,
	[Sub-category]
ORDER BY
	Category,
	total_profit DESC;


SELECT State, Category, SUM(Quantity) AS total_qty
FROM superstore
GROUP BY State, Category
ORDER BY State, total_qty DESC


-- BB [Category & Customer] --
SELECT
	[Customer Name],
	[Sub-category],
	SUM(Quantity) AS total_qty
FROM
	superstore
GROUP BY
	[Customer Name],
	[Sub-category]
ORDER BY
	[Customer Name],
	total_qty DESC;
-- It wouldn't make sense to work with the Customer Names and Sub Categories cause there are a lot of records regarding these criterias

-- We can work with Segments and Categories

-- Purchasing power of each Segment
SELECT Segment, SUM(Quantity) AS total_purchases
FROM superstore
GROUP BY Segment
ORDER BY total_purchases DESC;

-- Purchase frequency per year
SELECT Segment,
SUM(CASE WHEN YEAR([Order Date]) = 2014 THEN Quantity ELSE NULL END) AS twenty_fourteen,
SUM(CASE WHEN YEAR([Order Date]) = 2015 THEN Quantity ELSE NULL END) AS twenty_fifteen,
SUM(CASE WHEN YEAR([Order Date]) = 2016 THEN Quantity ELSE NULL END) AS twenty_sixteen,
SUM(CASE WHEN YEAR([Order Date]) = 2017 THEN Quantity ELSE NULL END) AS twenty_seventeen
FROM superstore
GROUP BY Segment
ORDER BY Segment

-- Purchase rate per customer segment
SELECT *, ROUND(total_qty/SUM(total_qty) OVER (PARTITION BY Segment), 2) AS purchase_rate
FROM (
SELECT
	Segment,
	Category,
	SUM(Quantity) AS total_qty
FROM
	superstore
Group By
	Segment,
	Category
) amount
ORDER BY
	Segment,
	total_qty DESC;

-- How much revenue and profits do each category generate?
SELECT
	Segment,
	Category,
	ROUND(SUM(Revenue), 2) AS total_revenue,
	ROUND(SUM(Profit), 2) AS total_profit
FROM
	superstore
GROUP BY
	Segment,
	Category
ORDER BY
	Segment,
	total_profit DESC;

-- What Segment generates the most renevue and profit?
SELECT
	Segment,
	ROUND(SUM(Revenue), 2) AS total_revenue,
	ROUND(SUM(Profit), 2) AS total_profit
FROM
	superstore
GROUP BY
	Segment
ORDER BY
	total_profit DESC;

-- -- TREND ANALYSIS -- --
-- Yearly trend of sales for each year
WITH iterate AS (
SELECT
	YEAR([Order Date]) AS yearly,
	ROUND(SUM(Revenue), 2) AS total_revenue,
	ROUND(SUM(Profit), 2) AS total_profit
FROM
	superstore
GROUP BY
	YEAR([Order Date])
)
SELECT 
	i1.yearly,
	i1.total_revenue,
	i1.total_profit,
	i2.yearly,
	i2.total_revenue,
	i2.total_profit,
	ROUND((i2.total_revenue - i1.total_revenue) * 100 / i1.total_revenue, 2) AS revenue_rate,
	ROUND((i2.total_profit - i1.total_profit) * 100 / i1.total_profit, 2) AS profit_rate
FROM
	iterate i1
	JOIN iterate i2 ON i2.yearly = i1.yearly + 1
ORDER BY
	i1.yearly;

-- Yearly trend of sales from 2014 to 2017
WITH iterate AS (
SELECT
	YEAR([Order Date]) AS yearly,
	ROUND(SUM(Revenue), 2) AS total_revenue,
	ROUND(SUM(Profit), 2) AS total_profit
FROM
	superstore
GROUP BY
	YEAR([Order Date])
)
SELECT 
	i1.yearly,
	i1.total_revenue,
	i1.total_profit,
	i2.yearly,
	i2.total_revenue,
	i2.total_profit,
	ROUND((i2.total_revenue - i1.total_revenue) * 100 / i1.total_revenue, 2) AS revenue_rate,
	ROUND((i2.total_profit - i1.total_profit) * 100 / i1.total_profit, 2) AS profit_rate
FROM
	iterate i1
	JOIN iterate i2 ON i2.yearly = i1.yearly + 3;

-- Monthly trend of sales from 2014 to 2017
SELECT
	DATENAME(MONTH, [Order Date]) AS monthly,
	ROUND(SUM(Revenue), 2) AS total_revenue,
	ROUND(SUM(Profit), 2) AS total_profit,
	MONTH([Order Date]) AS month_num
FROM
	superstore
GROUP BY
	DATENAME(MONTH, [Order Date]),
	MONTH([Order Date])
ORDER BY
	MONTH([Order Date]);