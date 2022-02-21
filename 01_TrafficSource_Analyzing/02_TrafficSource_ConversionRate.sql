USE mavenfuzzyfactory; 

SELECT COUNT(DISTINCT w.website_session_id) AS sessions,
		COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_rate
FROM website_sessions w 
	LEFT JOIN orders o 
		ON w.website_session_id=o.website_session_id
WHERE w.created_at < '2012-04-14' 
	AND w.utm_source='gsearch' 
    AND w.utm_campaign='nonbrand'
    
-- since the conversion rate is below 4% threshold, the marketing team can dial down on the search bids, to avoid over-spending.