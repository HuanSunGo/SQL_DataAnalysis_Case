-- Task: build up a full conversion funnel between the new /lander-1 page and placing an order, to understand where the 'gsearch' visitors lost.
-- Clarify: Start with/lander -1 and build the funnel all the way to our thank you page . Please use data since August 5 5th 2012.

USE mavenfuzzyfactory;
-- STEP 1: select all pageviews for relevant sessions
-- STEP 2: identify each relevant pageview as the specific funnel step

CREATE TEMPORARY TABLE session_level_madeit_flags
WITH pageview_level AS (SELECT 
    website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    -- create each steps as a 0-1 flag for individual pageview, that signals where the customer at 
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY website_sessions.website_session_id , website_pageviews.created_at)

-- STEP 3: create the session level conversion funnel view, check for each session, where did the customer finally made it 
SELECT
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM pageview_level
GROUP BY website_session_id;

-- STEP 4: aggregate the data to assess funnel performance, and translate counts to click rates, each based on the previous steps
SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)  / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM
    session_level_made_it_flags;
    
-- Results 1: the lander_click_rt, mrfuzzy_click_rt, billing)click_rt are around 45%， significantly lower than click rates on other steps.
-- Next Step: start from billing page, the product team will make the customer more comfortable in entering the credit card info, analyze the billing page test the plans to run.

