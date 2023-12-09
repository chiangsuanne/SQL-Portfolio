# Registrations by month
  
WITH reg_dates AS (
  SELECT
    user_id,
    MIN(order_date) AS reg_date
  FROM orders
  GROUP BY user_id)

SELECT
  /* Count the unique user IDs by registration month */
  DATE_TRUNC('month', reg_date) :: DATE AS delivr_month,
  COUNT(DISTINCT user_id) AS regs
FROM reg_dates
GROUP BY delivr_month
ORDER BY delivr_month ASC;  


# Monthly active users (MAU)
  
SELECT
  /* Truncate the order date to the nearest month */
  DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
  /* Count the unique user IDs */
  COUNT(DISTINCT user_id) AS mau
FROM orders
GROUP BY delivr_month
/* Order by month */
ORDER BY delivr_month ASC;  


# Registrations running total
  
WITH reg_dates AS (
  SELECT
    user_id,
    MIN(order_date) AS reg_date
  FROM orders
  GROUP BY user_id),

  regs AS (
  SELECT
    DATE_TRUNC('month', reg_date) :: DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS regs
  FROM reg_dates
  GROUP BY delivr_month)

SELECT
  /* Calculate the registrations running total by month */
  delivr_month,
  SUM(regs) OVER(ORDER BY delivr_month ASC) AS regs_rt
FROM regs
/* Order by month in ascending order */
ORDER BY delivr_month ASC;  



# MAU Monitor (I)
-- Return a table of MAUs and the previous month's MAU for every month

WITH mau AS (
  SELECT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS mau
  FROM orders
  GROUP BY delivr_month)

SELECT
  /* Select the month and the MAU */
  delivr_month,
  mau,
  COALESCE(
    LAG(mau) OVER (ORDER BY delivr_month ASC),
  0) AS last_mau
FROM mau
/* Order by month in ascending order */
ORDER BY delivr_month ASC;  


# MAU Monitor (II)
-- Return a table of months and the deltas of each month's current and previous MAUS. If the delta is negative, less users were active in the current month than in the previous month, which triggers the monitor to raise a red flag so the Product team can investigate.
  
WITH mau AS (
  SELECT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS mau
  FROM orders
  GROUP BY delivr_month),

  mau_with_lag AS (
  SELECT
    delivr_month,
    mau,
    /* Fetch the previous month's MAU */
    COALESCE(
      LAG(mau) OVER (ORDER BY delivr_month ASC),
    0) AS last_mau
  FROM mau)

SELECT
  /* Calculate each month's delta of MAUs */
  delivr_month,
  mau - last_mau AS mau_delta
FROM mau_with_lag
/* Order by month in ascending order */
ORDER BY delivr_month ASC;  


# MAU Monitor (III)
-- Return a table of months and each month's MoM MAU growth rate to finalize the MAU monitor. With month-on-month (MoM) MAU growth rate over a raw delta of MAUs, the MAU monitor can have more complex triggers, like raising a yellow flag if the growth rate is -2% and a red flag if the growth rate is -5%.
  
WITH mau AS (
  SELECT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS mau
  FROM orders
  GROUP BY delivr_month),

  mau_with_lag AS (
  SELECT
    delivr_month,
    mau,
    GREATEST(
      LAG(mau) OVER (ORDER BY delivr_month ASC),
    1) AS last_mau
  FROM mau)

SELECT
  /* Calculate the MoM MAU growth rates */
  delivr_month,
  ROUND(
  (mau - last_mau) :: NUMERIC / last_mau,
  2) AS growth
FROM mau_with_lag
/* Order by month in ascending order */
ORDER BY delivr_month ASC;  


# Order growth rate
-- Return table of MoM order growth rates

WITH orders AS (
  SELECT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    /*  Count the unique order IDs */
    COUNT(DISTINCT order_id) AS orders
  FROM orders
  GROUP BY delivr_month),

  orders_with_lag AS (
  SELECT
    delivr_month,
    /* Fetch each month's current and previous orders */
    orders,
    COALESCE(
      LAG(orders) OVER (ORDER BY delivr_month ASC),
    1) AS last_orders
  FROM orders)

SELECT
  delivr_month,
  /* Calculate the MoM order growth rate */
  ROUND(
    (orders - last_orders) :: NUMERIC / last_orders,
  2) AS growth
FROM orders_with_lag
ORDER BY delivr_month ASC;  


# Retention rate
-- Return MoM retention rates to highlight high user loyalty
  
WITH user_monthly_activity AS (
  SELECT DISTINCT
    DATE_TRUNC('month', order_date) :: DATE AS delivr_month,
    user_id
  FROM orders)

SELECT
  /* Calculate the MoM retention rates */
  previous.delivr_month,
  ROUND(
    COUNT(DISTINCT current.user_id) :: NUMERIC /
    GREATEST(COUNT(DISTINCT previous.user_id), 1),
  2) AS retention_rate
FROM user_monthly_activity AS previous
LEFT JOIN user_monthly_activity AS current
/* Fill in the user and month join conditions */
ON previous.user_id = current.user_id
AND previous.delivr_month = (current.delivr_month - INTERVAL '1 month')
GROUP BY previous.delivr_month
ORDER BY previous.delivr_month ASC;  

