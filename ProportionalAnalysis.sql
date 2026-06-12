--Which categories contribute the to overall sales
WITH Category_Sales AS(
SELECT 
	category,
	SUM(sales_amount) AS TotalSales
FROM gold.fact_sales f
JOIN gold.dim_products p
	ON f.product_key = p.product_key
GROUP BY category
)
SELECT*,
	SUM(TotalSales) OVER () overallSales,
	CONCAT(ROUND((CAST (TotalSales AS FLOAT)/SUM(TotalSales) OVER ()) * 100,2), '%') AS Percentage
FROM Category_Sales
ORDER BY TotalSales DESC 