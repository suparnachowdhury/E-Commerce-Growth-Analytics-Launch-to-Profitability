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
-- Time window: 2012-06-19 to 2012-07-28

-- STEP 1: Filter test sessions
CREATE TEMPORARY TABLE test_sessions AS
SELECT 
    website_session_id,
    created_at
FROM website_sessions
WHERE created_at >= '2023-04-02'
  AND created_at < '2023-05-15'
  AND utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand';


-- STEP 2: Identify landing page per session (first pageview)
CREATE TEMPORARY TABLE session_landing AS
SELECT
    pv.website_session_id,
    pv.pageview_url AS landing_page
FROM website_pageviews pv
INNER JOIN test_sessions ts
    ON pv.website_session_id = ts.website_session_id
INNER JOIN (
    SELECT
        website_session_id,
        MIN(website_pageview_id) AS first_pv_id
    FROM website_pageviews
    GROUP BY website_session_id
) fp
    ON pv.website_session_id = fp.website_session_id
   AND pv.website_pageview_id = fp.first_pv_id
WHERE pv.pageview_url IN ('/home', '/home-v2');


-- STEP 3: Count pageviews per session
CREATE TEMPORARY TABLE session_pageviews AS
SELECT
    website_session_id,
    COUNT(*) AS pageviews
FROM website_pageviews
GROUP BY website_session_id;


-- STEP 4: Identify bounced sessions
CREATE TEMPORARY TABLE bounced_sessions AS
SELECT
    website_session_id
FROM session_pageviews
WHERE pageviews = 1;


-- STEP 5: Final A/B test result
SELECT
    sl.landing_page,
    COUNT(*) AS sessions,
    SUM(CASE 
            WHEN bs.website_session_id IS NOT NULL THEN 1 
            ELSE 0 
        END) AS bounced_sessions,
    SUM(CASE 
            WHEN bs.website_session_id IS NOT NULL THEN 1 
            ELSE 0 
        END) * 1.0 / COUNT(*) AS bounce_rate
FROM session_landing sl
LEFT JOIN bounced_sessions bs
    ON sl.website_session_id = bs.website_session_id
GROUP BY sl.landing_page;
/*
Build a full conversion funnel from /lander-1 through to the thank-you page using data from August 5th onward. I want to see where we're losing people at each step so we know what to fix next.
*/