/*
Date: March 20, 2023
Subject: 
New Website Manager: 
	"I'm new to this site and need to understand how people move through it. 

	Pull the the most-viewed website pages, ranked by session volume. 

	I want to know what visitors see first."

*/
SELECT
	pageview_url,
    COUNT(website_pageview_id) AS sessions
FROM website_pageviews
WHERE created_at < '2023-03-20'
GROUP BY pageview_url
ORDER BY sessions DESC;

/*
Date: March 20, 2023
Subject: Finding top entry pages
New Website Manager: 
Would you be able to pull a list of the top entry pages? I want to confirm 
where our users are hitting the site.
If you could pull all entry pages and rank them on entry volume,
that would be great.
*/

CREATE TEMPORARY TABLE first_pv_per_session
SELECT 
		website_session_id,
        MIN(website_pageview_id) as first_pv
FROM website_pageviews
WHERE created_at < '2023-03-20'
GROUP BY 
		website_session_id;
        
-- SELECT * FROM first_pv_per_session;        
SELECT
        pv.pageview_url AS landing_page,
        COUNT(fs.website_session_id) as sessions_hitting_this_page
FROM first_pv_per_session fs
LEFT JOIN website_pageviews  pv
ON fs.first_pv = pv.website_pageview_id
GROUP BY
		pv.pageview_url;
        


/*
Date: April 21, 2023
Subject: 
New Website Manager: 
	"Almost all traffic lands on /home. 
    
    Pull the bounce rate for that page — I want sessions, bounced sessions, 
    and bounce rate % so we can see if it's doing its job."
*/
CREATE TEMPORARY TABLE bounced_sessions AS
SELECT 
    website_session_id
FROM website_pageviews
WHERE created_at < '2023-03-21'
GROUP BY website_session_id
HAVING COUNT(*) = 1;


SELECT
    COUNT(DISTINCT pv.website_session_id) AS sessions,
    COUNT(DISTINCT bs.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bs.website_session_id) * 1.0 
        / COUNT(DISTINCT pv.website_session_id) AS bounce_rate
FROM website_pageviews pv
LEFT JOIN bounced_sessions bs
    ON pv.website_session_id = bs.website_session_id
WHERE pv.created_at < '2023-03-21'
AND pv.pageview_url = '/home';

/*
Date: April 21, 2023
Subject: 
Website Manager: 
	"We A/B tested a new landing page (/home-v2) against /home for paid non-brand traffic. 

	Compare bounce rates for both groups during the test window to see which page performed better."
*/

SELECT
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pv
FROM website_pageviews
WHERE pageview_url = '/home-v2';

# first_created_at: 2023-04-02 00:35:54, 
# first_pv: 23504

-- A/B TEST: Bounce rate comparison (/home vs /home-v2)
-- Traffic: gsearch nonbrand
-- Time window: 2023-04-02 to 2023-04-02

-- STEP 2: Finding the landing page sessions which are the sessions with
-- minimum pageview_ids.

CREATE TEMPORARY TABLE first_pv_per_session
SELECT
	pv.website_session_id,
    MIN(pv.website_pageview_id) AS first_pv
FROM website_pageviews pv
INNER JOIN website_sessions ws 
ON pv.website_session_id = ws.website_session_id
WHERE pv.created_at >= '2023-04-02'
  AND pv.created_at < '2023-05-15'
  AND ws.utm_source = 'g_search'
  AND ws.utm_campaign = 'nonbrand'
GROUP BY 
	pv.website_session_id;
    
    
-- STEP 3: Filtering out only the home and lander-1 landing pages
    
CREATE TEMPORARY TABLE sessions_landing_page
SELECT 
		pv.website_session_id,
        pv.pageview_url as landing_page
FROM first_pv_per_session fs
LEFT JOIN   website_pageviews pv
ON pv.website_pageview_id = fs.first_pv
WHERE pv.pageview_url  IN ('/home','/home-v2') ;

-- STEP 4: then we count pageviews per session limiting to bounced sessions

CREATE TEMPORARY TABLE only_bounced_session AS         
SELECT
		sh.website_session_id,
        sh.landing_page,
        COUNT(pv.website_pageview_id) AS count_of_page_viewed
FROM sessions_landing_page sh
LEFT JOIN website_pageviews pv
ON sh.website_session_id = pv.website_session_id
GROUP BY
		sh.website_session_id,
        sh.landing_page
HAVING	
		 COUNT(pv.website_pageview_id) = 1;
         
-- Final output
SELECT 
	 sessions_landing_page.landing_page,
     COUNT(sessions_landing_page.website_session_id) AS sessions,
     COUNT( only_bounced_session.website_session_id) AS bounced_sessions,
     COUNT( only_bounced_session.website_session_id)/
     COUNT(sessions_landing_page.website_session_id) * 100.0 AS bounce_rate
FROM sessions_landing_page 
LEFT JOIN only_bounced_session
ON sessions_landing_page.website_session_id = only_bounced_session.website_session_id
GROUP BY sessions_landing_page.landing_page;


/*
LANDING PAGE TREND ANALYSIS
Website Manager: 
Could you pull the volume of paid search nonbrand traffic landing 
on /home and /home-v2, trended weekly since June 1st? 
I want to confirm the traffic is all routed correctly.
Could you also pull our overall paid search bounce rate trended weekly? 
I want to make sure the lander change has improved the overall picture.
*/


SELECT * FROM website_sessions LIMIT 5;
SELECT   DISTINCT utm_content FROM website_sessions LIMIT 5;

-- STEP 1: Finding the landing page sessions which are the sessions with
-- minimum pageview_ids.

 
 CREATE TEMPORARY TABLE session_w_min_pv_id_view_count
 SELECT    
	pv.website_session_id,
    MIN(pv.website_pageview_id) AS first_pv,
    COUNT(pv.website_pageview_id) AS pageview_counts
FROM website_pageviews pv
INNER JOIN website_sessions ws 
ON pv.website_session_id = ws.website_session_id
WHERE pv.created_at >= '2023-04-01'
AND pv.created_at <'2023-06-15'
AND ws.utm_campaign = 'nonbrand'
AND ws.utm_source = 'g_search'
GROUP BY
		pv.website_session_id;
        
-- STEP 3: Filtering out only the home and lander-1 landing pages
    
CREATE TEMPORARY TABLE sessions_w_landing_page_created_at
SELECT 
		fs.*,
        pv.created_at,
        pv.pageview_url as landing_page
FROM session_w_min_pv_id_view_count fs
LEFT JOIN   website_pageviews pv
ON pv.website_pageview_id = fs.first_pv;

-- SELECT * FROM sessions_w_landing_page_created_at LIMIT 5;
-- STEP 4: Then we count pageviews per session limiting to bounced sessions
        
-- Final output

SELECT 
	 YEARWEEK(created_at) AS year_week,
     MIN(DATE(created_at)) AS week_start_date,
     COUNT(DISTINCT website_session_id) AS total_sessions,
     COUNT(DISTINCT CASE WHEN pageview_counts = 1 
				THEN website_session_id ELSE NULL END ) AS bounced_sessions,
	COUNT(DISTINCT CASE WHEN pageview_counts = 1 
				THEN website_session_id ELSE NULL END )/
                COUNT(DISTINCT website_session_id)*100.0 AS bounced_rate,
     COUNT(CASE WHEN landing_page = '/home' 
				THEN website_session_id ELSE NULL END ) AS home_sessions,
	COUNT(CASE WHEN landing_page = '/lander-1' 
				THEN website_session_id ELSE NULL END ) AS lander1_sessions
FROM sessions_w_landing_page_created_at
GROUP BY YEARWEEK(created_at);

/*
Build a full conversion funnel from /home-v2 through to the thank-you page using data 
from August 5th onward. 

I want to see where we're losing people at each step so we know what to fix next.
*/