# Calculate Average Revenue per User (ARPU) per week - I
WITH kpi AS (
  SELECT
    -- Select the week, revenue, and count of users
    DATE_TRUNC('week', order_date) :: DATE AS delivr_week,
    SUM(meal_price * order_quantity) AS revenue,
    COUNT(DISTINCT user_id) AS users
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY delivr_week)

SELECT
  delivr_week,
  -- Calculate ARPU
  ROUND(
    revenue :: NUMERIC / GREATEST(users, 1),
  2) AS arpu
FROM kpi
-- Order by week in ascending order
ORDER BY delivr_week ASC;

/* this method is useful because you can easily change it to calculate ARPU by month. If you include a month column in the CTE and group by it, you can select it in the final query and calculate ARPU per month to track its change over time. If a locations table is available, grouping by user location would also help in determining which cities, states, and countries are the most profitable per user. */


# Calculate Average Revenue per User (ARPU) - II
WITH kpi AS (
  SELECT
    -- Select the user ID and calculate revenue
    user_id,
    SUM(m.meal_price * o.order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id)
-- Calculate ARPU
SELECT ROUND(AVG(revenue) :: NUMERIC , 2) AS arpu
FROM kpi;  

/* this method is to calculate each user’s revenue by grouping by user ID. After storing all user IDs and each user ID’s revenue in a CTE, average the revenue column to calculate ARPU. It’s not as straightforward to calculate ARPU by month or location this way, but you can use it to explore the distribution of revenues by user, since you have each user’s revenue. This method is more flexible than the first method. */


# Return the average orders per user
WITH kpi AS (
  SELECT
    -- Select the count of orders and users
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT user_id) AS users
  FROM orders)

SELECT
  -- Calculate the average orders per user
  ROUND(
    orders :: NUMERIC / GREATEST(users, 1),
  2) AS arpu
FROM kpi;  



# Histograms of revenue
-- useful to see whether the distribution is U-shaped or normal to see how best to categorize users by the revenue they generate
  
WITH user_revenues AS (
  SELECT
    -- Select the user ID and revenue
    user_id,
    SUM(meal_price * order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id)

SELECT
  -- Return the frequency table of revenues by user
  ROUND(revenue :: NUMERIC, -2) AS revenue_100,
  COUNT(DISTINCT user_id) AS users
FROM user_revenues
GROUP BY revenue_100
ORDER BY revenue_100 ASC;  

/* revenues are usually decimal values, so it’s very unlikely that two or more users generated the exact same revenue. This clutters the histogram. That's why revenue is rounded here. */


# Histograms of orders
-- useful to see if it matches the shape of the histogram of revenues

WITH user_orders AS (
  SELECT
    user_id,
    COUNT(DISTINCT order_id) AS orders
  FROM orders
  GROUP BY user_id)

SELECT
  -- Return the frequency table of orders by user
  orders,
  COUNT(DISTINCT user_id) AS users
FROM user_orders
GROUP BY orders
ORDER BY orders ASC;  



# Bucketing users by revenue
-- split users into low, mid, and high-revenue brackets, and return the count of users in each group
  
WITH user_revenues AS (
  SELECT
    -- Select the user IDs and the revenues they generate
    user_id,
    SUM(meal_price * order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id)

SELECT
  -- Fill in the bucketing conditions
  CASE
    WHEN revenue < 150 THEN 'Low-revenue users'
    WHEN revenue < 300 THEN 'Mid-revenue users'
    ELSE 'High-revenue users'
  END AS revenue_group,
  COUNT(DISTINCT user_id) AS users
FROM user_revenues
GROUP BY revenue_group;  


# Bucketing users by orders
-- return a table of each order group and how many users are in it
  
WITH user_orders AS (
  SELECT
    user_id,
    COUNT(DISTINCT order_id) AS orders
  FROM orders
  GROUP BY user_id)

SELECT
  -- Write the conditions for the three buckets
  CASE
    WHEN orders < 8 THEN 'Low-orders users'
    WHEN orders < 15 THEN 'Mid-orders users'
    ELSE 'High-orders users'
  END AS order_group,
  -- Count the distinct users in each bucket
  COUNT(DISTINCT user_id) AS users
FROM user_orders
GROUP BY order_group;  



# Revenue quartiles
-- Return the first, second, and third revenue quartiles. Also, find the average to see wehich direction the data is skewed

WITH user_revenues AS (
  -- Select the user IDs and their revenues
  SELECT
    user_id,
    SUM(meal_price * order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id)

SELECT
  -- Calculate the first, second, and third quartile
  ROUND(
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue ASC) :: NUMERIC,
  2) AS revenue_p25,
  ROUND(
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue ASC) :: NUMERIC,
  2) AS revenue_p50,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue ASC) :: NUMERIC,
  2) AS revenue_p75,
  -- Calculate the average
  ROUND(AVG(revenue) :: NUMERIC, 2) AS avg_revenue
FROM user_revenues;  


# Interquartile range
-- users outside the revenue IQR are outliers; return the count of users in the revenue IQR

WITH user_revenues AS (
  SELECT
    -- Select user_id and calculate revenue by user 
    user_id,
    SUM(m.meal_price * o.order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id),

  quartiles AS (
  SELECT
    -- Calculate the first and third revenue quartiles
    ROUND(
      PERCENTILE_CONT(0.25) WITHIN GROUP
      (ORDER BY revenue ASC) :: NUMERIC,
    2) AS revenue_p25,
    ROUND(
      PERCENTILE_CONT(0.75) WITHIN GROUP
      (ORDER BY revenue ASC) :: NUMERIC,
    2) AS revenue_p75
  FROM user_revenues)

SELECT
  -- Count the number of users in the IQR
  COUNT(DISTINCT user_id) AS users
FROM user_revenues
CROSS JOIN quartiles
-- Only keep users with revenues in the IQR range
WHERE revenue :: NUMERIC >= revenue_p25
  AND revenue :: NUMERIC <= revenue_p75;

