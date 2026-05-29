-- =====================================================================================
-- Optimizing ad spend after our first bid adjustment

-- Stakeholder: Head of Marketing
-- =====================================================================================

/*
Date: February 1, 2023
Subject: Where are our first customers coming from?

Head of Marketing:
Based on the CVR analysis, we cut bids on our primary non-brand campaign on April 15th. 

Pull weekly session volume since launch so we can see if cutting bids hurt our traffic, 
and by how much.
*/

SELECT
    -- YEAR(created_at) AS yr,
    -- WEEK(created_at) AS wk,
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at BETWEEN '2023-01-05' AND '2023-05-19'
  AND utm_source = 'g_search'
  AND utm_campaign = 'nonbrand'
GROUP BY
    YEAR(created_at),
    WEEK(created_at);

/*
Date: February 1, 2023
Subject: Where are our first customers coming from?

Head of Marketing:
"I noticed our mobile experience feels rough — pull conversion rates broken down by device 
type so we can see if mobile is dragging down our overall numbers.
*/

/*
Date: February 1, 2023
Subject: Where are our first customers coming from?

Head of Marketing:
We improved desktop bids on May 19th after seeing desktop CVR was strong. 
Show me weekly session trends for desktop vs mobile separately, 
using April 15th as a baseline, so we can see the delta after the bid increase.
*/