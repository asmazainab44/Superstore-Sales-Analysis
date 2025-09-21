-- Create and use database

CREATE DATABASE sales_analysis;
USE sales_analysis;

-- View the raw data 

SELECT * FROM superstore;

-- Total record count 

SELECT COUNT(*) AS Total_Records
FROM superstore;

-- Remove existing Row ID column

ALTER TABLE sales_analysis.superstore 
DROP COLUMN `Row ID`;

-- Add a new Row ID column as the first column

ALTER TABLE sales_analysis.superstore 
ADD COLUMN `Row ID` INT FIRST;

-- Initialize a variable to generate row num then update each row with a sequential Row ID

SET @row_num = 0;    
UPDATE sales_analysis.superstore
SET `Row ID` = (@row_num := @row_num + 1);

-- Null Value check 

SELECT COUNT(*) AS Total_Null_Records
FROM superstore
WHERE `Row ID` is null;

SELECT *
FROM superstore
WHERE Sales is null or Sales = '';

-- Duplicate Order ID check 

SELECT `Order ID`, COUNT(*)
FROM superstore
GROUP BY `Order ID`
HAVING 	COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- Distinct Category, Region, Ship Mode and Customer Segments

SELECT DISTINCT Category
FROM superstore;

SELECT DISTINCT Region
FROM superstore;

SELECT DISTINCT `Ship Mode`
FROM superstore;

SELECT DISTINCT Segment
FROM superstore;

-- Total Sales, Quantiy and Profit

SELECT ROUND(SUM(sales),2) AS Total_Sales,
	   SUM(Quantity) AS Total_Quantity,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY Category
ORDER BY Total_Sales DESC, Total_Quantity DESC, Total_Profit DESC;

-- Region wise Total Sales, Total Quantity and Total Proft

SELECT Region,
	   ROUND(SUM(Sales),2) AS Total_Sales,
       SUM(quantity) AS Total_Quantity,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY Region
ORDER BY Total_Sales DESC, Total_Quantity DESC, Total_Profit DESC;

-- Ship Mode wise Total Sales, Total Quantity and Total Profit 

SELECT `Ship Mode`,
       ROUND(SUM(Sales),2) AS Total_Sales,
       SUM(Quantity) AS Total_Quantity,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY `Ship Mode`
ORDER BY Total_Sales DESC, Total_Quantity DESC, Total_Profit DESC;

-- Customer Segment wise Total Sales, Total Quantity and Total Profit

SELECT Segment,
       ROUND(SUM(Sales),2) AS Total_Sales,
       SUM(Quanity) AS Total_Quantity,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY Segment
ORDER BY Total_Sales DESC,Total_Quantity DESC, Total_Profit DESC;

-- Yearly Total Sales, Total Quantity and Total Profit 

SELECT Year(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,
	   ROUND(SUM(Sales),2) AS Total_Sales,
	   SUM(Quantity) AS Total_Quantity,
	   ROUND(SUM(Profit),2) AS Total_Profit		
FROM superstore
GROUP BY Year(STR_TO_DATE(`Order Date`, '%d-%m-%Y'))
ORDER BY Order_Year;


SELECT YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year, Region,
       ROUND(SUM(Sales),2) AS Total_Sales,
       SUM(Quantity) AS Total_Quantity,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')), Region
ORDER BY Order_Year, Region;


-- Monthly Total Sales, Total Quantity and Total Profit

SELECT MONTHNAME(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Month,
       ROUND(SUM(Sales),2) AS Total_Sales,
       SUM(Quantity) AS Total_Quantity,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')),
         MONTHNAME(STR_TO_DATE(`Order Date`, '%d-%m-%Y'))
ORDER BY MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y'));

-- Product categories and Sub Categories wise Sales and Profit 

SELECT Category,
	   `Sub-Category`,
	   ROUND(SUM(Sales),2) AS Total_Sales,
	   ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY Category,`Sub-Category`
ORDER BY Total_Sales DESC,Total_Profit DESC;

-- Top 10 Sales Product Name

SELECT `Product Name`,
		ROUND(SUM(Sales),2) AS Total_Sales
FROM superstore
GROUP BY `Product Name`
ORDER BY Total_Sales DESC
Limit 10;

-- Bottom 10 Sales Product Name 

SELECT `Product Name`,
		ROUND(SUM(Sales),2) AS Total_Sales
FROM superstore
GROUP BY `Product Name`
ORDER BY Total_Sales
Limit 10;

-- Top 10 Profit Product Name 

SELECT `Product Name`,
		ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY `Product Name`
ORDER BY Total_Profit DESC
LIMIT 10;

-- Bottom 10 Profit Product Name 

SELECT `Product Name`,
		ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY `Product Name`
ORDER BY Total_Profit
LIMIT 10;


-- Profit Margin by Product Category 

SELECT Category,
	   ROUND(SUM(Sales),2) AS Total_Sales,
	   ROUND(SUM(Profit),2) AS Total_Profit,
	   ROUND(SUM(Profit)*100.0/SUM(Sales),2) AS Profit_Margin
FROM superstore
GROUP BY Category
ORDER BY Profit_Margin DESC;


-- Sales Growth rate between current month and previous Month 

WITH Monthly_Sales AS (
	SELECT FORMAT(`Order Date`, 'yyyy-MM') AS YearMonth,
	       SUM(Sales) AS Total_Sales
    FROM superstore
    GROUP BY FORMAT(`Order Date`, 'yyyy-MM')
)

SELECT YearMonth,
	  Total_Sales,
	  LAG(Total_Sales) OVER(ORDER BY YearMonth) AS Prev_Month_Sales,
	  ROUND((Total_Sales - LAG(Total_Sales) OVER(ORDER BY YearMonth))*100.0/LAG(Total_Sales) OVER(ORDER BY YearMonth),2) AS Growth_rate
FROM Monthly_Sales
ORDER BY YearMonth;


WITH Monthly_Sales AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m-%d-%Y'), '%Y-%m') AS YearMonth,
        SUM(Sales) AS Total_Sales
    FROM superstore
    GROUP BY DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m-%d-%Y'), '%Y-%m')
)
SELECT 
    YearMonth,
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY YearMonth) AS Prev_Month_Sales,
    ROUND(
        (Total_Sales - LAG(Total_Sales) OVER (ORDER BY YearMonth)) * 100.0 /
        LAG(Total_Sales) OVER (ORDER BY YearMonth),
        2
    ) AS Growth_rate
FROM Monthly_Sales
ORDER BY YearMonth;

-- Product WITH negative Profit(Loss Making Product)

SELECT `Product Name`,
	   ROUND(SUM(Profit),2) AS Total_Profit
FROM superstore
GROUP BY `Product Name`
HAVING SUM(Profit) < 0
ORDER BY Total_Profit;

-- Top Sales Product by Region 

WITH Rank_Cte AS (
       SELECT Region,
			  `Product Name`,
			  SUM(Sales) AS Total_Sales,
			  RANK() OVER(PARTITION BY Region ORDER BY SUM(sales) DESC) AS Rnk
FROM superstore
GROUP BY Region,`Product Name`
) 

SELECT *
FROM Rank_Cte
WHERE Rnk = 1;

-- Top Profit Product by Region 

WITH Rank_Cte AS (
SELECT Region,
	   `Product Name`,
	   SUM(Profit) AS Total_Sales,
	   RANK() OVER(PARTITION BY Region ORDER BY SUM(profit) DESC) AS Rnk
FROM superstore
GROUP BY Region,`Product Name`) 
SELECT *
FROM Rank_Cte
WHERE Rnk = 1;

-- Customer WITH only one Purchase 

SELECT `Customer ID`,
	   `Customer Name`,
	   COUNT(DISTINCT `Order ID`) AS Total_Order
FROM superstore
GROUP BY `Customer ID`,`Customer Name`
HAVING COUNT(DISTINCT `Order ID`) = 1
ORDER BY `Customer ID`;

-- Average Discount Impact ON Profit 

SELECT ROUND(Discount, 2) AS Discount_Level,
       ROUND(AVG(Profit), 2) AS Avg_Profit
FROM superstore
GROUP BY ROUND(Discount, 2)
ORDER BY Discount_Level;

-- Shipping Mode Usage Trend 

SELECT `Ship Mode`,
	   COUNT(*) AS Cnt,
	   ROUND(SUM(Sales),2) AS Total_Sales
FROM superstore
GROUP BY `Ship Mode`
ORDER BY Cnt DESC;