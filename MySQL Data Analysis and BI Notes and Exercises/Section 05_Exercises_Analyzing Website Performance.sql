-- Section 5 Exercises: Analyzing Website Performance

USE mavenfuzzyfactory;

-- Pull the most-viewed websites ranked by session volume prior to 6/9/12

SELECT pageview_url, COUNT(website_pageview_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY COUNT(website_pageview_id) DESC;

-- List top entry pages ranked by entry volume prior to 6/12/12

CREATE TEMPORARY TABLE first_pageviews
SELECT website_session_id, MIN(website_pageview_id) AS first_pv
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT pageview_url AS landing_page, COUNT(first_pv) AS sessions_hitting_this_landing_page
FROM first_pageviews LEFT JOIN website_pageviews ON first_pv = website_pageview_id
GROUP BY landing_page
ORDER BY COUNT(first_pv) DESC;

-- DROP TABLE first_pageviews;

-- Pull bounce rates for traffic landing on the homepage; include sessions, bounced sessions, and bounce rate

-- Create temp table of landing pages

CREATE TEMPORARY TABLE landing_pages
SELECT website_session_id, MIN(website_pageview_id) AS landing_page
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

-- Create temp table of those sessions where the landing page was the homepage

CREATE TEMPORARY TABLE homepage_landings
-- SELECT landing_pages.website_session_id, landing_page, pageview_url
SELECT landing_pages.website_session_id, pageview_url
FROM landing_pages JOIN website_pageviews ON landing_page = website_pageview_id -- no 
WHERE pageview_url = '/home';

SELECT * FROM homepage_landings;

-- Create temp table of bounced sessions, i.e., where sessions started on the homepage but only stayed on the homepage in the session

CREATE TEMPORARY TABLE bounced_sessions
SELECT website_session_id as bounce_session_id, COUNT(website_pageview_id)
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id
HAVING COUNT(website_pageview_id) = 1;

SELECT * FROM homepage_landings;
SELECT * FROM bounced_sessions;
DROP TABLE homepage_landings;

-- Return total count of sessions where landing page was homepage, the number of bounced sessions for homepage-landing sessions, and the bounce rate

SELECT COUNT(DISTINCT website_session_id) AS sessions, COUNT(bounce_session_id) AS bounced_sessions, COUNT(bounce_session_id)/COUNT(DISTINCT website_session_id) AS bounce_rate
FROM homepage_landings LEFT JOIN bounced_sessions ON website_session_id = bounce_session_id;

SELECT *
FROM website_sessions AS ws JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
WHERE ws.website_session_id = 6;

-- Pull bounce rates for custom landing page (/lander-1) and homepage (/home) for gsearch nonbrand traffic; taking into account the time period when /lander-1 was getting traffic

-- 1) Find beginning /lander-1 analysis timeframe

SELECT website_pageview_id, MIN(created_at)
FROM website_pageviews
WHERE pageview_url = '/lander-1'
GROUP BY website_pageview_id
LIMIT 1;

-- Date range between '2012-06-19 00:35:54' and '2012-07-28'
-- website_pageview_id = 23504

-- 2) Determine total sessions, bounced sessions, and bounce rate for pages in question

CREATE TEMPORARY TABLE first_pageviews
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
GROUP BY website_session_id;

CREATE TEMPORARY TABLE gsearch_nonbrand_sessions
SELECT
	website_session_id
FROM
	website_sessions
WHERE
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand' AND
    created_at < '2012-07-28';

CREATE TEMPORARY TABLE first_pageview_w_url
SELECT
	f.website_session_id,
    pageview_url
FROM
	first_pageviews AS f JOIN
    website_pageviews AS w ON
    first_pv_id = website_pageview_id
WHERE
	pageview_url IN ('/home','/lander-1') AND
    f.website_session_id IN (SELECT * FROM gsearch_nonbrand_sessions) AND
    website_pageview_id > 23504;

CREATE TEMPORARY TABLE bounces
SELECT
	website_session_id,
    COUNT(website_pageview_id) AS bounced_sessions
FROM website_pageviews
WHERE website_session_id IN (SELECT * FROM gsearch_nonbrand_sessions)
GROUP BY website_session_id
HAVING COUNT(website_pageview_id) = 1;

-- Return total sessions, bounced sessions, and bounce rate for /home and /lander-1 landing pages
SELECT
	pageview_url AS landing_page,
    COUNT(f.website_session_id) AS total_sessions,
    COUNT(bounced_sessions) AS bounced_sessions,
    COUNT(bounced_sessions)/COUNT(f.website_session_id) AS bounce_rate
FROM
	first_pageview_w_url AS f
    JOIN gsearch_nonbrand_sessions AS g ON f.website_session_id = g.website_session_id
    LEFT JOIN
    bounces AS b ON f.website_session_id = b.website_session_id
GROUP BY pageview_url;

-- Pull volume of paid search nonbrand traffic landing on /home and /lander-1, trended weekly since 6/1/2012 and through 8/30/2012
-- Pull overall paid search bounce rate trended weekly
-- week_start_date, bounce_rate, home_sessions, lander_sessions

SELECT DISTINCT utm_source FROM website_sessions WHERE utm_campaign = 'nonbrand';

-- 1) Return first landings and with pageview_url

CREATE TEMPORARY TABLE first_landing
SELECT
	website_session_id,
    MIN(website_pageview_id) AS landing_pv_id
FROM
	website_pageviews
GROUP BY
	website_session_id;

-- gsearch and nonbrand sessions within date range

CREATE TEMPORARY TABLE sessions
SELECT
	website_session_id
FROM
	website_sessions
WHERE
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand' AND
    created_at BETWEEN '2012-06-01' AND '2012-08-30';

-- Pull in landing url

CREATE TEMPORARY TABLE first_landing_w_url
SELECT
	created_at,
	f.website_session_id,
    website_pageview_id,
    pageview_url
FROM
	first_landing AS f JOIN
    website_pageviews AS w ON landing_pv_id = website_pageview_id
WHERE
	pageview_url IN ('/home', '/lander-1'); 
    -- AND created_at BETWEEN '2012-06-01' AND '2012-08-30';

-- 2) Return table of bounced sessions

CREATE TABLE bounced_sessions
SELECT
	website_session_id,
    COUNT(website_pageview_id) AS bounced_sessions
FROM
	website_pageviews
GROUP BY
	website_session_id
HAVING
	COUNT(website_pageview_id) = 1;
 
 DROP TABLE bounced_sessions;

 SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(bounced_sessions)/COUNT(f.website_session_id) AS bounce_rate,
    SUM(CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END) AS home_sessions,
    SUM(CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END) AS lander_sessions
 FROM
	first_landing_w_url AS f LEFT JOIN
    bounced_sessions AS b ON f.website_session_id = b.website_session_id
WHERE
	f.website_session_id IN (SELECT * FROM sessions)
GROUP BY
	YEAR(created_at),
    WEEK(created_at);

-- gsearch visitors conversion funnel with landing on /lander-1 from 8/5/12 through 9/4/12

-- limit sessions by date and gsearch join results with min landing page where url is /lander-1

-- Step 1: Identify gsearch sessions within date range and whether they landed on pages in question
 DROP TABLE session_level_landing_flags;
 
CREATE TEMPORARY TABLE sessions_w_pages
SELECT
	ws.website_session_id,
    pageview_url,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM
	website_sessions AS ws LEFT JOIN
    website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
WHERE
	ws.created_at > '2012-08-05'
    AND ws.created_at < '2012-09-05'
    AND pageview_url IN ('/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
    AND utm_source = 'gsearch'
    AND utm_campaign ='nonbrand'
;

-- Step 2: Count number of sessions and return count landing on each of the pages in question

CREATE TEMPORARY TABLE session_level_landing_flags
SELECT
	website_session_id,
    MAX(products_page) AS product_landing,
    MAX(mrfuzzy_page) AS mrfuzzy_landing,
    MAX(cart_page) AS cart_landing,
    MAX(shipping_page) AS shipping_landing,
    MAX(billing_page) AS billing_landing,
    MAX(thankyou_page) AS thankyou_landing

FROM
	sessions_w_pages
GROUP BY
	website_session_id
;

-- Step 3: Return number of total sessions and sessions landing on each page, and click rates (final output)
SELECT
	COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_landing = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(CASE WHEN mrfuzzy_landing = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(CASE WHEN cart_landing = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(CASE WHEN shipping_landing = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(CASE WHEN billing_landing = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(CASE WHEN thankyou_landing = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM
	session_level_landing_flags
;

SELECT
	COUNT(CASE WHEN product_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(website_session_id) AS lander_click_rt,
    COUNT(CASE WHEN mrfuzzy_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN product_landing = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(CASE WHEN cart_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN mrfuzzy_landing = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(CASE WHEN shipping_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN cart_landing = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(CASE WHEN billing_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN shipping_landing = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(CASE WHEN thankyou_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN billing_landing = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM 
	session_level_landing_flags
;

-- A/B test to see whether /billing-2 is doing any better than /billing
-- Percentage of those sessions landing on these pages that end up placing an order
-- Include all traffic prior to 11/10/2012 and when /billing-2 went live

-- 1) Determine first /billing-2 timestamp

SELECT
	MIN(created_at) AS first_created_at,
    website_pageview_id AS first_pv_id
FROM
	website_pageviews
WHERE
	pageview_url = '/billing-2'
GROUP BY
	website_pageview_id
ORDER BY
	created_at ASC
LIMIT 1
;

-- '2012-09-10 00:13:05' and first_pv_id = 53550

-- 2) Determine relevant sessions within time range using CTE

WITH billing_sessions AS (
  SELECT
    ws.website_session_id,
    pageview_url AS landing_page
  FROM
    website_sessions AS ws
    JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
  WHERE
    ws.created_at > '2012-09-10 00:13:05'
    AND ws.created_at < '2012-11-10'
    AND pageview_url IN ('/billing', '/billing-2')
)

-- Determine relevant pageviews and flag to determine orders using CTE

SELECT
    bs.website_session_id,
    landing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS order_page
FROM
	billing_sessions AS bs
    JOIN website_pageviews AS wp ON bs.website_session_id = wp.website_session_id
WHERE wp.website_session_id IN (SELECT website_session_id FROM billing_sessions);

-- Determine relevant pageviews and flag to determine orders using temp table

CREATE TEMPORARY TABLE billing_sessions_temp
  SELECT
    ws.website_session_id,
    pageview_url AS landing_page
  FROM
    website_sessions AS ws
    JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
  WHERE
    ws.created_at > '2012-09-10 00:13:05'
    AND ws.created_at < '2012-11-10'
    AND pageview_url IN ('/billing', '/billing-2');

-- Additional table to limit pageviews to relevant sessions

CREATE TEMPORARY TABLE billing_sessions_filter
  SELECT
    ws.website_session_id,
    pageview_url AS landing_page
  FROM
    website_sessions AS ws
    JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
  WHERE
    ws.created_at > '2012-09-10 00:13:05'
    AND ws.created_at < '2012-11-10'
    AND pageview_url IN ('/billing', '/billing-2');

-- Determine relevant pageviews and flag to determine orders

CREATE TEMPORARY TABLE billing_sessions_w_order
	SELECT
		bs.website_session_id,
		landing_page,
		CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS order_page
	FROM
		billing_sessions_temp AS bs
		JOIN website_pageviews AS wp ON bs.website_session_id = wp.website_session_id
	WHERE wp.website_session_id IN (SELECT website_session_id FROM billing_sessions_filter);
    
-- The above query does not work if the same temp table is referenced more than once; using billing_sessions_temp and billing_sessions_fitler addresses this

SELECT * FROM billing_sessions_temp;
-- 3) Final output with count of sessions and orders and with percentage

SELECT
	landing_page AS billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(order_page) AS orders,
    COUNT(order_page)/COUNT(DISTINCT website_session_id) AS billing_to_order_rt
FROM
	billing_sessions_w_order
GROUP BY
	landing_page;
  

  