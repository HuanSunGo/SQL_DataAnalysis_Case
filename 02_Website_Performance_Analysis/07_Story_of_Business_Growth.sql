-- General Task: tell the stakeholder the story of company's growth, using trended performance data. Analyze current performance and use the data available to assess upcoming opportunities. 
USE mavenfuzzyfactory;

-- Task 1: tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?
SELECT
	YEAR(website_sessions.created_at) AS year,
    MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate 
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id=website_sessions.website_session_id 
WHERE website_sessions.created_at < '2012-11-27' 
	AND website_sessions.utm_source='gsearch' 
GROUP BY 1,2;

-- Result: Session volumn is growing over time and the order is growing as well.  

-- Task 2: For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
-- Step1: see which is the initial pageview_url that first landed on '/lander-1'
SELECT 
	MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url='/lander-1';  -- it's 23504

-- Step2: use the previous info to adjust the test range
CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id=website_pageviews.website_session_id
        AND website_sessions.created_at < '2012-07-28'
        AND website_pageviews.website_pageview_id >= 23504 
        AND utm_source = 'gsearch'
        AND utm_campaign='nonbrand' 
GROUP BY
	website_pageviews.website_session_id;