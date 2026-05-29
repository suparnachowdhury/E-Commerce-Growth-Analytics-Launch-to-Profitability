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
	"We A/B tested a new landing page (/home-v3) against /home for paid non-brand traffic. 

	Compare bounce rates for both groups during the test window to see which page performed better."
*/




/*
Build a full conversion funnel from /lander-1 through to the thank-you page using data from August 5th onward. I want to see where we're losing people at each step so we know what to fix next.
*/