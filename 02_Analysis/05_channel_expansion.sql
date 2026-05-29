/** 
Marketing Director: 
With gsearch doing well and the site performing better, we launched a second paid search 
channel (b_search) on September 3rd. 

Pull weekly session volume for both channels side-by-side so I can see how fast b_search 
is scaling relative to our primary channel.

**/

SELECT
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN utm_source= 'g_search' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(CASE WHEN utm_source= 'b_search' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE created_at >= '2023-09-03'
AND created_at <= '2023-11-04'
AND utm_source IN ('g_search','b_search')
GROUP BY
	YEAR(created_at),
    WEEK(created_at);
    
/** 
Marketing Director: 
I’d like to understand bsearch's audience — compare the share of mobile traffic 
between bsearch and gsearch since September 3rd. 

Are these different audiences?

**/
SELECT
utm_source,
COUNT(DISTINCT website_session_id) AS sessions, 
COUNT(DISTINCT CASE WHEN  device_type = 'mobile' THEN website_session_id ELSE 0 END) as mobile_sessions,
COUNT(DISTINCT CASE WHEN  device_type = 'mobile' THEN website_session_id ELSE 0 END)* 100.0/
 COUNT(DISTINCT website_session_id)as pct_mobile 
FROM website_sessions
WHERE created_at >= '2023-09-03' AND 
created_at < '2023-12-15' AND
utm_campaign = 'nonbrand'
GROUP BY utm_source;