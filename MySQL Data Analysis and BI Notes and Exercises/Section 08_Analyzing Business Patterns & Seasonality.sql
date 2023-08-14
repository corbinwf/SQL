-- Analyzing Business Patterns & Seasonality

-- Objective is to generate insights to help maximize efficiency and anticipate future trends
-- Common use cases: day-parting analysis and analyzing seasonality

SELECT 
	website_session_id,
    created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS wkday_num, -- 0 = Monday, 1 = Tuesday, ...
    CASE
		WHEN WEEKDAY(created_at) = 0 THEN "Monday"
        WHEN WEEKDAY(created_at) = 1 THEN "Tuesday"
        WHEN WEEKDAY(created_at) = 2 THEN "Wednesday"
        WHEN WEEKDAY(created_at) = 3 THEN "Thursday"
        WHEN WEEKDAY(created_at) = 4 THEN "Friday"
        WHEN WEEKDAY(created_at) = 5 THEN "Saturday"
        WHEN WEEKDAY(created_at) = 6 THEN "Sunday"
        ELSE "-"
	END AS wkday_text,
    QUARTER(created_at) AS qtr,
    MONTH(created_at) AS mo,
    DATE(created_at) AS date,
    WEEK(created_at) AS wk
FROM
	website_sessions
WHERE
	website_session_id BETWEEN 150000 AND 155000;