WITH orders AS (
  SELECT
    DISTINCT order_id,
    merchant_id,
    total_cost,
    merchant_registered_dt,
    address_to_country,
    sales_channel_type_id,
    merchant_registered_dt,
    sub_is_active_flag,
    sub_plan
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

successful_merchants AS (
  SELECT 
    merchant_id,
    total_revenue,
    CASE WHEN total_revenue >= 1323  THEN 'Top 15%' ELSE 'Others' END AS merchant_tier
  FROM merchant_revenue
),

merchant_metrics AS (
  SELECT 
    s.merchant_id,
    s.merchant_tier,
    MAX(CASE WHEN o.sub_is_active_flag = 1 THEN 1 ELSE 0 END) as has_active_subscription,


    COUNT(DISTINCT o.order_id) / 6.0 as avg_monthly_orders,
    COUNT(DISTINCT o.address_to_country) as countries_served,
    COUNT(DISTINCT o.sales_channel_type_id) as sales_channel_count,
    COUNT(DISTINCT l.product_type) as product_types_count,
    COUNT(DISTINCT l.print_provider_id) as print_providers_count,
    AVG(o.total_cost) as avg_order_value,
    SUM(l.quantity) / COUNT(DISTINCT o.order_id) as avg_items_per_order,
  FROM orders o
  JOIN successful_merchants s
    ON o.merchant_id = s.merchant_id
  JOIN ecommerce.line_items l 
    ON o.order_id = l.order_id
  GROUP BY s.merchant_id, s.merchant_tier
)

SELECT -- Duckdb
 unnest([
   'merchant_count',
   'avg_monthly_orders', 
   'avg_countries_served',
   'avg_sales_channels',
   'avg_product_types',
   'avg_print_providers',
   'avg_order_value',
   'avg_items_per_order'
 ]) AS metric,
 unnest([
   COUNT(CASE WHEN merchant_tier = 'Top 15%' THEN 1 END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN avg_monthly_orders END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN countries_served END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN sales_channel_count END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN product_types_count END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN print_providers_count END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN avg_order_value END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN avg_items_per_order END)
 ]) AS top_15_percent,
 unnest([
   COUNT(CASE WHEN merchant_tier = 'Others' THEN 1 END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_monthly_orders END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN countries_served END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN sales_channel_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN product_types_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN print_providers_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_order_value END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_items_per_order END)
 ]) AS others,
 (unnest([
   COUNT(CASE WHEN merchant_tier = 'Top 15%' THEN 1 END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN avg_monthly_orders END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN countries_served END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN sales_channel_count END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN product_types_count END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN print_providers_count END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN avg_order_value END),
   AVG(CASE WHEN merchant_tier = 'Top 15%' THEN avg_items_per_order END)
 ]) - unnest([
   COUNT(CASE WHEN merchant_tier = 'Others' THEN 1 END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_monthly_orders END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN countries_served END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN sales_channel_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN product_types_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN print_providers_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_order_value END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_items_per_order END)
 ])) / NULLIF(unnest([
   COUNT(CASE WHEN merchant_tier = 'Others' THEN 1 END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_monthly_orders END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN countries_served END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN sales_channel_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN product_types_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN print_providers_count END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_order_value END),
   AVG(CASE WHEN merchant_tier = 'Others' THEN avg_items_per_order END)
 ]), 0) AS difference
FROM merchant_metrics;