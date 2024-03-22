/* PROJECT WALKTHOUGH

In this step we create query to answer the following questions


3.2. Product Analysis
-- Total sales and profit by product category/Sub category/segment/region
-- Top 5 subcategory has the most sales/order/profit
-- Bottom 5 subcategory has the most sales/order/profit
-- Average discount for each product category
-- Category Sales Growth: Calculate the year-over-year growth in sales for each product category.
*/

--------------------------------------------------------------------------------------------------------------------------------------



-- Total sales and profit by product category

	SELECT
		p.Category AS ProductCategory,
		ROUND(SUM(o.Profit),0) AS TotalProfit,
		ROUND(SUM(o.Sales),0) AS TotalSales,
		ROUND(SUM(o.Profit) / SUM(o.Sales) * 100, 0) AS ProfitPercentageOverSales,
		ROUND(SUM(o.Sales) / SUM(SUM(o.Sales)) OVER () * 100, 0) AS SalesPercentageOverTotal,
		ROUND(SUM(o.Profit) / SUM(SUM(o.Profit)) OVER () * 100, 0) AS ProfitPercentageOverTotal
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.Category;


-- Total sales and profit by sub category

	SELECT
		p.SubCategory AS ProductSubcategory,
		SUM(o.Profit) AS TotalProfit,
		SUM(o.Sales) AS TotalSales,
		ROUND(SUM(o.Profit) / SUM(o.Sales) * 100, 0) AS ProfitPercentageOverSales,
		ROUND(SUM(o.Sales) / SUM(SUM(o.Sales)) OVER () * 100, 0) AS SalesPercentageOverTotal,
		ROUND(SUM(o.Profit) / SUM(SUM(o.Profit)) OVER () * 100, 0) AS ProfitPercentageOverTotal
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.SubCategory
	ORDER BY 6 DESC


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
	GROUP BY c.Segment
	ORDER BY 6 DESC


--- Sales and profit by market

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


--- Sales and profit by region

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




-- Top 5 subcategory has the most sales/order/profit

-- Order?
	SELECT TOP 5
		p.subCategory AS SubCategory,
		COUNT(*) AS NumberOfOrders,
		ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS PercentageOfOrders
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.SubCategory
	ORDER BY 3 DESC
	
-- Sales?
	SELECT Top 5
		p.subCategory AS SubCategory,
		SUM(o.Sales) AS TotalSales,
		ROUND(SUM(o.Sales) * 100.0 / SUM(SUM(o.Sales)) OVER (), 2) AS PercentageOfTotalSales
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.SubCategory
	ORDER BY 3 DESC

-- Profit?
	SELECT TOP 5
		p.SubCategory AS SubCategory,
		SUM(o.Profit) AS TotalProfit,
		ROUND(SUM(o.Profit) * 100.0 / SUM(SUM(o.Profit)) OVER (), 2) AS PercentageOfTotalProfit
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.SubCategory
	ORDER BY 3 DESC





-- BOTTOM 5 subcategory has the LEAST sales/order/profit

-- Order?
	SELECT TOP 5
		p.subCategory AS SubCategory,
		COUNT(*) AS NumberOfOrders,
		ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS PercentageOfOrders
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.SubCategory
	ORDER BY 3 Asc
	
-- Sales?
	SELECT Top 5
		p.subCategory AS SubCategory,
		SUM(o.Sales) AS TotalSales,
		ROUND(SUM(o.Sales) * 100.0 / SUM(SUM(o.Sales)) OVER (), 2) AS PercentageOfTotalSales
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.SubCategory
	ORDER BY 3 Asc

-- Profit?
	SELECT TOP 5
		p.SubCategory AS SubCategory,
		SUM(o.Profit) AS TotalProfit,
		ROUND(SUM(o.Profit) * 100.0 / SUM(SUM(o.Profit)) OVER (), 2) AS PercentageOfTotalProfit
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.SubCategory
	ORDER BY 3 Asc


-- Average discount for each product category

--- Category
	SELECT
		p.Category AS ProductCategory,
		Round(AVG(o.Discount),2) AS AverageDiscount
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.Category
	Order by 2 desc

--- Sub-category
	SELECT
		p.SubCategory AS ProductSubcategory,
		Round(AVG(o.Discount),2) AS AverageDiscount
	FROM Orders o
	JOIN Product p ON o.ProductID = p.ProductID
	GROUP BY p.SubCategory
	Order by 2 desc



-- Category Sales Growth: Calculate the year-over-year growth in sales for each product category.

	WITH CategorySales AS (
		SELECT
			p.Category AS ProductCategory,
			DATEPART(YEAR, o.OrderDate) AS OrderYear,
			SUM(o.Sales) AS TotalSales
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		GROUP BY p.Category, DATEPART(YEAR, o.OrderDate)
	)
	SELECT
		ProductCategory,
		OrderYear,
		TotalSales,
		LAG(TotalSales) OVER (PARTITION BY ProductCategory ORDER BY OrderYear) AS PreviousYearSales,
		ROUND((TotalSales - LAG(TotalSales) OVER (PARTITION BY ProductCategory ORDER BY OrderYear)) / NULLIF(LAG(TotalSales) OVER (PARTITION BY ProductCategory ORDER BY OrderYear), 0) * 100, 2) AS SalesGrowthRate
	FROM CategorySales
	ORDER BY ProductCategory, OrderYear;
