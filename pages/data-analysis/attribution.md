---
title: Ecommerce Attribution
---

```sql monthly_orders
with order_events as (
    select *
    from attribution.order_events
),

monthly_orders as (
    select
        store,
        order_month,
        count(distinct order_id) AS order_count,
        round(sum(order_total), 2) AS total_revenue,
        round(sum(order_total) / count(distinct order_id), 2) as avg_order_value
    from order_events
    where row_num = 1
    group by store, order_month 
    order by store, strptime(order_month, '%b %Y')
)

select *
from monthly_orders
```