USE mavenfuzzyfactory;

SELECT
	w.device_type,
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS conv_rt
FROM website_sessions w 
	LEFT JOIN orders o
		ON o.website_session_id = w.website_session_id
WHERE w.created_at<'2012-05-11'
	AND w.utm_source='gsearch'
    AND w.utm_campaign='nonbrand'
GROUP BY 1

-- The outcome shows that mobile end conversion rate isn't as good as the desktop end,
-- Shoudn't be running the same bid for the two traffic.