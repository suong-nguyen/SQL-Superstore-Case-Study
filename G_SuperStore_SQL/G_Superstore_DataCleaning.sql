/* PROJECT WALKTHOUGH

Step 1: Data Source and Structure
	- Create database and import data. Data type has been converted when imported.
	- Create diagram showing relationship between 5 tables of the dataabase. This step also to fix structural errors (if any)

Step 2: Clean data, including: 
	1 - Handle missing data
	2 - Remove duplicate data
	3 - Deal with outliers - Pending
	4 - Standardize/Normalize data - Pending
	
Step 3: EDA - see other file(s)
*/

-------------------------------------------------------------------

--- Step 1: Create database and import data. Check datatype and nullable when importing
	Create database G_Superstore
	Use G_Superstore


--- Step 2: Clean data

	--- Show data
	Select * from Customer
	Select * from Location
	Select * from Orders
	Select * from Product

/* 1 - Handle missing data (Although I have already check on Excel) */

--- Show missing data
	SELECT 'Customer' AS Table_Name,
		   SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS Null_CustomerID,
		   SUM(CASE WHEN CustomerName IS NULL THEN 1 ELSE 0 END) AS Null_CustomerName,
		   SUM(CASE WHEN Segment IS NULL THEN 1 ELSE 0 END) AS Null_Segment
	FROM Customer
	
	SELECT 'Location' AS Table_Name,
		   SUM(CASE WHEN LocationID IS NULL THEN 1 ELSE 0 END) AS Null_LocationID,
		   SUM(CASE WHEN PostalCode IS NULL THEN 1 ELSE 0 END) AS Null_PostalCode,
		   SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Null_City,
		   SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS Null_State,
		   SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS Null_Country,
		   SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS Null_Region,
		   SUM(CASE WHEN Market IS NULL THEN 1 ELSE 0 END) AS Null_Market
	FROM Location
	
	SELECT 'Product' AS Table_Name,
		   SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) AS Null_ProductID,
		   SUM(CASE WHEN ProductName IS NULL THEN 1 ELSE 0 END) AS Null_ProductName,
		   SUM(CASE WHEN SubCategory IS NULL THEN 1 ELSE 0 END) AS Null_SubCategory,
		   SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS Null_Category
	FROM Product
	
		SELECT 'Orders' AS Table_Name,
		   SUM(CASE WHEN RowID IS NULL THEN 1 ELSE 0 END) AS Null_RowID,
		   SUM(CASE WHEN LocationID IS NULL THEN 1 ELSE 0 END) AS Null_LocationID,
		   SUM(CASE WHEN OrderDate IS NULL THEN 1 ELSE 0 END) AS Null_OrderDate,
		   SUM(CASE WHEN ShipDate IS NULL THEN 1 ELSE 0 END) AS Null_ShipDate,
		   SUM(CASE WHEN OrderID IS NULL THEN 1 ELSE 0 END) AS Null_OrderID,
		   SUM(CASE WHEN ShipMode IS NULL THEN 1 ELSE 0 END) AS Null_ShipMode,
		   SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS Null_CustomerID,
		   SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) AS Null_ProductID,
		   SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Null_Sales,
		   SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
		   SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS Null_Discount,
		   SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Null_Profit,
		   SUM(CASE WHEN ShippingCost IS NULL THEN 1 ELSE 0 END) AS Null_ShippingCost,
		   SUM(CASE WHEN OrderPriority IS NULL THEN 1 ELSE 0 END) AS Null_OrderPriority
	FROM Orders;


--- Only Missing 3224 Postcode
--- Check available Postcode
	SELECT country,
	Count(PostalCode) as number_postcode_listed	 
	FROM Location
	WHERE PostalCode IS NOT NULL
	Group by country
	/* all postcode in USA*/


--- Check Missing Postcode
	SELECT *
	FROM Location
	WHERE PostalCode IS NULL and country like '%State'
	/* NO missing postcode in USA, so assuming only USA market needs PostCode, so no action needed*/






/* 2 - Remove duplicate data */

	SELECT 'Customer' AS Table_Name,
		   COUNT(*) - COUNT(DISTINCT CustomerID) AS Duplicate_Count
	FROM Customer
	
	UNION ALL
	SELECT 'Location' AS Table_Name,
		   COUNT(*) - COUNT(DISTINCT LocationID) AS Duplicate_Count
	FROM Location
	
	UNION ALL
	SELECT 'Product' AS Table_Name,
		   COUNT(*) - COUNT(DISTINCT ProductID) AS Duplicate_Count
	FROM Product
	
	UNION ALL
	SELECT 'Orders' AS Table_Name,
		   COUNT(*) - COUNT(DISTINCT RowID) AS Duplicate_Count
	FROM Orders;





/* 	3 - Deal with outliers */

/*	4 - Standardize/Normalize data */



