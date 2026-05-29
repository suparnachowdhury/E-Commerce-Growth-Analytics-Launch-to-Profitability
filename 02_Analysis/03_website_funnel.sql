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
CREATE drop TEMPORARY TABLE first_pv_per_session
SELECT 
		website_session_id,
        MIN(website_pageview_id) as first_pv
FROM website_pageviews
WHERE created_at < '2023-03-21'
GROUP BY 
		website_session_id;
        
SELECT * FROM first_pv_per_session LIMIT 5;
SELECT count(*) FROM first_pv_per_session;

CREATE TEMPORARY TABLE sessions_with_home
SELECT 
		pv.website_session_id,
        pv.pageview_url as landing_page
FROM first_pv_per_session fs
LEFT JOIN   website_pageviews pv
ON pv.website_pageview_id = fs.first_pv
WHERE pv.pageview_url = "/home";
        
-- SELECT * FROM sessions_with_home LIMIT 5;
-- SELECT count(*) FROM sessions_with_home;

CREATE TEMPORARY TABLE only_bounces_session AS         
SELECT
		sh.website_session_id,
        sh.landing_page,
        COUNT(pv.website_pageview_id) AS count_of_page_viewed
FROM sessions_with_home sh
LEFT JOIN website_pageviews pv
ON sh.website_session_id = pv.website_session_id
GROUP BY
		sh.website_session_id,
        sh.landing_page
HAVING	
		 COUNT(pv.website_pageview_id) = 1;


SELECT 
		COUNT( DISTINCT fs.website_session_id) AS sessions,
        COUNT(DISTINCT bs.website_session_id) AS bounced_sessions,
        COUNT(DISTINCT bs.website_session_id)/COUNT(DISTINCT fs.website_session_id)
* 100.0 AS bounce_rate
FROM sessions_with_home fs	
LEFT JOIN only_bounces_session bs 
ON fs.website_session_id = bs.website_session_id;

/*
We A/B tested a new landing page (/lander-1) against /home for paid non-brand traffic. Compare bounce rates for both groups during the test window to see which page performed better.
Build a full conversion funnel from /lander-1 through to the thank-you page using data from August 5th onward. I want to see where we're losing people at each step so we know what to fix next.
*/