-- Analyzing Top Website Pages & Entry Pages

-- Objective: Understand which pages are viewed most and identify where to focus on improving the business

/*
You can create a dataset that is stored as a table and can be queryed

CREATE TEMPORARY TABLE newTempTableName
*/

SELECT
	pageview_url,
    COUNT(website_pageview_id) AS pvs
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY pvs DESC
;

CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id
;

SELECT 
    website_pageviews.pageview_url AS landing_page,
    COUNT(first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY landing_page
;