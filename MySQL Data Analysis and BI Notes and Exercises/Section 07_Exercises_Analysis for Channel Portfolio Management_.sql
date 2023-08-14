-- Section 7 Exercises: Analysis for Channel Portfolio Management

-- 1) Analyzing Channel Portfolios
-- Pull weekly trended session volume for nonbrand bsearch and gsearch (utm_source) beginning 8/22/12 through 11/28/12

USE mavenfuzzyfactory;

SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM
	website_sessions
WHERE
	created_at > '2012-08-22'
    AND created_at < '2012-11-29'
    AND utm_campaign = 'nonbrand'
GROUP BY
	WEEK(created_at);

-- 2) Comparing Channel Characteristics
-- Analyze bsearch nonbrand traffic and determine percentage of traffic coming from mobile devices.
-- Compare to gsearch.
-- Dates: 8/22/12 through 11/20/12

SELECT
	utm_source,
	COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN device_type = 'mobile' THEN device_type ELSE NULL END) AS mobile_sessions,
	COUNT(CASE WHEN device_type = 'mobile' THEN device_type ELSE NULL END) / COUNT(website_session_id) AS pct_mobile
FROM
	website_sessions
WHERE
	utm_source LIKE '%search'
    AND utm_campaign = 'nonbrand'
    AND created_at BETWEEN '2012-08-22' and '2012-11-30'
GROUP BY
	utm_source;
    
-- 3) Cross-Channel Bid Optimization
-- Determine sessions, orders, and conversion rates for bsearch and gsearch (nonbrand) by device from 8/22/12 to 9/18/12.

SELECT
	device_type,
    utm_source,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(ws.website_session_id) AS conv_rate
FROM
	website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	utm_source LIKE '%search'
    AND utm_campaign = 'nonbrand'
    AND ws.created_at BETWEEN '2012-08-22' AND '2012-09-18'
GROUP BY
	1,
    2
ORDER BY
	1
;

-- 4) Analyzing Channel Portfolio Trends
-- Pull weekly session volume for gsearch and bsearch (nonbrand) by device since 11/4/12 and through 12/21/12.
-- Include a comparison metric to show bsearch as a percentage of gsearch by device.

SELECT
	MIN(DATE(created_at)),
    SUM(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN 1 ELSE 0 END) AS g_dsktp_sessions,
    SUM(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN 1 ELSE 0 END) AS b_dsktp_sessions,
    SUM(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN 1 ELSE 0 END) / SUM(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN 1 ELSE 0 END) AS b_pct_g_dsktp_sessions,
    SUM(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN 1 ELSE 0 END) AS g_mob_sessions,
    SUM(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN 1 ELSE 0 END) AS b_mob_sessions,
    SUM(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN 1 ELSE 0 END) / SUM(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN 1 ELSE 0 END) AS b_pct_g_mob_sessions
FROM
	website_sessions
WHERE
	utm_source LIKE '%search'
    AND utm_campaign = 'nonbrand'
    AND created_at BETWEEN '2012-11-04' AND '2012-12-22'
GROUP BY
	WEEK(created_at)
;

-- 5) Analyzing Direct Traffic
-- Pull organic search, direct type-in, and paid brand search sessions by month thru 12/22/12, showing as percentage of paid search nonbrand

SELECT 
	YEAR(created_at) AS year,
	MONTHNAME(created_at) AS month,
    SUM(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE 0 END) AS nonbrand,
	SUM(CASE WHEN  utm_campaign = 'brand' THEN 1 ELSE 0 END) AS brand_search,
    SUM(CASE WHEN  utm_campaign = 'brand' THEN 1 ELSE 0 END) / SUM(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE 0 END) AS brand_pct_nonbrand,
    SUM(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN 1 ELSE 0 END) AS direct,
    SUM(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN 1 ELSE 0 END) / SUM(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE 0 END) AS direct_pct_nonbrand,
    SUM(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 1 ELSE 0 END) AS org_search,
    SUM(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 1 ELSE 0 END) / SUM(CASE WHEN utm_campaign = 'nonbrand' THEN 1 ELSE 0 END) AS org_pct_nonbrand
FROM website_sessions
WHERE
	created_at < '2012-12-23'
GROUP BY
	year,
	month,
	MONTH(created_at)
ORDER BY
	MONTH(created_at)
;















