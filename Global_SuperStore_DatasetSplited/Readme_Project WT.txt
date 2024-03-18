/* PROJECT WALKTHOUGH

In this step we create query to answer the following questions


3.1. Sales Trends
-- Total sales revenue, Total profit, Total number of order, Average discount
-- Yearly Growth Rate (sales revenue, Total profit, Total number of order): Calculate the yearly growth rate in sales from one year to the next, using window functions.
-- Monthly Sales Trend: Create a view that shows 3 months with highest sales of each year Growth Trend 
-- Analyze the quantity of orders by order priority
-- Discount (Highest, lowest and average discount rates, Sales and profit distribution across discount ranges)


3.2. Product Analysis
-- Total profit by product category/Sub category/segment/region
-- Which product category has the most orders?
-- Top 5 most profitable sub-category?
-- Top 5 least profitable sub-category?
-- What is the average discount for each product category?
-- Category Sales Growth: Calculate the year-over-year growth in sales for each product category.
-- Product Category Ranking: Rank product categories by total sales in descending order using window functions.


3.3. Geographical and Customer Analysis
-- Total sales revenue, Total profit, Total number of order, Average discount for each market?
-- Who are the top 5 customers based on their total spending?
-- Find the top 5 customers who have made the highest total sales in each market, along with the product category they mostly purchased. 
-- Use a Common Table Expression (CTE) to calculate the total sales for each customer in category, and then retrieve the top 5 customers for each market
-- Where is the least profitable product subcategory shipped the most?
-- Identify customers who have made at least five purchases and calculate their average order value


3.4. Shipment Analysis
-- Update shipping_status
-- What is the typical wait time between placing an order and its shipment?
-- Which order category has the highest likelihood of being shipped via each class?
-- What percentage of orders is associated with each shipment type?
-- List orders that have not been shipped on time/late/early.

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
