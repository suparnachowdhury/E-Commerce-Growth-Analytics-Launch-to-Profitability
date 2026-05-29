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

/** 
Cross-Channel Bid Optimization
Marketing Director: 
Should we bid bsearch the same as gsearch?
Could you pull nonbrand conversion rates from session to order for gsearch and bsearch, 
and slice the data by device type?  

*/
SELECT
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)* 100.0/ COUNT(DISTINCT website_sessions.website_session_id) conv_rate
FROM website_sessions 
LEFT JOIN orders 
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at >= '2023-09-03' AND 
website_sessions.created_at <= '2023-10-10' AND 
website_sessions.utm_campaign = 'nonbrand'
GROUP BY
		website_sessions.device_type,
    website_sessions.utm_source;
    
/** 
Analyzing Channel Portfolio Trends
Marketing Director: Based on your last analysis, we bid down bsearch nonbrand on December 2nd.  

Can you pull weekly session volume for gsearch and bsearch nonbrand, 
broken down by device, since November 4th? 
If you can include a comparison metric to show bsearch as a percent of gsearch for each device,
that would be great too.
*/

SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN utm_source='g_search' AND device_type = 'desktop'
                    THEN website_session_id ELSE NULL END) AS g_dtop_sessions, 
	COUNT(DISTINCT CASE WHEN utm_source='b_search' AND device_type = 'desktop'
                    THEN website_session_id ELSE NULL END) AS b_dtop_sessions, 
    COUNT(DISTINCT CASE WHEN utm_source='b_search' AND device_type = 'desktop'
                    THEN website_session_id ELSE NULL END) / 
	COUNT(DISTINCT CASE WHEN utm_source='g_search' AND device_type = 'desktop'
                    THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop, 
    COUNT(DISTINCT CASE WHEN utm_source='g_search' AND device_type = 'mobile'
                    THEN website_session_id ELSE NULL END) AS g_mob_sessions, 
	COUNT(DISTINCT CASE WHEN utm_source='b_search' AND device_type = 'mobile'
                    THEN website_session_id ELSE NULL END) AS b_mob_sessions, 
    COUNT(DISTINCT CASE WHEN utm_source='b_search' AND device_type = 'mobile'
                    THEN website_session_id ELSE NULL END) / 
	COUNT(DISTINCT CASE WHEN utm_source='g_search' AND device_type = 'mobile'
                    THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob
FROM website_sessions
WHERE created_at > '2023-08-18'
AND created_at < '2023-10-05'
AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at)
ORDER BY YEARWEEK(created_at);


/*
Analyzing_Direct_Traffic
CEO:A potential investor is asking if we’re building any momentum with our brand or
 if we’ll need to keep relying on paid traffic.  

Could you pull organic search, direct type in, and paid brand search sessions by month,
 and show those sessions as a % of paid search nonbrand?
 */ 
 
 -- SELECT * FROM website_sessions limit 5;

SELECT
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END)* 100.0
        / COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) AS direct,
    COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) * 100.0
        / COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
       COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) AS organic,
    COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) * 100.0
        / COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
        FROM
        (SELECT
    website_session_id,
    created_at,
    CASE
        WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') 
        THEN 'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
    END AS channel_group
FROM website_sessions
WHERE created_at < '2023-12-23') a
GROUP BY 1,2
ORDER BY 1,2;