-- Exploring Email Campaign variable distributions     

WITH email_link_clicks as (
    SELECT
        COUNT(EventID) as num_link_clicks,
        UserID
    FROM FrontendEventLog
    WHERE EventID = 5
    GROUP BY UserID
)

SELECT 
    num_link_clicks,
    COUNT(UserID) as num_users
FROM email_link_clicks
GROUP BY num_link_clicks;
