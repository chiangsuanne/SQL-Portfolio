-- Calculating descriptive statistics for monthly revenue by product	  

**Query**
```sql
WITH product_rev as (
SELECT 
    ProductName,
    sum(Revenue) as monthly_rev,
    date_trunc('month', OrderDate) as order_month
FROM Products as p
JOIN Subscriptions as s
WHERE p.PRODUCTID = s.PRODUCTID
    AND date_trunc('month', OrderDate) BETWEEN '2022-01-01' AND '2022-12-01'
GROUP BY ProductName, order_month
)

SELECT
    ProductName,
    min(monthly_rev) as min_rev,
    max(monthly_rev) as max_rev,
    avg(monthly_rev) as avg_rev,
    stddev(monthly_rev) as std_dev_rev
FROM product_rev
GROUP BY ProductName;
````



-- Exploring Email Campaign variable distributions     

**Query**
```sql
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
````



-- Payment Funnel Analysis   

**Query**
```sql
WITH max_status_reached AS (
	SELECT
		MAX(StatusID) AS maxstatus,
		SubscriptionID
	FROM
		PaymentStatusLog
	GROUP BY SubscriptionID
)
,
	paymentfunnelstages AS (
	SELECT
		s.SubscriptionID,
		CASE WHEN maxstatus = 1 then 'PaymentWidgetOpened'
		when maxstatus = 2 then 'PaymentEntered'
		when maxstatus = 3 and currentstatus = 0 then 'User Error with Payment Submission'
		when maxstatus = 3 and currentstatus != 0 then 'Payment Submitted'
		when maxstatus = 4 and currentstatus = 0 then 'Payment Processing Error with Vendor'
		when maxstatus = 4 and currentstatus != 0 then 'Payment Success'
		when maxstatus = 5 then 'Complete'
		when maxstatus is null then 'User did not start payment process'
		END AS paymentfunnelstage
	FROM Subscriptions AS s
	JOIN max_status_reached AS m
	WHERE s.SubscriptionID = m.SubscriptionID
)

SELECT
	paymentfunnelstage,
	COUNT(SubscriptionID) AS subscriptions
FROM paymentfunnelstages
GROUP BY paymentfunnelstage;
````
