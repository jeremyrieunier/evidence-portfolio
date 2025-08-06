WITH orders AS (
  SELECT
    DISTINCT order_id,
    merchant_id,
    total_cost
  FROM ecommerce.orders
  WHERE (fulfilled_dt > order_dt OR fulfilled_dt IS NULL)
    AND order_dt > merchant_registered_dt
),

merchant_orders AS (
  SELECT
    merchant_id,
    COUNT(order_id) AS total_orders,
    SUM(total_cost) AS total_revenue
  FROM orders
  GROUP BY merchant_id
),

orders_distribution AS (
  SELECT 
    merchant_id,
    total_orders,
    total_revenue,
    CASE 
      WHEN total_orders <= 10 THEN '0-10'
      WHEN total_orders <= 25 THEN '11-25'
      WHEN total_orders <= 50 THEN '26-50'
      WHEN total_orders <= 100 THEN '51-100'
      WHEN total_orders <= 500 THEN '101-500'
      ELSE '500+'
    END as order_bucket
  FROM merchant_orders
)

SELECT
  order_bucket,
  COUNT(merchant_id) AS merchant_count,
  SUM(total_revenue) AS merchant_revenue,
  CAST(COUNT(*) AS FLOAT) / SUM(COUNT(*)) OVER() AS percent_of_merchants
FROM orders_distribution
GROUP BY order_bucket
ORDER BY 
  CASE order_bucket
    WHEN '0-10' THEN 1
    WHEN '11-25' THEN 2
    WHEN '26-50' THEN 3
    WHEN '51-100' THEN 4
    WHEN '101-500' THEN 5
    WHEN '500+' THEN 6
  END