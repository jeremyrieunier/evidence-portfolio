WITH orders AS (
  SELECT
    DISTINCT order_id,
    order_dt,
    address_to_country,
    shipment_carrier,
    strftime(order_dt, '%Y-%m') AS order_month
  FROM ecommerce.orders
  WHERE (fulfilled_dt > order_dt OR fulfilled_dt IS NULL)
    AND order_dt > merchant_registered_dt
)

SELECT
    shipment_carrier,
    COUNT(DISTINCT order_id) AS total_orders,
    CAST(COUNT(DISTINCT order_id) AS FLOAT) / SUM(COUNT(DISTINCT order_id)) OVER() AS percent_total_orders,
    COUNT(DISTINCT address_to_country) AS countries_served
FROM orders
WHERE shipment_carrier IS NOT NULL
GROUP BY shipment_carrier
ORDER BY total_orders DESC
LIMIT 2;