/*
Head of Marketing: Date: February 1, 2023
We launched three weeks ago and I want to know where our first customers are actually coming from — 
break down sessions by traffic source, campaign, and device type so we know what's working.
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
Head of Marketing: Date: February 2, 2023
Now that we see paid search is dominant, I need to know whether those clicks are converting into sales. 
Calculate our session-to-order conversion rate by source. 
We need at least 3.5% to be profitable at our current CPC.
*/
SELECT
	COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)* 100.0 /COUNT(ws.website_session_id) AS  session_to_order_conv
FROM website_sessions ws 
LEFT JOIN orders o 
ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2023-02-02';



