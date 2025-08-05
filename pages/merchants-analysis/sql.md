---
title: SQL Exercices
queries: 
    - orders_month: ecommerce/exercises/orders_month.sql
    - merchants_sales: ecommerce/exercises/merchants_sales.sql
    - orders_rank: ecommerce/exercises/orders_rank.sql
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
  (SUM(total_cost) + SUM(total_shipping)) / COUNT(order_id) AS aov,
  COUNT(DISTINCT merchant_id) AS total_merchants
FROM orders
GROUP BY order_month
ORDER BY order_month 
```

<DataTable data={orders_month}/>

# SQL query returning merchants total sales, product count, and order count ordered by order count for merchants with more than 5 orders

```sql
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
ORDER BY order_count DESC
```

<DataTable data={merchants_sales}/>


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
ORDER BY o.order_dt, order_id
```

<DataTable data={orders_rank}/>


