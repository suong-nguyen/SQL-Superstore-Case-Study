Create database Global_Superstore
use Global_Superstore

/* Check data */
--View all data
		SELECT * 
		FROM orders;
-- Check null
		SELECT * 
		FROM orders
		WHERE [Row ID] IS NULL OR [Order ID] IS NULL OR [Order Date] IS NULL OR [Ship Date] IS NULL OR Sales IS NULL;
-- Check duplicated orderID 
		SELECT *
		FROM Orders
		WHERE ([Row ID])
		IN (
			SELECT [Row ID]    
			FROM Orders
			GROUP BY [Row ID]
			HAVING COUNT(*) > 1
		)
		ORDER BY [Row ID]


/* 3. Exploratory Data Analysis*/

-- 3.1. Sales Trends--- 

	-- 3.1.1. Sales at a glance
		-- What is the total sales revenue for all orders in the dataset?
				SELECT ROUND(SUM(Sales),0) AS Total_sales_revenue 
				FROM Orders;

		-- What is the total profit for all orders in the dataset?
				SELECT ROUND(SUM(profit),0) AS TotalProfit
				FROM orders;

		-- How many orders are in the dataset?
				SELECT COUNT([Order ID]) AS Total_Orders
				FROM orders;

		--  What is the average discount applied to orders?
				SELECT ROUND(AVG(discount),2) AS AverageDiscount
				FROM orders;

		--  What is the total sales revenue for each market?
				SELECT Market, ROUND(SUM(sales),0) AS TotalSalesRevenue
				FROM orders
				GROUP BY Market
				ORDER BY TotalSalesRevenue DESC;

		-- How many orders were placed in each year?
				SELECT YEAR([Order Date]) AS year, COUNT(*) AS NumberofOrders
				FROM orders
				GROUP BY YEAR([Order Date])
				ORDER BY YEAR([Order Date]);

		--3.1.7. How much profit each year?
				SELECT YEAR([Order Date]) AS year, round(sum(Profit),0) AS Yearprofit
				FROM orders
				GROUP BY YEAR([Order Date])
				ORDER BY YEAR([Order Date]);


	-- 3.1.2. Monthly Sales Trend: Create a view that shows the monthly sales trend for each year. Include the year, month, and total sales for each month.
				-- Create a view that shows the monthly sales trend for each year. Include the year, month, and total sales for each month.
				CREATE VIEW Monthly_sales_trend AS
				SELECT YEAR([Order Date]) AS year, MONTH([Order Date]) AS months, 
				round(SUM(sales),0) AS Totalsales
				FROM orders
				GROUP BY YEAR([Order Date]), MONTH([Order Date]);
		
				--QUERYING THE VIEW--
				SELECT * 
				FROM Monthly_sales_trend 
				ORDER BY year, months;

	-- 3.1.3. Yearly Growth Rate: Calculate the yearly growth rate in sales from one year to the next, using window functions.
				WITH YearlySales AS (
						SELECT 
							YEAR([Order Date]) AS Year,
							Round(SUM(Sales),0) AS TotalSales,
							LAG(Round(SUM(Sales),0)) OVER (ORDER BY YEAR([Order Date])) AS PreviousYearSales
						FROM orders
						GROUP BY YEAR([Order Date])
					)
					SELECT 
						Year,
						TotalSales,
						PreviousYearSales,
						ROUND((TotalSales - PreviousYearSales) / PreviousYearSales * 100, 0) AS YearlyGrowthRate
					FROM YearlySales;



-- 3.2. Product Analysis---
		---3.2.Product overview
				-- Which product category has the most orders?
				SELECT TOP 1 Category, COUNT(*) AS NumberOfOrders
				FROM orders
				GROUP BY Category
				ORDER BY NumberOfOrders DESC;

				-- Most profitable sub-category?
				SELECT Top 5 [Sub-Category], ROUND(SUM(profit),0) AS TotalProfit
				FROM orders
				GROUP BY [Sub-Category]

				-- Top 5 least profitable sub-category?
				SELECT TOP 5 [Sub-Category], ROUND(SUM(profit), 0) AS TotalProfit
				FROM orders
				GROUP BY [Sub-Category]
				ORDER BY TotalProfit ASC;

				-- What is the average discount for each product category?
				SELECT Category,ROUND(AVG(discount), 2) AS AverageDiscount
				FROM orders
				GROUP BY category;

		-- 3.2.2. Category Sales Growth: Calculate the year-over-year growth in sales for each product category.
				WITH YearbyCategorySales AS
				(
					SELECT YEAR([Order Date]) AS Year, Category, ROUND(SUM(sales), 0) AS PresentYrSales
					FROM orders
					GROUP BY YEAR([Order Date]), Category
				)

				SELECT 
					C1.Category, 
					C1.Year AS PrevYear, 
					C2.Year AS CurrentYear, 
					C1.PresentYrSales AS PrevYearSales, 
					C2.PresentYrSales AS CurrentYearSales,
					ROUND(((C2.PresentYrSales - C1.PresentYrSales) / NULLIF(C1.PresentYrSales, 0)) * 100, 2) AS PercentageGrowth
				FROM 
					YearbyCategorySales C1
				JOIN 
					YearbyCategorySales C2 ON C1.Category = C2.Category AND C1.Year = C2.Year - 1
				ORDER BY 
					C1.Category, 
					C1.Year;

		-- 3.2.3. Product Category Ranking: Rank product categories by total sales in descending order using window functions.
				SELECT category, Round(SUM(sales),0) AS TotalSales,
				RANK() OVER (ORDER BY SUM(sales) DESC) AS CategoryRank
				FROM orders
				GROUP BY category
				ORDER BY TotalSales DESC;

-- 3.3. Geographical and Customer Analysis
		-- 3.3.1. Who are the top 5 customers based on their total spending?
			SELECT Top 5 [Customer Name], Round(SUM(sales),0) AS TotalSpending
			FROM orders
			GROUP BY [Customer Name]
			ORDER BY TotalSpending DESC

		-- 3.3.2. Find the top 5 customers who have made the highest total sales in each state, along with the product category they mostly purchased
			WITH CustomerSales AS (
				SELECT 
					[Customer Name],
					Market,
					Category,
					SUM(sales) AS Total_Sales,
					RANK() OVER (PARTITION BY Market ORDER BY SUM(sales) DESC) AS Sales_Rank
				FROM orders
				GROUP BY [Customer Name], Market, Category
			)
			SELECT 
				[Customer Name],
				Market,
				Category AS Predominant_Product_Category,
				Total_Sales,
				Sales_Rank
			FROM CustomerSales
			WHERE Sales_Rank <= 5
			ORDER BY Market, Total_Sales DESC;

		-- 3.3.3. Where is the least profitable product subcategory shipped the most? 
			WITH LeastProfitableSubcategory AS (
				SELECT [Sub-Category], SUM(profit) AS total_profit
				FROM Orders
				GROUP BY [Sub-Category]
				ORDER BY total_profit ASC
				OFFSET 0 ROWS
				FETCH FIRST 1 ROWS ONLY
			)

			SELECT 
				Market,
				[Sub-Category],
				COUNT(*) AS no_of_shipments,
				SUM(profit) AS profit_in_each_market,
				Round((SUM(profit) / (SELECT SUM(profit) FROM Orders)),5) * 100 AS profit_percentage
			FROM 
				Orders
			WHERE 
				[Sub-Category] IN (SELECT [Sub-Category] FROM LeastProfitableSubcategory)
			GROUP BY 
				Market, [Sub-Category]
			ORDER BY 
				profit_in_each_market DESC;

		-- 3.3.4. Identify customers who have made at least five purchases and calculate their average order value.
			SELECT [Customer Name], COUNT(*) AS TotalOrders, ROUND(AVG(sales), 2) AS AverageOrderValue
			FROM orders
			GROUP BY [Customer Name]
			HAVING COUNT(*) >= 5
			ORDER BY TotalOrders, AverageOrderValue DESC;


--3.4. Shipment Analysis
		-- 3.4.1. Add shipping status for each order
			ALTER TABLE Orders
			ADD Shipping_status VARCHAR(20);

			-- Update shipping_status based on the provided logic
			UPDATE Orders
			SET Shipping_status = 
				CASE 
					WHEN DATEDIFF(day, [Order Date], [Ship Date]) > 
						 CASE [Ship Mode]
							WHEN 'Same Day' THEN 0
							WHEN 'First Class' THEN 1
							WHEN 'Second Class' THEN 3
							WHEN 'Standard Class' THEN 6
						END THEN 'Late'
					WHEN DATEDIFF(day, [Order Date], [Ship Date]) = 
						 CASE [Ship Mode]
							WHEN 'Same Day' THEN 0
							WHEN 'First Class' THEN 1
							WHEN 'Second Class' THEN 3
							WHEN 'Standard Class' THEN 6
						END THEN 'On-Time'
					ELSE 'Early'
				END;

			-- Optional: View the updated table to verify the changes
			SELECT * FROM Orders;

		-- 3.4.2. What is the typical wait time between placing an order and its shipment?
			SELECT Avg(DATEDIFF(day, [Order Date], [Ship Date])) AS AVG_SHIPPING_DAYS
			FROM Orders

		--3.4.3.  Which order categoty has the highest likelihood of being shipped via each class?
			SELECT 
			[Ship Mode],
			Category
				, COUNT(*) AS 'No. Of Times'
			FROM Orders
			GROUP BY [Ship Mode], Category ORDER BY COUNT(*) DESC;

		-- 3.4.4. What percentage of orders is associated with each shipment type?
			SELECT 
				[Ship Mode], COUNT(*) AS total_orders,
				round((COUNT(*) * 100 / (SELECT COUNT(*) FROM Orders)),0) AS '%'
			FROM 
				 Orders 
			GROUP BY  [Ship Mode] ORDER BY '%' desc;
