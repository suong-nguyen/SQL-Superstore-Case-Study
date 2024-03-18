
/* PROJECT WALKTHOUGH

In this step we create query to answer the following questions

3.5. Identify factors affecting profit


-- Calculates basic descriptive statistics for the 'Profit'.
-- Analyzes profitability trends over time, aggregating profits by year. 
-- Analyzes profitability by customer segment. 
-- Analyzes profitability by product category. 
-- Analyzes profitability by location (region).
-- Time-Series Analysis with Moving Averages
-- Segment-Wise Contribution to Profitability
-- Where is the least/most profitable product subcategory shipped the most?
-- Who are the top 5 and bottom customers based on profit
-- Who buy the most/least profitable product ?

*/




-- Descriptive Statistics for Profit column
		SELECT 
			MIN(Profit) AS MinProfit,
			MAX(Profit) AS MaxProfit,
			AVG(Profit) AS AvgProfit,
			STDEV(Profit) AS ProfitStdDev
		FROM Orders;

-- Profitability Analysis over Time (Yearly)
		SELECT OrderYear, AVG(Profit) AS AvgProfit
		FROM Orders o
		JOIN Time t ON o.TimeID = t.TimeID
		GROUP BY OrderYear
		ORDER BY OrderYear;

-- Profitability Analysis by Customer Segment
		SELECT c.Segment, AVG(o.Profit) AS AvgProfit
		FROM Orders o
		JOIN Customer c ON o.CustomerID = c.CustomerID
		GROUP BY c.Segment
		ORDER BY 2 Desc

-- Profitability Analysis by Product Category
		SELECT p.Category, AVG(o.Profit) AS AvgProfit
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		GROUP BY p.Category
		ORDER BY 2 Desc

-- Profitability Analysis by Location (Region)
		SELECT l.Region, AVG(o.Profit) AS AvgProfit
		FROM Orders o
		JOIN Location l ON o.LocationID = l.LocationID
		GROUP BY l.Region
		ORDER BY 2 Desc



--- Time-Series Analysis with Moving Averages
		WITH ProfitabilityByMonth AS (
			SELECT 
				FORMAT(OrderDate, 'yyyy-MM') AS YearMonth, AVG(Profit) AS AvgProfit
			FROM Orders o
			JOIN Time t ON o.TimeID = t.TimeID
			GROUP BY FORMAT(OrderDate, 'yyyy-MM')
		)

		SELECT 
			YearMonth, AvgProfit,
			AVG(AvgProfit) OVER (ORDER BY YearMonth ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING) AS MovingAvgProfit
		FROM ProfitabilityByMonth
		ORDER BY YearMonth;

-- Segment-Wise Contribution to Profitability
		SELECT 
			c.Segment,
			SUM(o.Profit) AS TotalProfit,
			SUM(o.Profit) / (SELECT SUM(Profit) FROM Orders) AS ProfitContribution
		FROM Orders o
		JOIN Customer c ON o.CustomerID = c.CustomerID
		GROUP BY c.Segment;



-- Where is the least profitable product subcategory shipped the most?


	WITH LeastProfitableSubcategory AS (
		SELECT TOP 1 p.SubCategory, SUM(o.Profit) AS TotalProfit
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		GROUP BY p.SubCategory
		ORDER BY TotalProfit ASC
	),
	CountryShipments AS (
		SELECT 
			l.Country,
			p.SubCategory,
			COUNT(*) AS NumberOfShipments,
			SUM(o.Profit) AS Profit,
			ROUND(SUM(o.Profit) / SUM(SUM(o.Profit)) OVER (), 5) * 100 AS ProfitPercentage
		FROM Orders o
		JOIN Location l ON o.LocationID = l.LocationID
		JOIN Product p ON o.ProductID = p.ProductID
		WHERE p.SubCategory IN (SELECT SubCategory FROM LeastProfitableSubcategory)
		GROUP BY l.Country, p.SubCategory
	)
	SELECT TOP 5
		Country, SubCategory, NumberOfShipments, Profit, ProfitPercentage
	FROM CountryShipments
	ORDER BY Profit DESC;
	

-- Where is the most profitable product subcategory shipped the most?

	WITH MostProfitableSubcategory AS (
		SELECT TOP 1 p.SubCategory, SUM(o.Profit) AS TotalProfit
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		GROUP BY p.SubCategory
		ORDER BY TotalProfit DESC
	),
	CountryShipments AS (
		SELECT 
			l.Country,
			p.SubCategory,
			COUNT(*) AS NumberOfShipments,
			SUM(o.Profit) AS Profit,
			ROUND(SUM(o.Profit) / SUM(SUM(o.Profit)) OVER (), 5) * 100 AS ProfitPercentage
		FROM Orders o
		JOIN Location l ON o.LocationID = l.LocationID
		JOIN Product p ON o.ProductID = p.ProductID
		WHERE p.SubCategory IN (SELECT SubCategory FROM MostProfitableSubcategory)
		GROUP BY l.Country, p.SubCategory
	)
	SELECT TOP 5 Country, SubCategory, NumberOfShipments, Profit, ProfitPercentage
	FROM CountryShipments
	ORDER BY NumberOfShipments DESC;



-- Who are the top 5 and bottom customers based on profit


	SELECT 
		c.CustomerID,
		c.CustomerName,
		SUM(o.Profit) AS TotalProfit
	FROM Orders o
	JOIN Customer c ON o.CustomerID = c.CustomerID
	GROUP BY c.CustomerID, c.CustomerName
	ORDER BY TotalProfit DESC
	OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY; -- Top 5 customers

	SELECT 
		c.CustomerID,
		c.CustomerName,
		SUM(o.Profit) AS TotalProfit
	FROM Orders o
	JOIN Customer c ON o.CustomerID = c.CustomerID
	GROUP BY c.CustomerID, c.CustomerName
	ORDER BY TotalProfit ASC
	OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY; -- Bottom 5 customers


	
-- Who buy the most/least profitable product ?

--- Most best-buyer of most profitable product Copiers
	WITH MostProfitableSubcategory AS 
	(
		SELECT TOP 1 p.SubCategory, SUM(o.Profit) AS TotalProfit
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		GROUP BY p.SubCategory
		ORDER BY TotalProfit DESC
	),
	CustomerProfits AS 
	(
		SELECT 
			c.CustomerID, c.CustomerName, SUM(o.Profit) AS TotalProfit
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		JOIN MostProfitableSubcategory mps ON p.SubCategory = mps.SubCategory
		JOIN Customer c ON o.CustomerID = c.CustomerID
		GROUP BY c.CustomerID, c.CustomerName
	)
	SELECT TOP 5 cp.CustomerID, cp.CustomerName, cp.TotalProfit
	FROM CustomerProfits cp
	ORDER BY cp.TotalProfit DESC;


--- LEAST best-buyer of most profitable product TABLEs
	WITH MostProfitableSubcategory AS 
	(
		SELECT TOP 1 p.SubCategory, SUM(o.Profit) AS TotalProfit
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		GROUP BY p.SubCategory
		ORDER BY TotalProfit
	),
	CustomerProfits AS 
	(
		SELECT 
			c.CustomerID, c.CustomerName, SUM(o.Profit) AS TotalProfit
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		JOIN MostProfitableSubcategory mps ON p.SubCategory = mps.SubCategory
		JOIN Customer c ON o.CustomerID = c.CustomerID
		GROUP BY c.CustomerID, c.CustomerName
	)
	SELECT TOP 5 cp.CustomerID, cp.CustomerName, cp.TotalProfit
	FROM CustomerProfits cp
	ORDER BY cp.TotalProfit;