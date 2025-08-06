WITH orders AS (
  SELECT
    DISTINCT order_id,
    merchant_id,
    total_cost
  FROM ecommerce.orders
  WHERE (fulfilled_dt > order_dt OR fulfilled_dt IS NULL)
    AND order_dt > merchant_registered_dt
),

merchant_revenue AS (
  SELECT 
    merchant_id,
    SUM(total_cost) AS total_revenue,
    COUNT(order_id) AS total_orders
  FROM orders
  GROUP BY merchant_id
  HAVING COUNT(order_id) >= 11

),

merchant_ranked AS (
  SELECT 
    merchant_id,
    total_revenue,
    total_orders,
    NTILE(100) OVER (ORDER BY total_revenue DESC) AS percentile,
    COUNT(*) OVER () AS total_merchants,
    SUM(total_revenue) OVER () AS total_revenue_all
  FROM merchant_revenue
),

percentile_summary AS (
  SELECT 
    percentile,
    SUM(total_revenue) AS bucket_revenue,
    MIN(total_revenue) AS min_revenue,
    MAX(total_revenue) AS max_revenue,
    AVG(total_revenue) AS avg_revenue,
    MAX(total_revenue_all) AS total_revenue_all
  FROM merchant_ranked
  GROUP BY percentile
)

SELECT 
  percentile,
  SUM(bucket_revenue) OVER (ORDER BY percentile) AS cumulative_revenue,
  CAST(SUM(bucket_revenue) OVER (ORDER BY percentile) AS FLOAT) / total_revenue_all AS cumulative_revenue_percent,
  min_revenue,
  max_revenue,
  avg_revenue
FROM percentile_summary
ORDER BY percentile;