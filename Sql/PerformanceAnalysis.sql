--Analyze the yearly performance of products by comparing thier sales
--to both the average sales performance of the product and the previous years sales

WITH Yearly_Product_sale AS(
SELECT
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales_amount) AS currentSales
FROM gold.fact_sales f
JOIN gold.dim_products p
	ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY 
	YEAR(f.order_date),
	p.product_name
)
SELECT
	order_year,
	product_name,
	currentSales,
	AVG(currentSales) OVER (PARTITION BY product_name) avgSales,
	currentSales - AVG(currentSales) OVER (PARTITION BY product_name) diff_avg,
	CASE 
		WHEN currentSales - AVG(currentSales) OVER (PARTITION BY product_name) > 0 THEN 'Above avg'
		WHEN currentSales - AVG(currentSales) OVER (PARTITION BY product_name) < 0 THEN 'Below avg'
		ELSE 'Avg'
	END Avg_change,
	LAG(currentSales) OVER (PARTITION BY product_name ORDER BY order_year) AS PreviousYearSales,
	currentSales - LAG(currentSales) OVER (PARTITION BY product_name ORDER BY order_year) diff_previousYear,
	CASE 
		WHEN currentSales - LAG(currentSales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increased'
		WHEN currentSales - LAG(currentSales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreased'
		ELSE 'no change'
	END Sales_change
FROM Yearly_Product_sale;