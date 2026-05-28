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



