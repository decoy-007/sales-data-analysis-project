--Defining a product summary view
CREATE VIEW gold.V_dim_products AS

WITH Product_Summary AS(
SELECT 
	p.product_key,
	p.product_id,
	s.customer_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	s.order_number,
	s.sales_amount,
	s.quantity,
	s.order_date
FROM gold.dim_products p
JOIN gold.fact_sales s
	ON p.product_key = s.product_key
WHERE order_date IS NOT NULL
),
Product_Aggregations AS(
SELECT
	product_key,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS totalCustomers,
	SUM(quantity) AS total_quantity,
	MAX(order_date) AS latest_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) avg_selling_price
FROM Product_Summary
GROUP BY product_key,
		 category,
		 subcategory,
		 cost
)
SELECT*,
CASE 
	WHEN total_sales >= 50000 THEN 'High-Performers'
	WHEN total_sales >= 25000 THEN 'Mid-Range'
	ELSE 'Low-Performers'
END Product_segment,
CASE 
	WHEN total_sales = 0 THEN 0
	ELSE total_sales/total_orders
END Avg_order_Revenue,

CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales/lifespan
END avg_Monthly_revenue
FROM Product_Aggregations 