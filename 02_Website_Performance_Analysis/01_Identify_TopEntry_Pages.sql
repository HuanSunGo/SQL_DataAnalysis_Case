USE mavenfuzzyfactory;

-- Step 1 : find the first pageview for each session
CREATE TEMPORARY TABLE first_pageviews
SELECT 
	website_session_id,	
    MIN(website_pageview_id) AS first_pv -- aka the first pageview in the session
FROM 
	website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY 
	website_session_id;

-- Step 2: find the url the customer saw on that first pageview 
SELECT 
	website_pageviews.pageview_url AS landing_page_url,
	COUNT( DISTINCT first_pageviews.website_session_id) AS sessuions_hitting_this_landing_page
FROM first_pageviews 
LEFT JOIN website_pageviews 
	ON  first_pageviews.first_pv = website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url

-- Results: the landing page are all home page now.
-- Next step: Analyze the landing page performance, and think about whether homepage is the best initial experience for all customers.
