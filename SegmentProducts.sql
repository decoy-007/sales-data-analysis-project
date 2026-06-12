--Segment product into cost ranges
-- count how many products fall into each segment
WITH Product_Segments AS(
SELECT
	product_key,
	product_name,
	cost,
	CASE WHEN cost > 1500 THEN 'HIGH'
		 WHEN cost > 800 THEN 'MID'
		 ELSE 'LOW'
	END priceSegment
FROM gold.dim_products
)
SELECT
	priceSegment,
	COUNT(product_key) AS Total_Products
FROM Product_Segments
GROUP BY priceSegment
order by Total_Products DESC;