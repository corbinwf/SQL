-- Section 9 Exercises: Product Analysis

-- 1 Pull monthly trends to date (through 1/4/13) for the number of sales, total revenue, and total margin generated.

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM
	orders
WHERE
	created_at < '2013-01-04'
GROUP BY
	1,
    2
;

-- 2) Determine whether adding a second product was good for the business by analyzing monthly order volume, conversion rates, and revenue per session.
-- Include a breakdown of sales by product. Date range: 4/1/12 thru 4/4/13

SELECT
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(ws.website_session_id) AS conv_rate,
    SUM(price_usd) / COUNT(ws.website_session_id) AS revenue_per_session,
    SUM(CASE WHEN primary_product_id = 1 THEN 1 ELSE 0 END) AS product_one_orders,
    SUM(CASE WHEN primary_product_id = 2 THEN 1 ELSE 0 END) AS product_two_orders
FROM
	website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	ws.created_at BETWEEN '2012-04-01' AND '2013-04-04'
GROUP BY
	1,
    2
;

-- 3) Pull clickthrough rates from /products by product since the new product launch on 1/6/13 (thru 4/5/13) and compare this to the three months leading up to the launch

-- Create a temporary table of /products landing by pre- or post-launch

CREATE TEMPORARY TABLE sessions_by_period
SELECT
	created_at,
    website_session_id,
    IF(created_at < '2013-01-06', 'A. Pre_Product_2', 'B. Pre_Product_2') AS time_period
FROM
	website_pageviews
WHERE
	created_at BETWEEN '2012-10-06' AND '2013-04-05'
    AND pageview_url = '/products'
;

-- Create temporary table of website sessions with with more than one pageview

CREATE TEMPORARY TABLE sessions_w_next_page
SELECT
	website_session_id,
	COUNT(pageview_url) AS w_next_pg
FROM
	website_pageviews
WHERE
	created_at BETWEEN '2012-10-06' AND '2013-04-05'
GROUP BY
	1
HAVING
	COUNT(pageview_url) > 1
;


-- Create a temporary table with sessions whose pageviews are either /the-original-mr-fuzzy or /the-forever-love-bear

CREATE TEMPORARY TABLE product_pageviews
SELECT
	website_session_id,
    pageview_url
FROM
	website_pageviews
WHERE
	created_at BETWEEN '2012-10-06' AND '2013-04-05'
	AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
;

-- Join temporary tables to analyze where customers went after landing on /products

SELECT
    COUNT(session.website_session_id),
    COUNT(next.website_session_id)
FROM
	sessions_by_period AS session
    RIGHT JOIN sessions_w_next_page AS next ON session.website_session_id = next.website_session_id
    LEFT JOIN product_pageviews AS product ON next.website_session_id = product.website_session_id;
GROUP BY
	1;

SELECT
*
FROM
	sessions_by_period AS session
    RIGHT JOIN sessions_w_next_page AS next ON session.website_session_id = next.website_session_id
WHERE next.website_session_id = NULL;

SELECT * FROM website_pageviews WHERE pageview_url LIKE '/prod%';




SELECT
	website_session_id,
    pageview_url,
    COUNT(website_pageview_id)
FROM
	website_pageviews
WHERE
	created_at BETWEEN '2012-10-06' AND '2013-04-05'
GROUP BY
1,2
;


DROP TABLE sessions_by_period;
DROP TABLE sessions_w_next_page;
DROP TABLE product_pageviews;

















