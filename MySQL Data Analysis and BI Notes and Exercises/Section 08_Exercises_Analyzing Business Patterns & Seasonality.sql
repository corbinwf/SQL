-- Exercises

-- 1) Find 2012's monthly and weekly volume patterns for sessions and orders

SELECT
	YEAR(ws.created_at) AS yr,
    MONTHNAME(ws.created_at) AS mo,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(order_id) AS orders
FROM
	website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	YEAR(ws.created_at) = 2012
GROUP BY
	1,
    2,
    MONTH(ws.created_at)
ORDER BY
	MONTH(ws.created_at)
;

SELECT
    MIN(DATE(ws.created_at)) AS week_start_date,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(order_id) AS orders
FROM
	website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	YEAR(ws.created_at) = 2012
GROUP BY
	WEEK(ws.created_at);
    
-- 2) Using the date range of 9/15/12 through 11/15/12, analyze the average website session volume by hour of day and day of week

CREATE TEMPORARY TABLE day_hr_sessions
SELECT
	DATE(created_at) AS created_date,
	WEEKDAY(created_at) AS day_of_wk,
    HOUR(created_at) AS hr,
    COUNT(website_session_id) AS sessions
FROM 
	website_sessions
WHERE
	created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY
	1,
    2,
    3
;

SELECT
	hr,
    ROUND(AVG(CASE WHEN day_of_wk = 0 THEN sessions ELSE NULL END), 1) AS mon,
    ROUND(AVG(CASE WHEN day_of_wk = 1 THEN sessions ELSE NULL END), 1) AS tue,
    ROUND(AVG(CASE WHEN day_of_wk = 2 THEN sessions ELSE NULL END), 1) AS wed,
    ROUND(AVG(CASE WHEN day_of_wk = 3 THEN sessions ELSE NULL END), 1) AS thu,
    ROUND(AVG(CASE WHEN day_of_wk = 4 THEN sessions ELSE NULL END), 1) AS fri,
    ROUND(AVG(CASE WHEN day_of_wk = 5 THEN sessions ELSE NULL END), 1) AS sat,
    ROUND(AVG(CASE WHEN day_of_wk = 6 THEN sessions ELSE NULL END), 1) AS sun
FROM 
	day_hr_sessions
GROUP BY
	1
ORDER BY
	hr
;



