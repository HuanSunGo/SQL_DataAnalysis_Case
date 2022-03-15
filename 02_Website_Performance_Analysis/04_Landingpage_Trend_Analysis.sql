-- Task: Pull volume of paid search nonbrand traffic landing on /home and /lander-1, trended weekly since June 1st, and bounce rates 

USE mavenfuzzyfactory;

-- STEP 1: Identify bounced and non bounced sessions
DROP TABLE IF EXISTS bounced_sessions;
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
    website_sessions.website_session_id,
    COUNT(DISTINCT website_pageview_id) AS n_pageviews
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 1
HAVING n_pageviews = 1;

-- STEP 2: Merge bounce sessions table with all sessions table
SELECT 
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT bounced_sessions.website_session_id) / COUNT(DISTINCT website_pageviews.website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/home' THEN website_sessions.website_session_id
            ELSE NULL
        END) AS home_sessions,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/lander-1' THEN website_sessions.website_session_id
            ELSE NULL
        END) AS lander_sessions
FROM
    website_sessions
        LEFT JOIN
    bounced_sessions ON website_sessions.website_session_id = bounced_sessions.website_session_id
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND pageview_url IN ('/home' , '/lander-1')
GROUP BY YEARWEEK(website_sessions.created_at)  -- check weekly trend 

-- Results 1: the traffic was primiarlly solly on homepage, and stards to split since 2012-06-17, then was totally transfered to lander page  since 2012-08-15.
-- Results 2: the bounce rates dropped from over 60% to around 50% 