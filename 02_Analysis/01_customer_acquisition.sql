/*
Head of Marketing: Date: February 1, 2023
We launched our website and store  three weeks ago and I want to know where our first customers are actually 
coming from — break down sessions by traffic source, campaign, and device type so we know what's working.
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
    
/* Finding: g_search (nonbrand) accounts for 98%+ of all sessions. 
The business is almost entirely dependent on a single paid channel at launch — 
creating both urgency and opportunity to optimise it.
*/
    
    
/*
Head of Marketing: Date: February 2, 2023
Now that we see paid g_search (nonbrand) is dominant, I need to know whether 
those clicks are converting into sales. Calculate our session-to-order conversion rate by source. 
We need at least 3.5% to be profitable at our current CPC.
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
Alert: At 2.88% CVR, the business is spending on clicks that aren't converting enough to be profitable. 
This flags a critical need to either reduce CPC bids, improve the landing page, or optimise 
which audience sees the ads. 

The data creates an immediate business case for action.  
*/
  
 
  
/*
Head of Marketing: Date: February 27, 2023
"Our brand keyword bidding strategy is different from non-brand. 
Show me conversion rates split by brand vs non-brand campaigns across all paid channels."
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
Finding: Brand searchers convert at 5.64% — nearly 2× higher than nonbrand. 
This validates protecting brand keyword spend. 
The nonbrand problem is structural: users aren't ready to buy when they arrive. 
The fix is on the landing page and funnel, not just the bid.
*/ 

/*

Desktop vs. mobile — where should we focus spend?
Head of Marketing: Date: February 28, 2023
"With conversion still below target, we need to know if device type is a factor. 
Show me CVR by device for g_search nonbrand so we can make a bid adjustment decision."
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





