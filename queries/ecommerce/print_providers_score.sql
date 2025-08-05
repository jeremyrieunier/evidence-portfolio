WITH clean_orders AS (
  SELECT
    DISTINCT order_id,
    order_dt,
    fulfilled_dt
  FROM ecommerce.orders
  WHERE (fulfilled_dt > order_dt OR fulfilled_dt IS NULL)
    AND order_dt > merchant_registered_dt
),

line_items AS (
  SELECT 
    l.order_id,
    l.print_provider_id,
    l.quantity,
    l.reprint_flag,
    o.order_dt,
    o.fulfilled_dt
  FROM ecommerce.line_items l
  INNER JOIN clean_orders o
    ON l.order_id = o.order_id
  WHERE l.print_provider_id IS NOT NULL
    AND o.fulfilled_dt IS NOT NULL  -- Only fulfilled orders for production time
),

provider_metrics AS (
  SELECT 
    print_provider_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_items,
    SUM(CASE WHEN reprint_flag = 'TRUE' THEN 1 ELSE 0 END) AS reprint_count,
    SUM(CASE WHEN reprint_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*) AS reprint_rate,
    AVG(DATE_DIFF('DAY', order_dt, fulfilled_dt)) AS avg_production_days,
  FROM line_items
  GROUP BY print_provider_id
  HAVING COUNT(DISTINCT order_id) >= 1000  -- Only providers with meaningful volume
),

-- Score each provider using rank function (higher score = better)
provider_scores AS (
  SELECT 
    print_provider_id,
    total_orders,
    total_items,
    reprint_rate,
    avg_production_days,
    COUNT(*) OVER() AS total_providers,
    RANK() OVER (ORDER BY reprint_rate ASC) AS quality_rank, -- Quality Score: lower reprint rate = better rank 
    RANK() OVER (ORDER BY avg_production_days ASC) AS speed_rank, -- Speed Score: faster production = better rank (1 = best)
    RANK() OVER (ORDER BY total_orders DESC) AS volume_rank -- Volume Score: higher orders = better rank (1 = best)   
  FROM provider_metrics
),

scored_providers AS (
  SELECT 
    print_provider_id,
    total_orders,
    total_items,
    reprint_rate,
    avg_production_days,
    -- Convert ranks to 0-100 scores (best rank = 100, worst rank = 0)
    ROUND(100.0 * (total_providers - quality_rank) / (total_providers - 1), 1) AS quality_score,
    ROUND(100.0 * (total_providers - speed_rank) / (total_providers - 1), 1) AS speed_score,
    ROUND(100.0 * (total_providers - volume_rank) / (total_providers - 1), 1) AS volume_score
  FROM provider_scores
)

SELECT
  print_provider_id,
  total_orders,
  total_items,
  reprint_rate,
  avg_production_days,
  quality_score,
  speed_score, 
  volume_score,
  ROUND((quality_score * 0.30) + (speed_score * 0.20) + (volume_score * 0.50), 1) AS final_score -- Weighted final score 
FROM scored_providers
ORDER BY final_score DESC