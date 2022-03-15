USE mavenfuzzyfactory;

-- Task1: Cross channel bid optimization. 
SELECT
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)  AS conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id=website_sessions.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-19'
    AND website_sessions.utm_campaign = 'nonbrand' -- limiting to nonbrand paid search
GROUP BY 1,2;

-- Result: within both desktop and mobile, gsearch outperformed bsearch on conversion rate
-- Action: bid down on the bsearch based on the analysis 

-- Task2: Channel portfolio trends. 
SELECT 
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
	COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
	COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
    COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob
FROM website_sessions
WHERE
	website_sessions.created_at BETWEEN '2012-11-04' AND '2012-12-22'
    AND website_sessions.utm_campaign = 'nonbrand' -- limiting to nonbrand paid search
GROUP BY YEARWEEK(created_at)

-- Result: `bsearch` is less price elastic on mobile, because the percentage of b to g have been stable on mobile after the bid down of company. 
