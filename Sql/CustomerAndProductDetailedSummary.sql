/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors
Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

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



/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

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

