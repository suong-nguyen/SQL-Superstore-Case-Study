/* PROJECT WALKTHOUGH

In this step we create query to answer the following questions

3.4. Shipment Analysis
-- Update shipping_status
-- What percentage of orders is associated with each shipment type?
-- Percentage of orders by shipping mode and status
-- What is the typical wait time between placing an order and its shipment for all orders and for each shipping mode
-- Which order category has the highest likelihood of being shipped late via each class?

*/

--------------------------------------------------------------------------------------------

-- Update shipping_status

		-- Add shipping_status column to your table
		ALTER TABLE Orders
		ADD Shipping_status VARCHAR(20);

		-- Update shipping_status based on the provided logic
		UPDATE o
		SET Shipping_status = 
			CASE 
				WHEN DATEDIFF(day, t.OrderDate, t.ShipDate) > 
					 CASE o.ShipMode
						WHEN 'Same Day' THEN 0
						WHEN 'First Class' THEN 1
						WHEN 'Second Class' THEN 3
						WHEN 'Standard Class' THEN 6
					 END THEN 'Late'
				WHEN DATEDIFF(day, t.OrderDate, t.ShipDate) = 
					 CASE o.ShipMode
						WHEN 'Same Day' THEN 0
						WHEN 'First Class' THEN 1
						WHEN 'Second Class' THEN 3
						WHEN 'Standard Class' THEN 6
					 END THEN 'On-Time'
				ELSE 'Early'
			END
		FROM 
			Orders o
		JOIN
			Time t ON o.TimeID = t.TimeID;


		-- Optional: View the updated table to verify the changes
		SELECT * FROM Orders;


-- What is the typical wait time between placing an order and its shipment for all orders and for each shipping mode
	SELECT 'All Orders' AS ShipMode, AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AverageWaitTime
	FROM Orders o
	JOIN Time t ON o.TimeID = t.TimeID
	UNION
	SELECT 
		ShipMode, AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AverageWaitTime
	FROM Orders o
	JOIN Time t ON o.TimeID = t.TimeID
	GROUP BY ShipMode;



-- What percentage of orders is associated with each shipment type?

	SELECT 
		ShipMode,
		COUNT(*) AS TotalOrders,
		ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS PercentageOfTotalOrders
	FROM Orders
	GROUP BY ShipMode
	ORDER BY 3 DESC


--Percentage of orders by shipping mode and status

	SELECT 
		ShipMode,
		Shipping_status,
		COUNT(*) AS TotalOrders,
		ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY ShipMode), 2) AS PercentageOfTotalOrders
	FROM 
		Orders
	GROUP BY 
		ShipMode, Shipping_status
	ORDER BY 1,4 Desc


	
-- Which order category has the highest likelihood of being shipped via each class?

	WITH CategoryCounts AS (
		SELECT p.Category, COUNT(*) AS CategoryCount
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		GROUP BY p.Category
	),
	OrderCounts AS (
		SELECT p.Category, o.ShipMode, COUNT(*) AS OrderCount
		FROM Orders o
		JOIN Product p ON o.ProductID = p.ProductID
		GROUP BY p.Category, o.ShipMode
	)
	SELECT oc.Category, oc.ShipMode, oc.OrderCount,
		round(CAST(oc.OrderCount AS FLOAT) / cc.CategoryCount * 100,0) AS PercentageOfTotal
	FROM OrderCounts oc
	JOIN CategoryCounts cc ON oc.Category = cc.Category
	ORDER BY 1,4 Desc

