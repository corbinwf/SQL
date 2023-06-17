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
	

    