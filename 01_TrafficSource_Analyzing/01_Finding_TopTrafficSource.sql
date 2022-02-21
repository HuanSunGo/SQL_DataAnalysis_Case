USE mavenfuzzyfactory;

SELECT
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions 
FROM website_sessions 
WHERE created_at < '2012-04-12'
GROUP BY utm_source,utm_campaign,http_referer
ORDER BY sessions DESC 

-- the top return is "utm_source:gsearch, utm_campaign:nonbrand", will focus and dig into it. 
