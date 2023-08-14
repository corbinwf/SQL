-- Analyzing Channel Portfolio

-- Analyzing a marketing channel portfolio is about bidding efficiently and leveraging data to maximize effectiveness of the marketing budget
-- Example channels: email, social media, search, and direct type-in
-- Objective: Analyze these different channels to figure out volume of each, how efficient they are, and whether marketing is doing well with their budgets
-- Identify those channels driving the most sessions and orders (volume)
-- Understand user characteristics and conversion across channels
-- Optimize bids and allocate marketing spend across a multi-channel portfolio to achieve maximum performance

-- Traking parameters:
-- paid traffic = tracking (UTM) parameters (utm_source and utm_campaign)
-- sources: bsearch, gsearch, etc. 
-- campaign: brand, nonbrand, etc.

-- Additional available data:
-- user characteristics and behaviors (session-level data): new or repeat visitor, device type, etc.
-- content tags for a particular ad or content (utm_content)

USE mavenfuzzyfactory;

SELECT
	utm_content,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(ws.website_session_id) AS session_to_order_conversion_rate
FROM
	website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
WHERE
	ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
	1
ORDER BY
	sessions DESC;