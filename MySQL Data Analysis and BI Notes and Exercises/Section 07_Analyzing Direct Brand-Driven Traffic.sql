-- Analyzing Direct, Brand-Driven Traffic

-- Keeping up to date with how well the brand is doing with consumers and drives business
-- Use cases:
-- Determining revenue from direct traffic
-- Understanding whether paid traffic is promoting additional direct traffic ("halo" effect)
-- Assessing the impact of various initiatives on how many customers seek out your business

-- Organic search and direct type-in have null utm parameters

SELECT
    CASE
		WHEN http_referer IS NULL THEN 'direct_type_in'
        WHEN http_referer = 'https://www.gsearch.com' AND utm_source IS NULL THEN 'gsearch_organic'
        WHEN http_referer = 'https://www.bsearch.com' AND utm_source IS NULL THEN 'bsearch_organic'
        ELSE 'other'
	END,
    COUNT(website_session_id) AS sessions
FROM
	website_sessions
WHERE
	website_session_id BETWEEN 100000 AND 115000
    -- AND utm_source IS NULL
GROUP BY
	1
ORDER BY
	2 DESC;

-- http_refer is for the website that directed the traffic to the site
-- When this is null, it is considered direct type-in