-- Background: Now there runs a new 50/50 test against homepage(/home) for "gsearch,nonbrand" traffic.
-- Task: Pull bounce rate for two groups for evaluation, where /home is the original one, and the /lander-1 is the new testing one.

USE mavenfuzzyfactory;

SELECT
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url='/lander-1'
	AND created_at IS NOT NULL;

-- for the new test, first created at '2012-06-19', and the first_pageview_id = 23504

WITH bounced_sessions  -- Create the CTE for counting the bounced sessions. 
AS(SELECT 
	 website_session_id,
     COUNT(website_pageview_id) AS pageviews,
     pageview_url
	FROM website_pageviews
    WHERE created_at BETWEEN '2012-06-19' AND '2012-07-28' -- use the test time limit 
    AND website_pageview_id > 23504
    GROUP BY 1
		HAVING pageviews = 1)

SELECT
	website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS total_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced,
    COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT website_pageviews.website_session_id) AS bounce_rate
FROM website_pageviews
LEFT JOIN bounced_sessions
	ON bounced_sessions.website_session_id = website_pageviews.website_session_id
    INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28'
	AND website_pageview_id > 23504
    AND website_pageviews.pageview_url IN ('/home', '/lander-1')
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 1
ORDER BY 3 DESC;
