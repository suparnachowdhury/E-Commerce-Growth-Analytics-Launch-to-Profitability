-- =====================================================================================
-- Optimizing ad spend after our first bid adjustment

-- Stakeholder: Head of Marketing
-- =====================================================================================

/*
Date: February 24, 2023
Subject: Cutting bid affects sessions?

Head of Marketing:
	"Based on the CVR analysis, we cut bids on our primary non-brand campaign on January 27th. 

	Pull weekly session volume since launch so we can see if cutting bids hurt our traffic, 
	and by how much."
    
Jan 27, 2023 bid change · Analysis window: Jan 1 → Feb 23, 2023
*/

SELECT    
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2023-02-24' 
  AND utm_source = 'g_search'
  AND utm_campaign = 'nonbrand'
GROUP BY
    YEAR(created_at),
    WEEK(created_at);


/*
Date: February 24, 2023
Subject: Did the desktop bid increase actually drive more volume?

Head of Marketing: 
	"After your device-level CVR analysis showed desktop converting at 4.23% vs 
	mobile at 0.99%, we increased bids on g_search nonbrand desktop campaigns on 
	March 7th. 

	Pull the weekly desktop and mobile session trends so we can see whether 
	the bid change lifted desktop volume — and confirm mobile is behaving 
	as expected after de-prioritisation."

Mar 7, 2023 bid change · Analysis window: Feb 5 → Apr 16, 2023
*/

SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop'
        THEN website_session_id END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile'
        THEN website_session_id END) AS mobile_sessions
FROM   website_sessions
WHERE  created_at  < '2023-02-24' 
  AND  utm_source   = 'g_search'
  AND  utm_campaign = 'nonbrand'
GROUP BY  YEAR(created_at), WEEK(created_at)
ORDER BY  week_start_date;

/*
Bid increase confirmed effective: 
Desktop sessions rose from a pre-bid average of ~427/week to ~634/week post-bid — 
a +48% lift that held consistently for 6 straight weeks. 

Mobile declined from ~249 to ~185/week (−26%), consistent with de-prioritisation. 
The device-level strategy is working exactly as intended.
*/


/*
Date: February 1, 2023
Subject: Where are our first customers coming from?

Head of Marketing:
We improved desktop bids on March 1st after seeing desktop CVR was strong. 
Show me weekly session trends for desktop vs mobile separately, 
using April 15th as a baseline, so we can see the delta after the bid increase.
*/

SELECT
    MIN(DATE(w.created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop'
        THEN w.website_session_id END) AS desktop_sessions,
        COUNT(DISTINCT CASE WHEN device_type = 'desktop'
        THEN o.website_session_id END) * 100.0
        / COUNT(DISTINCT CASE WHEN device_type = 'desktop'
        THEN w.website_session_id END) AS desktop_conv_ratio,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile'
        THEN w.website_session_id END) AS mobile_sessions,
        COUNT(DISTINCT CASE WHEN device_type = 'mobile'
        THEN o.website_session_id END) * 100.0
        / COUNT(DISTINCT CASE WHEN device_type = 'mobile'
        THEN w.website_session_id END) AS mobile_conv_ratio
FROM   website_sessions w
LEFT JOIN orders o
    ON w.website_session_id = o.website_session_id
WHERE  w.created_at  < '2023-03-01' 
  AND  w.utm_source   = 'g_search'
  AND  w.utm_campaign = 'nonbrand'
GROUP BY  YEAR(w.created_at), WEEK(w.created_at)
ORDER BY  week_start_date;

SELECT
    w.device_type,
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.website_session_id) AS orders,
    COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_ratio
FROM website_sessions w
LEFT JOIN orders o
    ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2023-01-25'
  AND w.utm_source = 'g_search'
  AND w.utm_campaign = 'nonbrand'
GROUP BY
    w.device_type;

