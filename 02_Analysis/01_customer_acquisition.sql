-- =====================================================
-- Diagnosing our customer acquisition engine

-- Stakeholder: Head of Marketing
-- ==============================================
/*
Date: February 1, 2023
Subject: Where are our first customers coming from?

Head of Marketing: "We launched our website and store three weeks ago. 

I want to know where our first customers are actually coming from — break 
down sessions by traffic source, campaign, and device type so we know what's working.


January 7, 2023 Website launch · Analysis window: Jan 7 -> Jan 31, 2023
*/

SELECT 
	utm_source,
    utm_campaign,
    device_type,
    COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2023-02-01'
GROUP BY 
	utm_source,
    utm_campaign,
    device_type
ORDER BY 
	sessions DESC;
    
/* 
Finding: 
	- g_search (nonbrand) accounts for 98%+ of all sessions. 
	- The business is almost entirely dependent on a single paid channel at launch — creating 
	  both urgency and opportunity to optimise it.
*/
    
    
/*
Date: February 2, 2023
Subject: Are paid clicks converting into sales?

Head of Marketing: 
	"Now that we see paid g_search (nonbrand) is dominant, I need to know whether 
	those clicks are converting into sales. 
    
    Calculate our session-to-order conversion rate by source. 
    
    We need at least 3.5% to be profitable at our current CPC."
    
January 7, 2023 Website launch · Analysis window: Jan 7 -> Feb 1, 2023
*/

SELECT
	COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)* 100.0 /COUNT(ws.website_session_id) AS  session_to_order_conv
FROM website_sessions ws 
LEFT JOIN orders o 
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2023-02-02'
  AND ws.utm_source = 'g_search'
  AND ws.utm_campaign = 'nonbrand';
  
/*
Alert: 
	- At 2.88% CVR, the business is spending on clicks that aren't converting enough 
	  to be profitable. 
      
	- This flags a critical need to either reduce CPC bids, improve the landing page, 
      or optimise which audience sees the ads.  
*/
  
 
  
/*
Date: February 27, 2023
Subject: Brand vs. nonbrand — are we bidding differently for a reason?

Head of Marketing: 
	"Our brand keyword bidding strategy is different from non-brand. 
    
	Show me conversion rates split by brand vs non-brand campaigns 
    across all paid channels."
    
January 7, 2023 Website launch · Analysis window: Jan 7 -> Feb 26, 2023
*/

SELECT
	ws.utm_campaign,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)* 100.0 /COUNT(ws.website_session_id) AS  session_to_order_conv
FROM website_sessions ws 
LEFT JOIN orders o 
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2023-02-27'
  AND ws.utm_source IN ('g_search', 'b_search')
GROUP BY ws.utm_campaign;
  
/*
Finding: 
	- Brand searchers convert at 5.64% — nearly 2× higher than nonbrand. This 
      validates protecting brand keyword spend. 
      
	- The nonbrand problem is structural: users aren't ready to buy when they arrive. 
	
    - The fix is on the landing page and funnel, not just the bid.
*/ 

/*
Date: February 28, 2023
Subject: Desktop vs. mobile — where should we focus spend?

Head of Marketing: 
	"With conversion still below target, we need to know if device type is a factor. 
    
	Show me CVR by device for g_search nonbrand so we can make a bid adjustment decision."
    
January 7, 2023 Website launch · Analysis window: Jan 7 -> Feb 27, 2023
*/
SELECT
    w.device_type,
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.website_session_id) AS orders,
    COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_ratio
FROM website_sessions w
LEFT JOIN orders o
    ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2023-02-28'
  AND w.utm_source = 'g_search'
  AND w.utm_campaign = 'nonbrand'
GROUP BY
    w.device_type;

/*
Action taken: 
	- Desktop already clears the 3.5% profitability threshold. 
	- Mobile at 0.98% is destroying ROI. 
    
Recommendation: 
	- Need to reduce mobile bids significantly, shift budget to desktop, and 
      investigate the mobile UX separately before scaling back.
*/

/*
Date: April 17, 2023
Subject: Did the desktop bid increase actually drive more volume?

Head of Marketing: 
	"After your device-level CVR analysis showed desktop converting at 3.77% vs 
	mobile at 0.98%, we increased bids on g_search nonbrand desktop campaigns on 
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
WHERE  created_at BETWEEN '2023-02-05' AND '2023-04-19'
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