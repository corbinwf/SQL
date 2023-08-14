-- Analyzing Product Sales and Launches

-- Objective: Analyze product sales to understand how each product contributes to the business and how product launches impact the overall portfolio
-- Common use cases:
-- Analyzing sales and revenue by product
-- Monitoring the effect of adding a new product to the portfolio
-- Watching product sales trends to understand the overall health of a business

-- Key terms: orders, revenue, margin, and average revenue generated per order (AOV)
USE mavenfuzzyfactory;

SELECT
	primary_product_id,
	COUNT(order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin,
    AVG(price_usd) AS aov
FROM
	orders
WHERE
	order_id BETWEEN 10000 AND 11000
GROUP BY
	1
ORDER BY
	2
;