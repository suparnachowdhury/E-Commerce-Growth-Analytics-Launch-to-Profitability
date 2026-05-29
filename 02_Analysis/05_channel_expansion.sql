/** 
Marketing Director: 
With gsearch doing well and the site performing better, we launched a second paid search 
channel (b_search) on August 22nd. Pull weekly session volume for both channels side-by-side so I can see how fast bsearch is scaling relative to our primary channel.

**/

select min(created_at) from website_sessions
where utm_source ='b_search'