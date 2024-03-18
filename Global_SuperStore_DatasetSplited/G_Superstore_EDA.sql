
/* PROJECT WALKTHOUGH

In this step we create query to answer the following questions


3.1. Sales Trends
-- Total sales revenue, Total profit, Total number of order, Average discount
-- Yearly Growth Rate (sales revenue, Total profit, Total number of order): Calculate the yearly growth rate in sales from one year to the next, using window functions.
-- Monthly Sales Trend: Create a view that shows 3 months with highest sales of each year Growth Trend 
-- Analyze the quantity of orders by order priority
-- Discount (Highest, lowest and average discount rates, Sales and profit distribution across discount ranges)

*/

-----------------------------------------------------------------------------------------------------------------------------------------



-- Total sales revenue, Total profit, Total number of order, Average discount

	WITH Aggregates AS (
    
    ---- Total
    SELECT 
        'Total' AS Category,
        SUM(Sales) AS TotalSales,
        SUM(Profit) AS TotalProfit,
        COUNT(*) AS TotalNumberOfOrders,
        AVG(Discount) AS AvgDiscount
    FROM Orders
    
    UNION ALL
    
    --- Yearly
	SELECT 
        'Yearly' AS Category,
        SUM(Sales) AS TotalSales,
        SUM(Profit) AS TotalProfit,
        COUNT(*) AS TotalNumberOfOrders,
        AVG(Discount) AS AvgDiscount
    FROM Orders
    JOIN Time ON Orders.TimeID = Time.TimeID
    GROUP BY Time.OrderYear
   
    UNION ALL

    ---- Monthly
	SELECT 
        'Monthly' AS Category,
        SUM(Sales) AS TotalSales,
        SUM(Profit) AS TotalProfit,
        COUNT(*) AS TotalNumberOfOrders,
        AVG(Discount) AS AvgDiscount
    FROM Orders
    JOIN Time ON Orders.TimeID = Time.TimeID
    GROUP BY Time.OrderYear, Time.OrderMonth
	)
	SELECT 
		Category,
		ROUND(AVG(TotalSales), 2) AS AverageTotalSales,
		ROUND(AVG(TotalProfit), 2) AS AverageTotalProfit,
		ROUND(AVG(TotalNumberOfOrders), 2) AS AverageTotalNumberOfOrders,
		ROUND(AVG(AvgDiscount), 2) AS AverageAvgDiscount
	FROM Aggregates
	GROUP BY Category
	ORDER BY 
		CASE 
			WHEN Category = 'Total' THEN 1
			WHEN Category = 'Yearly' THEN 2
			WHEN Category = 'Monthly' THEN 3
		END;


-- Yearly Growth Rate (sales revenue, Total profit, Total number of order)

	WITH YearlyData AS (
		SELECT 
			t.OrderYear,
			SUM(o.Sales) AS TotalSales,
			SUM(o.Profit) AS TotalProfit,
			COUNT(*) AS TotalNumberOfOrders
		FROM Orders o
		JOIN Time t ON o.TimeID = t.TimeID
		GROUP BY t.OrderYear
	)
	SELECT 
		t1.OrderYear,
		t1.TotalSales,
		t1.TotalProfit,
		t1.TotalNumberOfOrders,
		ROUND(((t1.TotalSales - t2.TotalSales) / t2.TotalSales) * 100, 2) AS SalesGrowthRate,
		ROUND(((t1.TotalProfit - t2.TotalProfit) / t2.TotalProfit) * 100, 2) AS ProfitGrowthRate,
		ROUND(((t1.TotalNumberOfOrders - t2.TotalNumberOfOrders) / t2.TotalNumberOfOrders) * 100, 2) AS NumberOfOrdersGrowthRate
	FROM YearlyData t1
	LEFT JOIN  YearlyData t2 ON t1.OrderYear = t2.OrderYear + 1


		
-- Monthly Sales Trend: Create a view that shows 3 months with highest sales of each year Growth Trend 

	CREATE VIEW MonthlyGrowthTrend AS

	WITH MonthlySalesRanked AS (
		SELECT 
			t.OrderYear,
			t.OrderMonth,
			SUM(o.Sales) AS TotalSales,
			ROW_NUMBER() OVER (PARTITION BY t.OrderYear ORDER BY SUM(o.Sales) DESC) AS SalesRank
		FROM Orders o
		JOIN Time t ON o.TimeID = t.TimeID
		GROUP BY t.OrderYear, t.OrderMonth
	)
	SELECT 
		SalesRank,
		OrderYear,
		OrderMonth,
		TotalSales
	FROM MonthlySalesRanked
	WHERE SalesRank <= 3;



-- Analyze the quantity of orders by order priority
	SELECT
		OrderPriority,
		COUNT(*) AS OrderCount
	FROM Orders
	GROUP BY OrderPriority
	ORDER By OrderCount Desc




---- DISCOUNT

-- Highest, lowest and average discount rates
	SELECT
		MIN(Discount) AS LowestDiscountRate,
		ROUND(AVG(Discount),2) AS AvgDiscountRate,
		MAX(Discount) AS HighestDiscountRate
	FROM Orders;


--- Distribution of sales and profit for different discount ranges

	WITH DiscountBins AS (
		SELECT
			CASE
				WHEN Discount < 0.1 THEN '0-10%'
				WHEN Discount >= 0.1 AND Discount < 0.2 THEN '10-20%'
				WHEN Discount >= 0.2 AND Discount < 0.3 THEN '20-30%'
				WHEN Discount >= 0.3 AND Discount < 0.4 THEN '30-40%'
				ELSE '40%+'
			END AS DiscountRange,
			Sales,
			Profit
		FROM Orders
	)
	SELECT
		DiscountRange,
		COUNT(*) AS NumberOfOrders,
		ROUND(SUM(Sales),0) AS TotalSales,
		ROUND(SUM(Profit),0) AS TotalProfit
	FROM DiscountBins
	GROUP BY DiscountRange
	ORDER BY MIN(CASE WHEN DiscountRange = '0-10%' THEN 1 WHEN DiscountRange = '10-20%' THEN 2 WHEN DiscountRange = '20-30%' THEN 3 WHEN DiscountRange = '30-40%' THEN 4 ELSE 5 END);