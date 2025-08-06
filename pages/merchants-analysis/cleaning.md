---
title: Data Review & Cleaning
hide_title: true
---

# Data Review & Cleaning Summary
- `ORDER_ID` not unique (1,091 duplicates)
- Extreme merchant concentration: 87% have  less than 10 orders
- 5,229 records with date logic violations.

## Dataset Overview

```sql orders_row_count
SELECT COUNT(*)
FROM ecommerce.orders
```
```sql line_items_row_count
SELECT COUNT(*)
FROM ecommerce.line_items
```

- Orders dataset: <Value data={orders_row_count} /> records
- Line items dataset: <Value data={line_items_row_count} /> records

## Data Quality Issues Identified
### Order ID Not Unique

```sql duplicate_orders
WITH duplicate_orders AS (
  SELECT
    order_id,
    COUNT(*) AS count
  FROM ecommerce.orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
)
SELECT
  COUNT(*)
FROM duplicate_orders 
```

- <Value data={duplicate_orders} /> orders representing separate legitimate transactions
- Different timestamps, addresses, costs - not data entry errors
- Solution: Use `DISTINCT` on `order_id` field for analysis while preserving underlying data

<Details title="SQL query used">

```sql
WITH duplicate_orders AS (
  SELECT
    order_id,
    COUNT(*) AS count
  FROM ecommerce.orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
)
SELECT
  COUNT(*)
FROM duplicate_orders 
```

</Details>

## Date Logic Violations
```sql date_logic
SELECT COUNT(*)
FROM ecommerce.orders
WHERE fulfilled_dt < order_dt
```
```sql merchant_registration
SELECT COUNT(*)
FROM ecommerce.orders
WHERE fulfilled_dt < merchant_registered_dt OR order_dt < merchant_registered_dt
```
- <Value data={date_logic} /> orders with fulfilled date before order date
- <Value data={merchant_registration} /> orders with registration issues
- Solution: Retain with appropriate filtering in analysis queries

## Data Integrity
```sql null_checks
SELECT
  COUNT(*) - COUNT(order_id) AS null_order_ids,
  COUNT(*) - COUNT(merchant_id) AS null_merchant_ids,
  COUNT(*) - COUNT(shop_id) AS null_shop_ids,
  COUNT(*) - COUNT(order_dt) AS null_order_dates,
FROM ecommerce.orders
```

<DataTable data={null_checks}/>

- Zero `null` values in primary keys (`order_id`, `merchant_id`, `shop_id`, `order_dt`)
- 1 order without line items (ORDER_ID: 719886.143) - kept as non-impactful
- No orphaned line items

<Details title="SQL query used">

```sql
SELECT
  COUNT(*) - COUNT(order_id) AS null_order_ids,
  COUNT(*) - COUNT(merchant_id) AS null_merchant_ids,
  COUNT(*) - COUNT(shop_id) AS null_shop_ids,
  COUNT(*) - COUNT(order_dt) AS null_order_dates,
FROM ecommerce.orders
```

</Details>


## Merchants Distribution: Extreme Concentration

```sql merchants_distribution
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
    END as order_bucket,
  FROM merchant_orders
)

SELECT
  order_bucket,
  COUNT(merchant_id) AS merchant_count,
  SUM(total_revenue) AS merchant_revenue,
  COUNT(*) / SUM(COUNT(*)) OVER() AS percent_of_merchants
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
```

87% of merchants have less than 10 orders over 6 months. Classic marketplace power-user distribution requiring segmented analysis approach:

<DataTable data={merchants_distribution} >
  <Column id=order_bucket/> 
	<Column id=merchant_count/> 
  <Column id=merchant_revenue fmt=usd0 contentType=bar /> 
	<Column id=percent_of_merchants fmt=pct contentType=bar /> 
</DataTable>

<Details title="SQL query used">

```sql
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
    END as order_bucket,
  FROM merchant_orders
)

SELECT
  order_bucket,
  COUNT(merchant_id) AS merchant_count,
  SUM(total_revenue) AS merchant_revenue,
  COUNT(*) / SUM(COUNT(*)) OVER() AS percent_of_merchants
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
```

</Details>