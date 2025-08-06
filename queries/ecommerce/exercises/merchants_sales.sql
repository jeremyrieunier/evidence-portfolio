WITH orders AS (
  SELECT
    DISTINCT order_id,
    merchant_id,
    shop_id,
    order_dt,
    fulfilled_dt,
    total_cost,
    total_shipping,
    strftime(order_dt, '%Y-%m') AS order_month
  FROM ecommerce.orders
  WHERE (fulfilled_dt > order_dt OR fulfilled_dt IS NULL)
    AND order_dt > merchant_registered_dt
),

order_line_summary AS (
  SELECT
    order_id,
    SUM(quantity) AS total_quantity
  FROM ecommerce.line_items
  GROUP BY order_id
)

SELECT
  o.merchant_id,
  SUM(o.total_cost) + SUM(o.total_shipping) AS total_sales,
  COUNT(o.order_id) AS order_count,
  SUM(l.total_quantity) AS products_sold
FROM orders o
LEFT JOIN order_line_summary l
  ON o.order_id = l.order_id
GROUP BY o.merchant_id
HAVING COUNT(o.order_id) > 5
ORDER BY order_count DESC;
