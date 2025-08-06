---
title: SQL Exercices
queries: 
    - orders_month: ecommerce/exercises/orders_month.sql
    - merchants_sales: ecommerce/exercises/merchants_sales.sql
    - orders_rank: ecommerce/exercises/orders_rank.sql
    - print_providers_table: ecommerce/exercises/print_providers_table.sql
---

# SQL query returning total sales, orders, and count of merchants by month

```sql
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
  COUNT(DISTINCT merchant_id) AS total_merchants
FROM orders
GROUP BY order_month
ORDER BY order_month;
```

<DataTable data={orders_month}/>

---

# SQL query returning merchants total sales, product count, and order count ordered by order count for merchants with more than 5 orders

```sql
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
  COALESCE(pm.products_sold, 0) AS products_sold
FROM merchant_order_metrics om
LEFT JOIN merchant_product_metrics pm
  ON om.merchant_id = pm.merchant_id
ORDER BY om.order_count DESC;
```

<DataTable data={merchants_sales}/>

---

# SQL query returning all ORDER_IDs with the time the merchant has been active at the time of the order, the rank of the merchant by order count for the previous month, and the merchant's primary sales channel for the previous month

```sql
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
```

<DataTable data={orders_rank}/>

---

# SQL statement to create a table containing print providers with average production time, reprint percent, last order timestamp, and primary shipping carrier

```sql
CREATE TABLE print_provider_metrics AS
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
```

<DataTable data={print_providers_table}/>
