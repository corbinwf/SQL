-- Bid Optimization & Trend Analysis

-- Objective: Understand value of various segments of paid traffic to optimize marketing budget

/*
Date Functions:
YEAR(dateOrDatetime)
QUARTER()
MONTH()
WEEK()
DATE()
NOW()
etc.

Use with GROUP BY
*/

SELECT 
    YEAR(created_at),
    WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id)
FROM website_sessions
WHERE website_session_id BETWEEN 100000 and 115000
GROUP BY 1, 2
;

/*
Pivoting Data with COUNT & CASE
*/

SELECT
	primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS count_single_item_orders,
	COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS count_two_item_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 320000
GROUP BY 1
;



