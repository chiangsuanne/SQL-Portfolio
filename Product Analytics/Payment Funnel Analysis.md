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
The provided SQL query aims to analyze the payment funnel for subscription sign-ups, identifying the stage at which users drop off or successfully complete the payment process. The output table presents the count of subscriptions at each stage of the payment funnel.	

**Payment Funnel Overview:**

PaymentWidgetOpened: 7 subscriptions started the payment process by opening the widget.	

PaymentEntered: 2 subscriptions proceeded to enter credit card information.	

User Error with Payment Submission: 1 subscription encountered a user error during payment submission.	

Payment Submitted: 1 subscription successfully submitted payment.	

Payment Processing Error with Vendor: 1 subscription faced an error during payment processing with the vendor.	

Payment Success: 1 subscription successfully completed the payment process.	

Complete: 12 subscriptions reached the final stage, signifying successful transactions.	

User did not start payment process: 3 subscriptions did not initiate the payment process.	

**Points of Concern:**	

There's a significant drop from the PaymentEntered stage to User Error with Payment Submission, suggesting potential issues during the user's input of credit card information.	

The presence of Payment Processing Error with Vendor indicates issues with the third-party payment processing company.

### Suggestions for Further Improvement
1. **Error Resolution:**

	Investigate and resolve issues related to payment processing errors with the vendor to ensure a smooth transaction process.	

2. **User Experience (UX) Optimization:**

	Analyze the 'Payment Entered' and 'Payment Widget Opened' stages to identify any user experience issues. Consider user feedback and make improvements to enhance the overall payment process.	

3. **Communication and Guidance:**

	For the 'Payment Submitted' and 'User Error with Payment Submission' stages, evaluate user guidance and communication. Clearer instructions or assistance may reduce errors and increase successful submissions.	

4. **Conversion Rate Optimization:**

	Focus on improving the conversion rates between stages, especially from 'Payment Widget Opened' to 'Payment Entered' and 'Payment Entered' to 'Complete.' This can positively impact the overall success rate.	

5. **Marketing and Onboarding Strategies:**

	Understand why some users did not start the payment process. This information can be valuable for refining marketing strategies, improving onboarding processes, or addressing potential concerns that deter users from initiating payments.	

6. **Continuous Monitoring:**

	Implement continuous monitoring of the payment funnel to promptly identify and address any emerging issues. Regularly update and optimize the process based on user behavior and feedback.	

By addressing these suggestions, the product manager can enhance the payment process, reduce errors, and ultimately improve the overall user experience, leading to increased successful transactions and customer satisfaction.
