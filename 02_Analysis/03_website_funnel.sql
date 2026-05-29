/*
BUILDING CONVERSION FUNNEL
Website Manager: I’d like to understand where we lose our search visitors between the new /home-v2 
page and placing an order. 
Can you build us a full conversion funnel, analyzing how many customers make it to each step?
Start with /home-v2 and build the funnel all the way to our thank you page.
 Please use data since May 14th.

*/
select distinct pageview_url from website_pageviews limit 5;
select * from website_sessions limit 5;

SELECT 
	  ws.website_session_id,
      wp.pageview_url,
      CASE WHEN wp.pageview_url = '/products' then 1 else 0 end as product_page,
      case when wp.pageview_url = '/the-aldgate-picture-frame-set' then 1 else 0 end as picture_frame_page,
      case when wp.pageview_url = '/cart' then 1 else 0 end as cart_page,
      case when wp.pageview_url = '/billing' then 1 else 0 end as billing_page,
      case when wp.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
      case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions ws
join website_pageviews wp
on ws.website_session_id = wp.website_session_id
where  ws.utm_source = 'g_search'
and ws.utm_campaign = 'nonbrand'
and wp.created_at > '2023-05-14' and 
wp.created_at < '2023-06-14' 
order by ws.website_session_id,
      wp.created_at;
      
create temporary table session_level_made_it_flags AS      
select 
website_session_id,
max(product_page) as product_made_it,
max(picture_frame_page) as picture_frame_made_it,
max(cart_page) as cart_made_it,
max(billing_page) as billing_made_it,
max(shipping_page) as shipping_made_it,
max(thankyou_page) as thankyou_made_it
from  (
	SELECT 
	  ws.website_session_id,
      wp.pageview_url,
      CASE WHEN wp.pageview_url = '/products' then 1 else 0 end as product_page,
      case when wp.pageview_url = '/the-aldgate-picture-frame-set' then 1 else 0 end as picture_frame_page,
      case when wp.pageview_url = '/cart' then 1 else 0 end as cart_page,
      case when wp.pageview_url = '/billing' then 1 else 0 end as billing_page,
      case when wp.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
      case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions ws
join website_pageviews wp
on ws.website_session_id = wp.website_session_id
where  ws.utm_source = 'g_search'
and ws.utm_campaign = 'nonbrand'
and wp.created_at > '2023-05-14' and 
wp.created_at < '2023-06-14' 
order by ws.website_session_id,
      wp.created_at) as pageview_level
group by website_session_id;


select
 count(distinct case when product_made_it = 1 then website_session_id else null end)/ 
 count(distinct website_session_id) as products_click_rate, 
 count(distinct case when picture_frame_made_it = 1 then website_session_id else null end)/
  count(distinct case when product_made_it = 1 then website_session_id else null end)as products_click_rate,
 count(distinct case when cart_made_it = 1 then website_session_id else null end)/
 count(distinct case when picture_frame_made_it = 1 then website_session_id else null end)as mrfuzzy_click_rate,
 count(distinct case when shipping_made_it = 1 then website_session_id else null end) /
 count(distinct case when cart_made_it = 1 then website_session_id else null end)as carts_click_rate,
 count(distinct case when billing_made_it = 1 then website_session_id else null end) /
 count(distinct case when shipping_made_it = 1 then website_session_id else null end) as shipping_click_rate,
 count(distinct case when thankyou_made_it = 1 then website_session_id else null end)/
  count(distinct case when billing_made_it = 1 then website_session_id else null end)
 as billing_click_rate
from session_level_made_it_flags;



/*
ANALYZING CONVERSION FUNNEL TEST
Website Manager: 
We tested an updated billing page based on your funnel analysis. 
Can you take a look and see whether /billing-2 is doing any better than the original /billing page?

We’re wondering what % of sessions on those pages end up placing an order. 
FYI – we ran this test for all traffic, not just for our search visitors.
*/
select min(created_at) as first_created_at
from website_pageviews
where pageview_url= '/billing-2';
-- first_created_at: '2023-06-24 00:13:05'



CREATE TEMPORARY TABLE billing_test_sessions AS
SELECT 
    website_session_id,
    MAX(billing_page) AS billing_made_it,
    MAX(billing2_page) AS billing2_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM (
    SELECT 
        ws.website_session_id,
        wp.pageview_url,
        CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
        CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing2_page,
        CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
    FROM website_sessions ws
    JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    WHERE wp.created_at >= '2023-06-24'
      AND wp.created_at < '2023-09-10'
      AND wp.pageview_url IN (
            '/billing',
            '/billing-2',
            '/thank-you-for-your-order'
      )
) AS pageview_level
GROUP BY website_session_id;


