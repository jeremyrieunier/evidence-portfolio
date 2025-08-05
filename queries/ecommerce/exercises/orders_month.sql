WITH orders AS (
  SELECT
    DISTINCT order_id,
    merchant_id,
    order_dt,
    fulfilled_dt,
    total_cost,
    total_shipping,
    strftime(order_dt, '%Y-%m') AS order_month
  FROM ecommerce.orders
  WHERE (fulfilled_dt > order_dt OR fulfilled_dt IS NULL)
    AND order_dt > merchant_registered_dt
)
SELECT
  order_month,
  SUM(total_cost) + SUM(total_shipping) AS total_sales,
  COUNT(order_id) AS total_orders,
  (SUM(total_cost) + SUM(total_shipping)) / COUNT(order_id) AS aov,
  COUNT(DISTINCT merchant_id) AS total_merchants
FROM orders
GROUP BY order_month
ORDER BY order_month 