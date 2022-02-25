-- Task: As all the traffic is landing on the homepage now, check the landing page performance by pulling bounce rate. 
USE mavenfuzzyfactory;

-- Step 1: Find the first website_pageview_id for relevant sessions. 
CREATE TEMPORARY TABLE first_pageviews
SELECT 
	website_session_id,	
    MIN(website_pageview_id) AS first_pv -- aka the first pageview in the session
FROM 
	website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY 
	website_session_id;
    
-- Step 2： Identify the landing page of each session. 
CREATE TEMPORARY TABLE  session_home_landing_page
SELECT 
	first_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_pageview_id=first_pageviews.first_pv
WHERE website_pageviews.pageview_url='/home';   -- since already know that home page is the only landing page 

-- Step 3： Count pageviews for each session, to identify bounces. 
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	session_home_landing_page.website_session_id,
    session_home_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed 
FROM session_home_landing_page 
LEFT JOIN website_pageviews 
	ON website_pageviews.website_session_id=session_home_landing_page.website_session_id 
GROUP BY 
	session_home_landing_page.website_session_id,
    session_home_landing_page.landing_page
    HAVING COUNT(website_pageviews.website_pageview_id)=1; -- "Bounce" means the customer bounces away after the first click.

-- Step 4: Summarize by counting total sessions and bounced sessions. 
SELECT 
	COUNT(DISTINCT session_home_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions, -- Only the count of 1 have been joined, the others will shown as NULL 
	COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT session_home_landing_page.website_session_id) AS bounce_rate
FROM session_home_landing_page
	LEFT JOIN bounced_sessions 
		ON session_home_landing_page.website_session_id=bounced_sessions.website_session_id;
        
-- Results: 59% of bounce rate, represents a major area of improvement. 
	