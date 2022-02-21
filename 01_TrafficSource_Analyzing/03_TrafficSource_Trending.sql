USE mavenfuzzyfactory;

SELECT 
	-- YEAR(created_at) AS yr,
    -- WEEK(created_at) AS wk,
	MIN(DATE(w.created_at)) AS week_start_date,
	COUNT(DISTINCT w.website_session_id) AS sessions
FROM website_sessions w
WHERE w.created_at < '2012-05-10'
	AND w.utm_campaign='nonbrand'
    AND w.utm_source='gsearch'
GROUP BY  -- can group by columns that haven't been selected 
	YEAR(created_at),
    WEEK(created_at)

-- from the result table, volume did drop down since 2012-04-15
-- should act on something to bring it back again, but at the same time keep the efficient budget