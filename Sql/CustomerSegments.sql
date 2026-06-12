/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH Customer_Spending AS(
SELECT
	c.customer_key,
	SUM(f.sales_amount) AS TotalSales,
	MIN(order_date) first_order,
	MAX(order_date) last_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
FROM gold.fact_sales f
JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY C.customer_key
)
SELECT
CASE 
	WHEN lifespan >= 12 AND TotalSales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND TotalSales <=5000 THEN 'Regular'
	ELSE 'New'
END customerSegment,
COUNT(customer_key) AS Total_customers
FROM Customer_Spending
GROUP BY CASE 
	WHEN lifespan >= 12 AND TotalSales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND TotalSales <=5000 THEN 'Regular'
	ELSE 'New'
END;