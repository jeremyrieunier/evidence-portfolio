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
        order_month,
        count(distinct order_id) AS order_count,
        round(sum(order_total), 2) AS total_revenue,
        round(sum(order_total) / count(distinct order_id), 2) as avg_order_value
    from order_events
    where row_num = 1
    group by order_month 
    order by strptime(order_month, '%b %Y')
)

select *
from monthly_orders
```

<BarChart 
    data={monthly_orders} 
    x=order_month 
    y=total_revenue
    yFmt=usd0k
    y2Fmt=usd
    y2=avg_order_value
    y2SeriesType=line
    sort=false
    seriesOrder=order_month
    chartAreaHeight=350
/>

<DataTable data={monthly_orders} totalRow=true >
  <Column id=order_month />
  <Column id=order_count />
  <Column id=total_revenue fmt=usd0 />
  <Column id=avg_order_value totalAgg="average of $225.65" />
</DataTable>