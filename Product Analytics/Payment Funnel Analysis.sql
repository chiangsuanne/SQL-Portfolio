-- Payment Funnel Analysis   

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
