
--Defining a customer summary view
CREATE VIEW gold.V_dim_products AS

WITH Customer_Summary AS(
SELECT
	c.customer_key,
	COUNT(DISTINCT order_number)AS total_orders,
	SUM(f.sales_amount)AS total_sales,
	SUM(f.quantity)AS total_quantity_purchased,
	COUNT(DISTINCT f.product_key) AS total_products,
	MAX(order_date) AS last_orderDate,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan_Months
FROM gold.dim_customers c
JOIN gold.fact_sales f
	ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
GROUP BY c.customer_key

		 
),
Customer_details AS(
SELECT
	customer_key,
	customer_number,
	first_name + ' ' + last_name AS customer_name,
	DATEDIFF(YEAR,birthdate ,GETDATE())  AS Age
FROM gold.dim_customers
)
SELECT
	cs.customer_key,
	customer_number,
	cd.customer_name,
	cd.Age,
	cs.total_orders,
	cs.total_sales,
	cs.total_quantity_purchased,
	cs.total_products,
	cs.lifespan_Months,
	DATEDIFF(MONTH,cs.last_orderDate , GETDATE()) [RecentOrder(Months)],
	CASE 
		WHEN cs.lifespan_Months >= 12 AND cs.total_sales > 5000 THEN 'VIP'
		WHEN cs.lifespan_Months >= 12 AND cs.total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment,
	CASE 
		WHEN cs.total_sales = 0 THEN 0
		ELSE cs.total_sales / cs.total_orders
	END Avg_Order_Value,
	CASE WHEN cs.lifespan_Months = 0 THEN cs.total_sales
		 ELSE total_sales / cs.lifespan_Months
	END AS avg_monthly_spend
FROM Customer_Summary cs
JOIN Customer_details cd
	ON cs.customer_key = cd.customer_key
