USE mavenfuzzyfactory;

SELECT 
	MIN(DATE(w.created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN device_type='desktop' THEN w.website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type='mobile' THEN w.website_session_id ELSE NULL END) AS mob_sessions	
    
FROM website_sessions w

WHERE w.created_at > '2012-04-15'
	AND w.created_at <'2012-06-09'
    AND w.utm_source='gsearch'
    AND w.utm_campaign='nonbrand'
    
GROUP BY 
	YEAR(w.created_at),
    WEEK(w.created_at)
    
-- After biding up on 2012-05-19 for the good performance on the desktop end, the optimized spend did make the desktop looks strong.