## Data scheme	
![image](https://github.com/chiangsuanne/SQL-Portfolio/assets/108243961/41fa9399-4efa-46f3-a9b1-104498f7b592)

### Calculating descriptive statistics for monthly revenue by product
**Business problem:**	  
The leadership team at your company is making goals for 2023 and wants to understand how much revenue each product subscriptions, basic and expert, are generating each month. More specifically, they want to understand the distribution of monthly revenue across the past year, 2022.	
They've asked the following questions:	
1. How much revenue does each product usually generate each month?
2. Which product had the most success throughout all of last year?
3. Did either product fluctuate greatly each month or was the month-to-month trend fairly consistent?

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
**Output**
| PRODUCTNAME | MIN_REV | MAX_REV | AVG_REV | STD_DEV_REV        |
|-------------|---------|---------|---------|--------------------|
| Basic       | 500     | 28000   | 13188   | 8123.763642197237  |
| Expert      | 3000    | 46000   | 18000   | 13796.134724383252 |

The Expert monthly revenues had more variability, whereas the Basic monthly revenues were more centered on the mean.    Although the Expert product produced more revenue on average, the Basic product was a little more consistent.

### Exploring Email Campaign variable distributions
**Business problem:**    
A marketing manager wants to understand the performance of their recent email campaign. After the campaign launch, the marketing manager wants to know how many users have clicked the link in the email.   

Tracking events located in the FrontendEventLog table, is logged when the user reaches a unique landing page that is only accessed from this campaign email.    
Since an overall aggregate metric like an average can hide outliers and further insights under the hood, it's best to calculate distribution of the number of email link clicks per user.    

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
**Output**    
| NUM_LINK_CLICKS | NUM_USERS |
|-----------------|-----------|
| 1               | 3         |
| 2               | 2         |
| 3               | 1         |    

### Payment Funnel Analysis
**Business problem:**    
The product manager has requested a payment funnel analysis from the analytics team; she wants to understand what the furthest point in the payment process users are getting to and where users are falling out of the process. She wants to have full visibility into each possible stage of the payment process from the user's point of view.    

Here's the payment process a user goes through when signing up for a subscription:    
1. The user opens the widget to initiate a payment process.
2. The user types in credit card information.
3. The user clicks the submit button to complete their part of the payment process.
4. The product sends the data to the third-party payment processing company.
5. The payment company completes the transaction and reports back with "complete."    

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
**Output**
| PAYMENTFUNNELSTAGE                   | SUBSCRIPTIONS |
|--------------------------------------|---------------|
| Complete                             | 12            |
| Payment Processing Error with Vendor | 1             |
| Payment Submitted                    | 1             |
| Payment Success                      | 1             |
| PaymentEntered                       | 2             |
| PaymentWidgetOpened                  | 7             |
| User Error with Payment Submission   | 1             |
| User did not start payment process   | 3             |

