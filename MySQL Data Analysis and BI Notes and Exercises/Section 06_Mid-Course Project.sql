-- Mid-Course Project

/*
- Tell the story of company's growth using trended performance data
- Use data to explain details around the growth story and quatify the revenue impact of some of the company's wins
- Analyze current performance and use the available data to assess upcoming opportunities
*/

-- 1) Pull monthly trends for Gsearch sessions and orders
-- Look at total Gsearch sessions and number of orders stemming from those sessions

SELECT
	YEAR(DATE(ws.created_at)) AS year,
    DATE_FORMAT(ws.created_at, '%M') AS month,
	COUNT(ws.website_session_id) AS gsearch_sessions,
    COUNT(order_id) AS gsearch_orders
FROM
	website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	utm_source = 'gsearch'
    AND ws.created_at < '2012-11-27'
GROUP BY
	year,
    month,
    MONTH(DATE(ws.created_at))
ORDER BY
	YEAR(DATE(ws.created_at)),
    MONTH(DATE(ws.created_at));
    
-- 2) Pull monthly trends for search broken out by nonbrand and brand campaigns

CREATE TEMPORARY TABLE gsearch_campaign_session_w_order
SELECT
	ws.created_at,
	ws.website_session_id,
	CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE NUll END AS nonbrand_session,
    CASE WHEN utm_campaign = 'brand' THEN 1 ELSE NULL END AS brand_session,
    CASE WHEN utm_campaign = 'nonbrand' THEN order_id ELSE NULL END AS nonbrand_order,
    CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END AS brand_order
FROM
	website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	utm_source = 'gsearch'
    AND ws.created_at < '2012-11-27';

SELECT
	YEAR(DATE(created_at)) AS year,
    DATE_FORMAT(created_at, '%M') AS month,
    COUNT(website_session_id) AS sessions,
    COUNT(nonbrand_session) AS nonbrand_sessions,
	COUNT(nonbrand_order) AS nonbrand_orders,
    COUNT(brand_session) AS brand_sessions,
    COUNT(brand_order) AS brand_orders
FROM
	gsearch_campaign_session_w_order
GROUP BY
	year,
    month,
	MONTH(DATE(created_at))
ORDER BY
	YEAR(DATE(created_at)),
    MONTH(DATE(created_at));
    
-- 3) Pull monthly Gsearch, nonbrand sessions and orders by device

SELECT
	YEAR(DATE(ws.created_at)) AS year,
    DATE_FORMAT(ws.created_at, '%M') AS month,
	COUNT(ws.website_session_id) AS sessions,
    COUNT(CASE WHEN device_type = 'desktop' THEN 1 ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN device_type = 'desktop' THEN order_id ELSE NULL END) AS desktop_order,
    COUNT(CASE WHEN device_type = 'mobile' THEN 1 ELSE NULL END) AS mobile_sessions,
    COUNT(CASE WHEN device_type = 'mobile' THEN order_id ELSE NULL END) AS mobile_order
FROM
	website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND ws.created_at < '2012-11-27'
GROUP BY
	year,
    month,
	MONTH(DATE(ws.created_at))
ORDER BY
	YEAR(DATE(ws.created_at)),
    MONTH(DATE(ws.created_at));

-- 4) Pull monthly percentage trends for Gsearch and other channels to compare them prior to 11/27/2012
-- Consider direct sessions, i.e., look at the http_referer; understand overall traffic

SELECT
	DISTINCT utm_source,
    utm_campaign,
    http_referer
FROM
	website_sessions
WHERE
	created_at < '2012-11-27';
/*
1) gsearch/nonbrand/gsearch
2) gsearch/brand/gsearch
3) bsearch/nonbrand/bsearch
4) bsearch/brand/bsearch
5) NULL/NULL/NULL => direct-type-in traffic
6) NULL/NULL/gsearch => organic search
7) NULL/NULL/bsearch => organic search

*/

-- Determine utm_source for period

SELECT
	YEAR(DATE(created_at)) AS year,
    DATE_FORMAT(created_at, '%M') AS month,
	COUNT(website_session_id) AS total_sessions,
    COUNT(CASE WHEN utm_source = 'gsearch' THEN 1 ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(CASE WHEN utm_source = 'bsearch' THEN 1 ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(CASE WHEN ISNULL(utm_source) AND http_referer IS NOT NULL THEN 1 ELSE NULL END) AS organic_search_sessions,
    COUNT(CASE WHEN ISNULL(http_referer) THEN 1 ELSE NULL END) AS direct_type_in_sessions
FROM 
	website_sessions
WHERE
	created_at < '2012-11-27'
GROUP BY
	year,
    month,
	MONTH(DATE(created_at))
ORDER BY
	1,
    MONTH(DATE(created_at));

-- 5) Pull monthly session-to-order conversion rates for first eight months
/*
Left join sessions and orders, where dates align, return total sessions, orders, and cr by month
*/

SELECT
	YEAR(DATE(ws.created_at)) AS year,
    DATE_FORMAT(ws.created_at, '%M') AS month,
	COUNT(ws.website_session_id) AS sessions,
	COUNT(order_id) AS orders,
    COUNT(order_id)/COUNT(ws.website_session_id) AS conversion_rate
FROM
	website_sessions AS ws
	LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	ws.created_at < '2012-11-27'
GROUP BY
	year,
    month,
	MONTH(DATE(ws.created_at))
ORDER BY
	year,
    MONTH(DATE(ws.created_at));


-- 6) For the gsearch lander-1 test, estimate the revenue that test earned
--    Look at the increase in CVR from the test 6/19/2012 thru 7/28/2012 (test end date) 
--    and use the nonbrand sessions and revenue since to calculate incremental value

-- Identify first /lander-1 pageview

SELECT
	MIN(website_pageview_id)
FROM
	website_pageviews
WHERE
	pageview_url = '/lander-1';
    
-- => 23504

-- Find first pageview within test period for gsearch/nonbrand

CREATE TEMPORARY TABLE first_test_pvs
SELECT
	wp.website_session_id,
    MIN(website_pageview_id) AS first_pv
FROM
	website_sessions AS ws
    JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
WHERE
	website_pageview_id >= 23504
    AND ws.created_at < '2012-07-28'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	wp.website_session_id;
	
-- Identify pageview_url for previous landing pages' ultimately narrowing down to /home and /lander-1

CREATE TEMPORARY TABLE nb_test_session_landing
SELECT
	wp.website_session_id,
    pageview_url
FROM 
	first_test_pvs AS ftp
    JOIN website_pageviews AS wp ON first_pv = website_pageview_id
WHERE
	pageview_url IN ('/home', '/lander-1');

-- Pull in orders and calculate orders by landing page and conversion rate

SELECT
	pageview_url AS landing_page,
    COUNT(ntsl.website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id)/COUNT(ntsl.website_session_id) AS conversion_rate
FROM
	nb_test_session_landing AS ntsl
    LEFT JOIN orders AS o ON ntsl.website_session_id = o.website_session_id
GROUP BY
	landing_page;

-- => 0.0088 increase in conversion rate during test
-- Using nonbrand sessions and revenue, calculate the incremental value since the end of the test (7/28/12) thru 11/26/12
-- Identify the most recent pageview_id for /home

SELECT
	MAX(ws.website_session_id) AS most_recent_gsearch_nonbrand_home_pv
FROM
	website_sessions AS ws
    JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
WHERE
	utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND ws.created_at < '2012-11-27';

-- most recent website session id with regards to 11/28/2012 date => 17145, i.e., last /home session
-- Now determine how many sessions since the test


SELECT
	COUNT(website_session_id) AS sessions_since_test
FROM
	website_sessions
WHERE
	created_at < '2012-11-27'
    AND website_session_id > 17145
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';

-- => 22,972 sessions since test
-- Provided the .0088 increase in conversion rate with the /lander-1 page, there were about 200 more orders in the period
-- since the end of the test and through 11/26/2012, i.e., that is about 50 additional orders each month on average

-- 7) Show a full conversion funnely from each of the landing pages from 6/19/12 thru 7/28/12
-- gsearch/nonbrand

-- 1. Temporary table of website sessions and pages landed on in each sessions
CREATE TEMPORARY TABLE website_sessions_w_pages
  SELECT
    ws.website_session_id,
    CASE
      WHEN pageview_url = '/home' THEN 1
      ELSE 0
    END AS homepage,
    CASE
      WHEN pageview_url = '/lander-1' THEN 1
      ELSE 0
    END AS custom_lander,
    CASE
      WHEN pageview_url = '/products' THEN 1
      ELSE 0
    END AS product_page,
    CASE
      WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1
      ELSE 0
    END AS mrfuzzy_page,
    CASE
      WHEN pageview_url = '/cart' THEN 1
      ELSE 0
    END AS cart_page,
    CASE
      WHEN pageview_url = '/shipping' THEN 1
      ELSE 0
    END AS shipping_page,
    CASE
      WHEN pageview_url = '/billing' THEN 1
      ELSE 0
    END AS billing_page,
    CASE
      WHEN pageview_url = '/thank-you-for-your-order' THEN 1
      ELSE 0
    END AS thank_you_page
  FROM
    website_sessions AS ws
    JOIN website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
  WHERE
    utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND ws.created_at BETWEEN '2012-06-19'
    AND '2012-07-28'
  ORDER BY
    ws.website_session_id;

-- 2. Temporary table of agg website sessions and whether pages were landed on

CREATE TEMPORARY TABLE sessions_w_views
SELECT
	website_session_id,
	MAX(homepage) AS homepage_landing,
	MAX(custom_lander) AS custom_landing,
    MAX(product_page) AS product_landing,
    MAX(mrfuzzy_page)AS mrfuzzy_landing,
    MAX(cart_page) AS cart_landing,
    MAX(shipping_page) AS shipping_landing,
    MAX(billing_page) AS billing_landing,
    MAX(thank_you_page) AS ty_landing
FROM
	website_sessions_w_pages
GROUP BY
	website_session_id;

-- 3. Count page landings by segment

SELECT
	CASE
		WHEN homepage_landing = 1 THEN 'homepage_landing'
        WHEN custom_landing = 1 THEN 'custom_landing'
        ELSE 'neither'
	END AS segment,
    COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_landing = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(CASE WHEN mrfuzzy_landing = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(CASE WHEN cart_landing = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(CASE WHEN shipping_landing = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(CASE WHEN billing_landing = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(CASE WHEN ty_landing = 1 THEN website_session_id ELSE NULL END) AS to_thank_you
FROM
	sessions_w_views
GROUP BY
	segment;

SELECT
	CASE
		WHEN homepage_landing = 1 THEN 'homepage_landing'
        WHEN custom_landing = 1 THEN 'custom_landing'
        ELSE 'neither'
	END AS segment,
    COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(website_session_id) AS landing_clickthrough_rate,
    COUNT(CASE WHEN mrfuzzy_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN product_landing = 1 THEN website_session_id ELSE NULL END) AS product_clickthrough_rate,
	COUNT(CASE WHEN cart_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN mrfuzzy_landing = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_clickthrough_rate,
    COUNT(CASE WHEN shipping_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN cart_landing = 1 THEN website_session_id ELSE NULL END) AS cart_clickthrough_rate,
    COUNT(CASE WHEN billing_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN shipping_landing = 1 THEN website_session_id ELSE NULL END) AS shipping_clickthrough_rate,
    COUNT(CASE WHEN ty_landing = 1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN billing_landing = 1 THEN website_session_id ELSE NULL END) AS billing_clickthrough_rate
FROM
	sessions_w_views
GROUP BY
	segment;

-- 8) Quantify the impact of billing test from 9/10/12 thru 11/10/12 in terms of revenue per billing page session;
-- then pull the number of billing-page sessions for the past month to understand monthly impact
-- /billing and /billing-2

SELECT DISTINCT pageview_url
FROM website_pageviews
WHERE pageview_url LIKE '/bil%';

-- 1. Create temporary table of relevant sessions

CREATE TEMPORARY TABLE test_pageview
SELECT
	website_session_id,
    pageview_url
FROM
	website_pageviews
WHERE
	created_at > '2012-09-10'
    AND created_at < '2012-11-10'
    AND pageview_url IN ('/billing', '/billing-2');

-- 2. Join relevant sessions with orders calculate revenue for /billing and /billing-2

SELECT
	pageview_url AS billing,
    COUNT(tp.website_session_id) AS sessions,
    SUM(price_usd)/COUNT(tp.website_session_id) AS revenue_per_billing_session
FROM
	test_pageview AS tp
    LEFT JOIN orders AS o ON tp.website_session_id = o.website_session_id
GROUP BY
	billing;

-- 3. Revenue per billing session
-- /billing-2 = $31.34 vs. /billing = $22.83 => diff = +$8.51 per billing page view

-- 4. Pull billing sessions from last month to see what the impact is

SELECT
	COUNT(website_session_id) AS billing_sessions_past_mo
FROM
	website_pageviews
WHERE
	created_at BETWEEN '2012-10-27' AND '2012-11-27'
    AND pageview_url LIKE '/bill%';

-- Impact:
-- 1,193 relevant sessions
-- Increase in revenue with billing test: +$10,152 in past month