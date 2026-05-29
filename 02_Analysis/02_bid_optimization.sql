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

Jan 27, 2023 g_search non-brand campaign bid reduce · Analysis window: Jan 1 → Feb 23, 2023
*/

SELECT
    MIN(DATE(created_at))        AS week_start_date,
    COUNT(website_session_id)    AS sessions
FROM website_sessions
WHERE  created_at  < '2023-02-24'
  AND  utm_source   = 'g_search'
  AND  utm_campaign = 'nonbrand'
GROUP BY
    YEAR(created_at),
    WEEK(created_at);

/*
Finding:
	- Cutting nonbrand bids on January 27th caused an immediate ~37% drop in weekly 
      sessions (967 → 611), and traffic did not recover over the following three weeks. 
      
	- The volume loss is real and persistent, but this was an expected trade-off — 
       the prior CVR analysis showed nonbrand was converting poorly, so the lost sessions 
       were low-quality. 
	
*/


/*
Date: March 7, 2023
Subject: Did the desktop bid increase actually drive more volume?
Head of Marketing:
	"The nonbrand bid cut on January 27th dropped weekly sessions ~37%
	(from ~967 to ~611), confirming the expected traffic trade-off.
	
    After your device-level CVR analysis (from January 25, 2023) showed desktop 
    converting at 4.23% vs mobile at 0.99%, we increased bids on 
    g_search nonbrand desktop campaigns on March 7th.
    
	Pull the weekly desktop and mobile session trends so we can see whether
	the bid change lifted desktop volume — and confirm mobile is behaving
	as expected after de-prioritisation."

Mar 7, 2023 g_search nonbrand desktop bid increase · Analysis window: Feb 5 → Apr 15, 2023
*/

SELECT
    MIN(DATE(created_at))                                              AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop'
        THEN website_session_id END)                                   AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile'
        THEN website_session_id END)                                   AS mobile_sessions
FROM   website_sessions
WHERE  created_at  < '2023-04-16'           -- analysis window: Feb 5 → Apr 16, 2023
  AND  created_at >= '2023-02-05'
  AND  utm_source   = 'g_search'
  AND  utm_campaign = 'nonbrand'
GROUP BY  YEAR(created_at), WEEK(created_at)
ORDER BY  week_start_date;




/*
Date: March 7, 2023
Subject: Device-level CVR analysis due to  the desktop bid increase
Head of Marketing:
	"We improved desktop bids on March 7th after seeing desktop CVR was strong.
	Show me weekly session trends for desktop vs mobile separately,
	using April 15th as a cutoff, so we can see the delta after the bid increase."

Mar 7, 2023 bid change · Analysis window: Feb 5 → Apr 16, 2023
*/

SELECT
    MIN(DATE(w.created_at))                                            AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop'
        THEN w.website_session_id END)                                 AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop'
        THEN o.website_session_id END) * 100.0
        / COUNT(DISTINCT CASE WHEN device_type = 'desktop'
        THEN w.website_session_id END)                                 AS desktop_conv_rate,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile'
        THEN w.website_session_id END)                                 AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile'
        THEN o.website_session_id END) * 100.0
        / COUNT(DISTINCT CASE WHEN device_type = 'mobile'
        THEN w.website_session_id END)                                 AS mobile_conv_rate
FROM   website_sessions w
LEFT JOIN orders o
    ON w.website_session_id = o.website_session_id
WHERE  w.created_at  < '2023-04-16'         
  AND  w.created_at >= '2023-02-05'
  AND  w.utm_source   = 'g_search'
  AND  w.utm_campaign = 'nonbrand'
GROUP BY  YEAR(w.created_at), WEEK(w.created_at)
ORDER BY  week_start_date;

