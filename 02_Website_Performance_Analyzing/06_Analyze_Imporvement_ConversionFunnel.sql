-- TASK: test different billing pages on conversion rate. 
-- Clarify: after launched an updated billing page based on the funnel analysis, test whether /billing-2 is doing better than the original /billing page. And run this test on all traffic. 

USE mavenfuzzyfactory;

-- STEP 1: Find the first time /billing-2 was seen.
SELECT 
    pageview_url, MIN(DATE(created_at))
FROM
    website_pageviews
WHERE
    pageview_url = '/billing-2'
GROUP BY 1;

-- Result: /billing-2 was first seen on 2012-09-10

-- STEP 2: Final output. Pull sessions, orders and orders/session for each billing page.
SELECT 
    pageview_url,
    COUNT(DISTINCT website_pageviews.website_session_id) AS sessions,
    COUNT(DISTINCT orders.website_session_id) AS orders,
    COUNT(DISTINCT orders.website_session_id) / COUNT(DISTINCT website_pageviews.website_session_id) AS billing_to_order_rt
FROM
    website_pageviews
        LEFT JOIN
    orders ON website_pageviews.website_session_id = orders.website_session_id
WHERE
    pageview_url IN ('/billing' , '/billing-2')
		-- limit the time interval between that /billing-2 first been seen and the current date 
        AND website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'  
GROUP BY pageview_url

-- Result: /billing-2's billing_to_order_rt is 0.6269, substantially higher than /billing, which is 0.4566