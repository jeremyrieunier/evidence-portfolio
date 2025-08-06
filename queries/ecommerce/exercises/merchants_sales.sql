WITH qualifying_merchants AS (
  SELECT merchant_id
  FROM ecommerce.orders
  GROUP BY merchant_id
  HAVING COUNT(DISTINCT order_id) > 5  
),

merchant_order_metrics AS (
  SELECT 
    o.merchant_id,
    SUM(o.total_cost + o.total_shipping) AS total_sales,
    COUNT(o.order_id) AS order_count
  FROM ecommerce.orders o
  INNER JOIN qualifying_merchants m
    ON o.merchant_id = m.merchant_id
  WHERE (o.fulfilled_dt > o.order_dt OR o.fulfilled_dt IS NULL)
    AND o.order_dt > o.merchant_registered_dt
  GROUP BY o.merchant_id
),

merchant_product_metrics AS (
  SELECT 
    o.merchant_id,
    SUM(l.quantity) AS products_sold
  FROM ecommerce.orders o
  INNER JOIN qualifying_merchants m 
    ON o.merchant_id = m.merchant_id
  LEFT JOIN ecommerce.line_items l
    ON o.order_id = l.order_id
  WHERE (o.fulfilled_dt > o.order_dt OR o.fulfilled_dt IS NULL)
    AND o.order_dt > o.merchant_registered_dt
  GROUP BY o.merchant_id
)

SELECT
  om.merchant_id,
  om.total_sales,
  om.order_count,
  pm.products_sold AS products_sold
FROM merchant_order_metrics om
LEFT JOIN merchant_product_metrics pm
  ON om.merchant_id = pm.merchant_id
ORDER BY om.order_count DESC;