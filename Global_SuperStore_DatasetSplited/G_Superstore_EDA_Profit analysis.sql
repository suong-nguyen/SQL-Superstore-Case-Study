
/* PROJECT WALKTHOUGH

In this step we create query to answer the following questions

3.5. Identify factors affecting profit - PENDING

-- Who are the top 5 and bottom customers based on profit
-- Who buy the most/least profitable product ?
-- Where is the least profitable product subcategory shipped the most?
-- Identify customers who have made at least five purchases and calculate their average order value

*/




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
