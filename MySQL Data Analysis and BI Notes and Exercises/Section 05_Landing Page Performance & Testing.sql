-- Landing Page Performance & Testing

-- Objective: Analyze landing page performance and compare multiple pages

-- Step 1: Find the first website_pageview_id for relevant sessions
-- Step 2: Identify the landing page of each session
-- Step 3: Count pageviews for each session to identify "bounces"
-- Step 4: Summarize total sessions and bounced sessions by landing page

-- Find the minimum website_pageview_id for each session in question

SELECT wp.website_session_id, MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wp JOIN website_sessions AS ws ON wp.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY wp.website_session_id;

-- Create a temp table with the above query

CREATE TEMPORARY TABLE first_pageviews
SELECT wp.website_session_id, MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wp JOIN website_sessions AS ws ON wp.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY wp.website_session_id;

SELECT *
FROM first_pageviews;

-- Join sessions with corresponding landing page and save as a temp table

CREATE TEMPORARY TABLE sessions_with_landing_page
SELECT fp.website_session_id, wp.pageview_url AS landing_page
FROM website_pageviews AS wp JOIN first_pageviews AS fp ON website_pageview_id = min_pageview_id
;

-- DROP TABLE sessions_with_landing_page;

SELECT * FROM sessions_with_landing_page;

-- Create a temp table to identify "bounces"

CREATE TEMPORARY TABLE bounces
SELECT website_session_id, COUNT(pageview_url) AS count_session_pageviews
FROM website_pageviews
GROUP BY website_session_id
HAVING COUNT(pageview_url) = 1
ORDER BY website_session_id;

-- Join sessions_with_landing_page with bounces and create a temp table

CREATE TEMPORARY TABLE sessions_with_bounces
SELECT s.website_session_id, b.website_session_id AS bounced_session_id, landing_page
FROM sessions_with_landing_page AS s LEFT JOIN bounces AS b ON s.website_session_id = b.website_session_id
;

SELECT * FROM sessions_with_bounces;

-- Return count of total sessions and bounced sessions for each landing page

SELECT landing_page, COUNT(website_session_id) AS sessions, COUNT(bounced_session_id) AS bounced_sessions, COUNT(bounced_session_id)/COUNT(website_session_id) AS bounce_rate
FROM sessions_with_bounces
GROUP BY landing_page
ORDER BY landing_page;





