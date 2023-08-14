-- Analyzing Product-Level Website Pathing

-- Objective: Learning how customers interact with each of your products and how well each product converts customers
-- Common use cases:
-- Understanding which products generate the most interest on multi-product showcase pages
-- Analyzing the impact on website conversion rates when you add a new product
-- Building product-specific conversion funnels to understand whether certain products convert better than others

USE mavenfuzzyfactory;

SELECT
	DISTINCT pageview_url
FROM
	website_pageviews
WHERE
	created_at BETWEEN '2013-02-01' AND '2013-03-01'
;

-- Compare sessions going to /the-original-mr-fuzzy and /the-forever-love-bear

SELECT
	pageview_url AS product_page,
    COUNT(wp.website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(wp.website_session_id) AS viewed_product_to_order_rate
FROM
	website_pageviews AS wp
    LEFT JOIN orders AS o ON wp.website_session_id = o.website_session_id
WHERE
	pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
	AND wp.created_at BETWEEN '2013-02-01' AND '2013-03-01'
GROUP BY
	1
;
