-- =====================================================================================
-- Diagnosing our customer acquisition engine

-- Stakeholder: Head of Marketing
-- =====================================================================================
/*

Date: January 24, 2023
Subject: Where are our first customers coming from?

Head of Marketing: "We launched our website and store three weeks ago. 

I want to know where our first customers are actually coming from — break 
down sessions by traffic source, campaign, and device type so we know what's working.


January 1, 2023 Website launch · Analysis window: Jan 1 -> Jan 23, 2023
*/

SELECT 
	utm_source,
    utm_campaign,
    device_type,
    COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2023-01-24'
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
Date: January 24, 2023
Subject: Are paid clicks converting into sales?

Head of Marketing: 
	"Now that we see paid g_search nonbrand  is dominant, I need to know whether 
	those clicks are converting into sales. 
    
    Calculate our session-to-order conversion rate by source. 
    
    We need at least 3.5% to be profitable at our current CPC."
    
January 1, 2023 Website launch · Analysis window: Jan 1 -> Jan 23, 2023
*/

SELECT
	COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)* 100.0 /COUNT(ws.website_session_id) AS  session_to_order_conv
FROM website_sessions ws 
LEFT JOIN orders o 
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2023-01-24'
  AND ws.utm_source = 'g_search'
  AND ws.utm_campaign = 'nonbrand';
  
/*
Alert: 
	- At 2.98% CVR, the business is spending on clicks that aren't converting enough 
	  to be profitable. 
      
	- This flags a critical need to either reduce CPC bids, improve the landing page, 
      or optimise which audience sees the ads.  
*/
  
 
  
/*
Date: January 25, 2023
Subject: Brand vs. nonbrand — are we bidding differently for a reason?

Head of Marketing: 
	"Our brand keyword bidding strategy is different from non-brand. 
    
	Show me conversion rates split by brand vs non-brand campaigns 
    across all paid channels."
    
January 1, 2023 Website launch · Analysis window: Jan 7 -> Jan 24, 2023
*/

SELECT
	ws.utm_campaign,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)* 100.0 /COUNT(ws.website_session_id) AS  session_to_order_conv
FROM website_sessions ws 
LEFT JOIN orders o 
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2023-01-25'
  AND ws.utm_source IN ('g_search', 'b_search')
GROUP BY ws.utm_campaign;
  
/*
Finding: 
	- Brand searchers convert at 6.08% — more than 2× higher than nonbrand. This 
      validates protecting brand keyword spend. 
      
	- The nonbrand problem is structural: users aren't ready to buy when they arrive. 
	
    - The fix is on the landing page and funnel, not just the bid.
*/ 

