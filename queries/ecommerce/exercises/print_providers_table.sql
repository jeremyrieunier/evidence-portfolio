WITH orders AS (
  SELECT
    DISTINCT order_id,
    merchant_id,
    order_dt,
    fulfilled_dt,
    shipment_carrier
  FROM ecommerce.orders
  WHERE (fulfilled_dt > order_dt OR fulfilled_dt IS NULL)
    AND order_dt > merchant_registered_dt
),

order_line_enriched AS (
  SELECT
    l.print_provider_id,
    l.reprint_flag,
    o.order_dt,
    o.fulfilled_dt,
    o.shipment_carrier,
    DATE_DIFF('DAY', o.order_dt, o.fulfilled_dt) AS production_days
  FROM ecommerce.line_items l
  INNER JOIN orders o
    ON l.order_id = o.order_id
),

print_provider_aggregates AS (
  SELECT
    print_provider_id,
    AVG(production_days) AS avg_production_time_days,
    COUNT(*) AS total_line_items,
    COUNT(CASE WHEN reprint_flag = 1 THEN 1 END) AS reprint_count,
    MAX(order_dt) AS last_order_timestamp,
    MODE() WITHIN GROUP (ORDER BY shipment_carrier) AS primary_shipping_carrier -- Carrier usage for primary carrier calculation
  FROM order_line_enriched
  GROUP BY print_provider_id
)

SELECT
  print_provider_id,
  ROUND(avg_production_time_days, 2) AS avg_production_time_days,
  ROUND(CAST(reprint_count AS FLOAT) / total_line_items, 4) AS reprint_rate,
  last_order_timestamp,
  COALESCE(primary_shipping_carrier, 'No Carrier Data') AS primary_shipping_carrier
FROM print_provider_aggregates
ORDER BY print_provider_id;