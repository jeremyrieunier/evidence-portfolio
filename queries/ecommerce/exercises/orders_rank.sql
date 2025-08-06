WITH orders AS (
  SELECT
    DISTINCT order_id,
    merchant_id,
    order_dt,
    sales_channel_type_id,
    merchant_registered_dt,
  FROM ecommerce.orders
  WHERE (fulfilled_dt > order_dt OR fulfilled_dt IS NULL)
    AND order_dt > merchant_registered_dt
),

merchants_monthly_metrics AS (
  SELECT
    merchant_id,
    strftime(order_dt, '%Y-%m') AS activity_month,
    COUNT(DISTINCT order_id) AS monthly_orders
  FROM orders
  GROUP BY merchant_id, activity_month
),

merchants_monthly_ranks AS (
  SELECT
    merchant_id,
    activity_month,
    monthly_orders,
    DENSE_RANK() OVER(PARTITION BY activity_month ORDER BY monthly_orders DESC) AS month_rank
  FROM merchants_monthly_metrics
),

primary_channel AS (
  SELECT
    merchant_id,
    strftime(order_dt, '%Y-%m') AS activity_month,
    sales_channel_type_id,
    COUNT(DISTINCT order_id) AS monthly_orders,
  FROM orders
  GROUP BY merchant_id, activity_month, sales_channel_type_id
  QUALIFY ROW_NUMBER() OVER (PARTITION BY merchant_id, activity_month ORDER BY monthly_orders DESC, sales_channel_type_id ASC) = 1
),

orders_lookups AS (
  SELECT
    order_id,
    merchant_id,
    order_dt,
    strftime(order_dt, '%Y-%m') AS activity_month,
    DATE_DIFF('DAY', merchant_registered_dt, order_dt) AS merchant_days_active,
    strftime(DATE_TRUNC('MONTH', order_dt - INTERVAL 1 MONTH), '%Y-%m') AS previous_month
  FROM orders
)

SELECT
  o.order_id,
  o.merchant_id,
  o.merchant_days_active,
  COALESCE(r.month_rank, NULL) AS previous_month_rank,
  COALESCE(c.sales_channel_type_id, NULL) AS previous_month_primary_channel,
  o.previous_month AS reference_month,
  r.monthly_orders
FROM orders_lookups o
LEFT JOIN merchants_monthly_ranks r
  ON o.merchant_id = r.merchant_id
  AND r.activity_month = o.previous_month
LEFT JOIN primary_channel c
  ON o.merchant_id = c.merchant_id
  AND c.activity_month = o.previous_month
ORDER BY o.order_dt, order_id;