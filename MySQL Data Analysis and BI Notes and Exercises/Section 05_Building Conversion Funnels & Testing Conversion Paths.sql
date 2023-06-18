-- Building Conversion Funnels & Testing Conversion Paths

-- Objective: Understand and optimize each step of your user's experience on their journey toward purchasing products

-- Conversion funnel: Examines users, where they land, and percentage of users who move on to next steps

/* Common Use Cases
1) Identifying common paths before purchasing products
2) Identidying how many of users continue on to next steps in conversion flow and number of users who abandon at each step
3) Optimizing critical pain points where users abandon in an effot to get users to make a purchase
*/
 
 -- Using subqueries: freestanding query and required alias
 
 /* Conversion Funnels
 - Create temporary tables using pageview data to build multi-step funnels
 - First identify relevant sessions, then bring in relevant pagevies, and then flag session as having made it to certain funnel step
 - Perform summary analysis
 */
 
 /* Business Context
 - Build a mini conversion funnel from /lander-2 to /cart
 - Determine how many people reach each step and dropoff rates
 - For this, focus on only /lander-2 traffic and customers who like Mr. Fuzzy
 
 Steps:
 1) Select all pageviews for relevant sessions
 2) Identify each relevant pageview as the specific funnel step
 3) Create the session-level conversion funnel view
 4) Aggregate data to assess funnel performance
 */
 
 -- Step 1
 
SELECT
	ws.website_session_id,
    wp.pageview_url,
    wp.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM
	website_sessions AS ws JOIN
    website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
WHERE
	ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
    AND wp.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	ws.website_session_id,
    wp.created_at
;

CREATE TEMPORARY TABLE session_level_made_it_flags_demo
SELECT
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM (
		SELECT
			ws.website_session_id,
			wp.pageview_url,
			wp.created_at AS pageview_created_at,
			CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
			CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
			CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
		FROM
			website_sessions AS ws LEFT JOIN
			website_pageviews AS wp ON ws.website_session_id = wp.website_session_id
		WHERE
			ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
			AND wp.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
		ORDER BY
			ws.website_session_id,
			wp.created_at
	) AS page_view_level
GROUP BY
	website_session_id
;

SELECT
	COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
    COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart
FROM
	session_level_made_it_flags_demo;

-- Then translate previous counts to click rates for final output

SELECT
	COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
		/COUNT(website_session_id) AS lander_clickthrough_rate,
    COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)
		/COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS product_clickthrough_rate,
    COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) 
		/COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mr_fuzzy_clickthrough_rate
FROM
	session_level_made_it_flags_demo;



    



