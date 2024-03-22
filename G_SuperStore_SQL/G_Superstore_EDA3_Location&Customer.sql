/* PROJECT WALKTHOUGH

In this step we create query to answer the following questions

3.3. Geographical and Customer Analysis
-- Total sales revenue, profit for each market/region/segment
-- Who are the top 5 customers based on their total spending?
-- Find the top 5 customers who have made the highest total sales in each market, along with the product category they mostly purchased. 
-- Use a Common Table Expression (CTE) to calculate the total sales for each customer in category, and then retrieve the top 5 customers for each market

*/

-----------------------------------------------------------------------------------------------------------------------------------------

-- Total sales revenue, profit for each market?

	SELECT
		l.Market AS LocationRegion,
		SUM(o.Profit) AS TotalProfit,
		SUM(o.Sales) AS TotalSales,
		ROUND(SUM(o.Profit) / SUM(o.Sales) * 100, 0) AS ProfitPercentageOverSales,
		ROUND(SUM(o.Sales) / SUM(SUM(o.Sales)) OVER () * 100, 0) AS SalesPercentageOverTotal,
		ROUND(SUM(o.Profit) / SUM(SUM(o.Profit)) OVER () * 100, 0) AS ProfitPercentageOverTotal
	FROM Orders o
	JOIN Location l ON o.LocationID = l.LocationID
	GROUP BY l.Market
	ORDER BY 6 DESC



-- Total sales revenue, profit for region?
	SELECT
		l.Market AS Martket,
		l.region AS Region,
		SUM(o.Profit) AS TotalProfit,
		SUM(o.Sales) AS TotalSales,
		ROUND(SUM(o.Profit) / SUM(o.Sales) * 100, 0) AS ProfitPercentageOverSales,
		ROUND(SUM(o.Sales) / SUM(SUM(o.Sales)) OVER () * 100, 0) AS SalesPercentageOverTotal,
		ROUND(SUM(o.Profit) / SUM(SUM(o.Profit)) OVER () * 100, 0) AS ProfitPercentageOverTotal
	FROM Orders o
	JOIN Location l ON o.LocationID = l.LocationID
	GROUP BY l.Market, l.region
	ORDER BY 1 Desc,6 DESC



-- Sales and profit by customer segment

	SELECT
		c.Segment AS CustomerSegment,
		SUM(o.Profit) AS TotalProfit,
		SUM(o.Sales) AS TotalSales,
		ROUND(SUM(o.Profit) / SUM(o.Sales) * 100, 0) AS ProfitPercentageOverSales,
		ROUND(SUM(o.Sales) / SUM(SUM(o.Sales)) OVER () * 100, 0) AS SalesPercentageOverTotal,
		ROUND(SUM(o.Profit) / SUM(SUM(o.Profit)) OVER () * 100, 0) AS ProfitPercentageOverTotal
	FROM Orders o
	JOIN Customer c ON o.CustomerID = c.CustomerID
	GROUP BY c.Segment;


-- Who are the top 5 and bottom 5 customers based on their total spending?

	---TOP
	SELECT TOP 5
		c.CustomerName,
		ROUND(SUM(o.Sales), 0) AS TotalSpending,
		ROUND(SUM(o.Sales) * 100.0 / (SELECT SUM(Sales) FROM Orders), 2) AS PercentageOfTotal
	FROM Orders o
	JOIN Customer c ON o.CustomerID = c.CustomerID
	GROUP BY c.CustomerName
	ORDER BY TotalSpending DESC;

	---BOTTOM
	SELECT TOP 5
		c.CustomerName,
		ROUND(SUM(o.Sales), 0) AS TotalSpending,
		ROUND(SUM(o.Sales) * 100.0 / (SELECT SUM(Sales) FROM Orders), 2) AS PercentageOfTotal
	FROM Orders o
	JOIN Customer c ON o.CustomerID = c.CustomerID
	GROUP BY c.CustomerName
	ORDER BY TotalSpending;


-- Find the top 5 customers who have made the highest total sales in each market.
-- Use a Common Table Expression (CTE) to calculate the total sales for each customer in category, and then retrieve the top 5 customers for each market

	---- BY MARKET
	WITH CustomerSales AS (
		SELECT 
			l.Market,
			RANK() OVER (PARTITION BY l.Market ORDER BY SUM(o.Sales) DESC) AS SalesRank,
			c.CustomerName,
			SUM(o.Sales) AS TotalSales
		FROM Orders o
		JOIN Customer c ON o.CustomerID = c.CustomerID
		JOIN Location l ON o.LocationID = l.LocationID
		GROUP BY l.Market, c.CustomerName
	)
	SELECT
		Market,
		SalesRank,
		CustomerName,
		TotalSales		
	FROM CustomerSales
	WHERE SalesRank <= 5
	ORDER BY Market, TotalSales DESC;


		---- BY SEGMENT
	WITH CustomerSegmentSales AS (
		SELECT 
			c.Segment,
			RANK() OVER (PARTITION BY c.Segment ORDER BY SUM(o.Sales) DESC) AS SalesRank,
			c.CustomerName,
			SUM(o.Sales) AS TotalSales			
		FROM Orders o
		JOIN Customer c ON o.CustomerID = c.CustomerID
		GROUP BY c.CustomerName, c.Segment
	)
	SELECT
		Segment,
		SalesRank,
		CustomerName,
		TotalSales	
	FROM CustomerSegmentSales
	WHERE SalesRank <= 5
	ORDER BY Segment, TotalSales DESC;



