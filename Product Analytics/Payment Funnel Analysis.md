## Data scheme	
![image](https://github.com/chiangsuanne/SQL-Portfolio/assets/108243961/41fa9399-4efa-46f3-a9b1-104498f7b592)  

## Payment Funnel Analysis
### Objective  
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

### Conclusion

### Suggestions for Further Improvement
