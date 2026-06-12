--Calculate the running total of sales over time
-- i didnt use DATETRUNC for some reason its not working on mssms 21
SELECT*,
SUM(TotalSales) OVER (PARTITION BY Order_YEAR ORDER BY Order_YEAR,Order_MONTH ) AS Running_Total_Sales
FROM(
	SELECT
		YEAR(order_date) AS Order_YEAR,
		MONTH(order_date) AS Order_MONTH,
		SUM(sales_amount) AS TotalSales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date),MONTH(order_date)
)t