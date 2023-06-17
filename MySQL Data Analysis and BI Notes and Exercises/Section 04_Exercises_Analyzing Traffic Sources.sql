-- Section 4 Exercises: Analyzing Traffic Sources

/* Provide analysis of where bulk of website sessions are coming from through 4/12/12
broken down by UTM source, campaign, and referring domain */

SELECT
	utm_source,
	utm_campaign,
    http_referer,
	COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC
;

/* Calculate the conversion rate (CVR) from session to order for sessions prior to 4/14/12
*/

SELECT 
	COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_rt
FROM 
	website_sessions AS w
		LEFT JOIN orders AS o 
			ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-04-14'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
;
	
/* Pull gsearch nonbrand trended session volume by week prior to 5/10/12
*/

SELECT
	-- YEAR(created_at) AS yr,
    -- WEEK(created_at) AS wk,
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(website_session_id) AS sessions
FROM
	website_sessions
WHERE 
	created_at < '2012-05-10'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
    WEEK(created_at)
;

/* Determine the conversion rates from session to order by device type
*/

SELECT
	device_type,
    COUNT(w.website_session_id) AS sessions,
    COUNT(order_id) as orders,
    COUNT(order_id)/COUNT(w.website_session_id) AS session_to_order_conv_rate
FROM
	website_sessions AS w
    LEFT JOIN orders AS o
    ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY device_type
;

/* Pull weekly trends for desktop and mobile sessions for gsearch nonbrand between 4/15/12 and 6/9/12
*/

SELECT
    MIN(DATE(created_at)) AS week_start_date,
    SUM(CASE WHEN device_type = 'desktop' THEN 1 ELSE NULL END) AS dtop_sessions,
    SUM(CASE WHEN device_type = 'mobile' THEN 1 ELSE NULL END) AS mob_sessions
FROM 
	website_sessions
WHERE
	created_at BETWEEN '2012-04-15' AND '2012-06-09'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at)
;

