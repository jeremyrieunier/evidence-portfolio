---
title: Retention Analysis
queries:
  - churn: retention/churn.sql
  - churn_service: retention/churn_service.sql
  - churn_region: retention/churn_region.sql
  - nrr: retention/nrr.sql
  - nrr_bu: retention/nrr_bu.sql
  - nrr_region: retention/nrr_region.sql
---

# Business Problem
A leading global workforce management platform experienced concerning retention trends during Q4 2023. The company, serving 13,700+ businesses needed urgent analysis to understand:

- What's driving the dramatic increase in customer churn?
- Which services and regions are most affected by retention challenges?
- How is revenue expansion from existing customers being impacted?
- What external factors correlate with the retention decline?

A leading healthcare technology platform needed to evaluate the impact of their newly launched chat feature that enables direct communication between healthcare providers and patients.

# Data Schema

## customer_monthly_revenue data table
<table class="markdown text-left"><thead class="markdown"><tr class="markdown"><th class="markdown"><strong class="markdown">Column</strong></th> <th class="markdown"><strong class="markdown">Data Type</strong></th> <th class="markdown"><strong class="markdown">Description</strong></th></tr></thead> <tbody class="markdown"><tr class="markdown"><td class="markdown">month</td> <td class="markdown">DATE</td> <td class="markdown">Revenue month</td></tr> <tr class="markdown"><td class="markdown">customer_id</td> <td class="markdown">INT</td> <td class="markdown">Unique customer identifier</td></tr> <tr class="markdown"><td class="markdown">service_id</td> <td class="markdown">INT</td> <td class="markdown">Service identifier</td></tr> <tr class="markdown"><td class="markdown">contracts</td> <td class="markdown">INT</td> <td class="markdown">Active service contracts count</td></tr> <tr class="markdown"><td class="markdown">total_saas_revenue_usd</td> <td class="markdown">FLOAT</td> <td class="markdown">Monthly SaaS revenue per service</td></tr></tbody></table>

## dim_customer data table
<table class="markdown text-left"><thead class="markdown"><tr class="markdown"><th class="markdown"><strong class="markdown">Column</strong></th> <th class="markdown"><strong class="markdown">Data Type</strong></th> <th class="markdown"><strong class="markdown">Description</strong></th></tr></thead> <tbody class="markdown"><tr class="markdown"><td class="markdown">customer_id</td> <td class="markdown">INT</td> <td class="markdown">Primary customer key</td></tr> <tr class="markdown"><td class="markdown">country</td> <td class="markdown">STRING</td> <td class="markdown">Customer country location</td></tr> <tr class="markdown"><td class="markdown">region</td> <td class="markdown">STRING</td> <td class="markdown">Geographic region code</td></tr></tbody></table>

## dim_service data table
<table class="markdown text-left"><thead class="markdown"><tr class="markdown"><th class="markdown"><strong class="markdown">Column</strong></th> <th class="markdown"><strong class="markdown">Data Type</strong></th> <th class="markdown"><strong class="markdown">Description</strong></th></tr></thead> <tbody class="markdown"><tr class="markdown"><td class="markdown">id</td> <td class="markdown">INT</td> <td class="markdown">Service identifier</td></tr> <tr class="markdown"><td class="markdown">name</td> <td class="markdown">STRING</td> <td class="markdown">Service name (IC, EOR, SHD, PR, GP)</td></tr> <tr class="markdown"><td class="markdown">business_unit</td> <td class="markdown">STRING</td> <td class="markdown">Internal business unit assignment</td></tr> <tr class="markdown"><td class="markdown">standard_monthly_fee</td> <td class="markdown">STRING</td> <td class="markdown">Standard pricing per contract</td></tr></tbody></table>

# Executive Summary
Monthly customer churn has doubled from 0.13% to 0.27%, while revenue expansion from existing customers has declined from 102.87% to 100.68%.

This analysis reveals the problem is concentrated in specific services (IC) and regions (AMS and EMEA), pointing to external economic factors rather than company-wide issues.

## Key Insights

### Service-Specific Vulnerability
- Individual Contractor (IC) service drives 93% of all churn
- IC churn rate nearly doubled: 0.33% to 0.63%
- Employer of Record (EOR) maintains perfect 0% churn
- Clear distinction between discretionary vs. essential services

### Geographic Concentration
- 90% of churn concentrated in AMS and EMEA regions
- Both regions converging at ~0.26% churn by December
- APAC and Brazil remain largely unaffected
- Regional economic factors appear to be primary driver

### Revenue Expansion Deterioration
- Net Revenue Retention declined from 102.87% to 100.68%
- Dual pressure: customers leaving AND reducing spend
- Contractor business unit volatile, EOR unit steadily declining
- APAC only region showing accelerating expansion

## Strategic Recommendations
**Immediate Actions**: Implement economic resilience programs including flexible pricing, value demonstration campaigns, and early warning systems for contract reduction patterns.

**Portfolio Strategy**: Accelerate growth in resilient regions (APAC) and services (EOR), while developing retention programs specifically for economic-sensitive segments.

**Market Position**: Reframe contractor services as cost-saving solutions during economic downturns rather than growth investments.

# Monthly Churn Rate Analysis
## Customer monthly churn rate has steadily increased from August to December 2023

<LineChart 
    data={churn}
    x=month
    y=churn_rate
    yFmt=pct2
    chartAreaHeight=300
/>

<DataTable data={churn} >
  <Column id=month />
  <Column id=active_customers_previous_month />
  <Column id=churned_customers />  
  <Column id=churn_rate fmt=pct2 />
</DataTable>

While churn rate remains low (less than 0.3%), the consistent month-over-month increase is concerning. However, strong customer acquisition (From 12K to 13.7K customers) is offsetting churn impact.

<Details title="SQL query used for the monthly churn rate analysis">

```sql
WITH customer_monthly_activity AS (
  SELECT 
    month,
    customer_id,
    SUM(contracts) as total_contracts
  FROM retention.customer_monthly_revenue
  GROUP BY month, customer_id
),

customer_activity_with_lag AS (
  SELECT 
    month,
    customer_id,
    total_contracts,
    CASE WHEN total_contracts > 0 THEN 1 ELSE 0 END as is_active,
    LAG(CASE WHEN total_contracts > 0 THEN 1 ELSE 0 END) 
      OVER (PARTITION BY customer_id ORDER BY month) as was_active_previous_month
  FROM customer_monthly_activity
),

monthly_churn_data AS (
  SELECT 
    month,
    SUM(was_active_previous_month) as active_customers_previous_month,
    SUM(CASE WHEN was_active_previous_month = 1 AND is_active = 0 THEN 1 ELSE 0 END) as churned_customers
  FROM customer_activity_with_lag
  WHERE was_active_previous_month IS NOT NULL 
  GROUP BY month
)

SELECT
  month,
  active_customers_previous_month,
  churned_customers,
  churned_customers / active_customers_previous_month AS churn_rate
FROM monthly_churn_data
ORDER BY month
```

</Details>


# Service-Level Performance Analysis
## Individual Contributor (IC) service represents +93% of total churned customers

```sql total_churn
SELECT
  service_name,
  SUM(churned_customers) AS total_churned_customers,
  ROUND(SUM(churned_customers) / SUM(SUM(churned_customers)) OVER (), 4) AS percentage_of_total
FROM ${churn_service} 
GROUP BY service_name
ORDER BY total_churned_customers DESC
```

<BarChart 
    data={total_churn}
    x=service_name
    y=total_churned_customers
    chartAreaHeight=350
/>

## IC churn rate increased every month except November

```sql ic_churn
SELECT *
FROM ${churn_service}
WHERE service_name = 'IC'
```

<LineChart 
    data={ic_churn}
    x=month
    y=churn_rate
    yFmt=pct2
    chartAreaHeight=300
/>

<DataTable data={ic_churn} >
  <Column id=month />
  <Column id=active_customers_previous_month />
  <Column id=churned_customers />  
  <Column id=churn_rate fmt=pct2 />
</DataTable>

- August to September: +30% increase (0.33% to 0.43%)
- September to October: +28% increase (0.43% to 0.55%)
- November to December: +11% increase (0.57% to 0.63%)

In term of impact:

- Total IC customers churned: 206 over 5 months
- December alone: 52 customers (highest monthly loss)
- Customer base growth: Despite churn, IC customer base grew from 7,885 to 8,251

<Details title="SQL query used for the service-level performance analysis">

```sql
WITH customer_monthly_activity_service AS (
  SELECT
    month,
    customer_id,
    service_id,
    contracts,
    CASE WHEN contracts > 0 THEN 1 ELSE 0 END AS is_active_service
  FROM retention.customer_monthly_revenue
),

customer_activity_service_with_lag AS (
  SELECT 
    month,
    customer_id,
    service_id,
    contracts,
    is_active_service,
    LAG(is_active_service) OVER (PARTITION BY customer_id, service_id ORDER BY month) AS was_active_previous_month
  FROM customer_monthly_activity_service
),

monthly_service_churn_data AS (
 SELECT 
   month,
   service_id,
   SUM(was_active_previous_month) AS active_customers_previous_month,
   SUM(CASE WHEN was_active_previous_month = 1 AND is_active_service = 0 THEN 1 ELSE 0 END) AS churned_customers
 FROM customer_activity_service_with_lag 
 WHERE was_active_previous_month IS NOT NULL 
  AND month >= '2023-08-01'
 GROUP BY month, service_id
)

SELECT
  m.month,
  m.service_id,
  s.name AS service_name,
  m.active_customers_previous_month,
  m.churned_customers,
  ROUND(m.churned_customers / m.active_customers_previous_month, 4) AS churn_rate
FROM monthly_service_churn_data m
LEFT JOIN retention.dim_service s
  ON m.service_id = s.id
ORDER BY month, service_id
```

</Details>

# Regional Performance Segmentation

```sql region_churn
SELECT
  region,
  SUM(churned_customers) AS total_churned_customers,
  ROUND(SUM(churned_customers) / SUM(SUM(churned_customers)) OVER (), 4) AS percentage_of_total
FROM ${churn_region}
WHERE region IS NOT NULL
GROUP BY region
ORDER BY total_churned_customers DESC
```

## 90% of customer churn occurs in the AMS and EMEA regions

<BarChart 
    data={region_churn}
    x=region
    y=total_churned_customers
    chartAreaHeight=350
/>

- AMS region dominates churn impact with 74 total churned customers (58% of all churn)
- EMEA accounts for 41 churned customers (32%)
- Other regions (APAC, BRAZIL) show minimal churn impact

```sql ams_emea_churn
SELECT *
FROM ${churn_region} 
WHERE region IN ('AMS', 'EMEA')
```

## Both AMS and EMEA show concerning deterioration of the churn rate

<LineChart 
    data={ams_emea_churn}
    x=month
    y=churn_rate
    series=region
    yFmt=pct2
    chartAreaHeight=300
/>

The convergence of both regions suggests common external factors (economic conditions, competitive pressure) affecting Western markets simultaneously, while other regions remain largely unaffected.

<Details title="SQL query used for the region-level churn analysis">

```sql
WITH customer_monthly_activity AS (
  SELECT
    month,
    customer_id,
    SUM(contracts) AS total_contracts
  FROM retention.customer_monthly_revenue
  GROUP BY month, customer_id
),

customer_activity_service_with_lag AS (
  SELECT 
    month,
    customer_id,
    total_contracts,
    CASE WHEN total_contracts > 0 THEN 1 ELSE 0 END as is_active,
    LAG(CASE WHEN total_contracts > 0 THEN 1 ELSE 0 END) 
      OVER (PARTITION BY customer_id ORDER BY month) as was_active_previous_month
  FROM customer_monthly_activity
),

monthly_churn_data AS (
  SELECT 
    month,
    customer_id,
    was_active_previous_month,
    CASE WHEN was_active_previous_month = 1 AND is_active = 0 THEN 1 ELSE 0 END as churned
  FROM customer_activity_service_with_lag 
  WHERE was_active_previous_month IS NOT NULL 
    AND month >= '2023-08-01'
)

SELECT
  m.month,
  c.region,
  SUM(m.was_active_previous_month) AS active_customers_previous_month,
  SUM(m.churned) AS churned_customers,
  SUM(m.churned) / SUM(m.was_active_previous_month) AS churn_rate
FROM monthly_churn_data m
LEFT JOIN retention.dim_customer c
  ON m.customer_id = c.customer_id
GROUP BY m.month, c.region
HAVING active_customers_previous_month > 0
ORDER BY m.month, c.region
```

</Details>

# Net Revenue Retention Analysis
## Overall NRR 
### NRR is on a concerning downward trend throughout Q4 2023

<LineChart 
    data={nrr}
    x=month
    y=nrr
    yFmt=pct2
    yMax=1.04
    yMin=0.96
    chartAreaHeight=300
/>


<Details title="SQL query used for the overall NRR analysis">

```sql
WITH monthly_revenue AS (
  SELECT
    month,
    customer_id,
    SUM(total_saas_revenue_usd) AS total_revenue
  FROM retention.customer_monthly_revenue
  GROUP BY month, customer_id
),

monthly_revenue_previous AS (
  SELECT
    month,
    customer_id,
    total_revenue,
    LAG(total_revenue) OVER (PARTITION BY customer_id ORDER BY month) AS previous_month_revenue
  FROM monthly_revenue
),

active_customers AS (
  SELECT
    month,
    customer_id,
    total_revenue AS current_month_revenue,
    previous_month_revenue
  FROM monthly_revenue_previous
  WHERE previous_month_revenue >= 0
    AND previous_month_revenue IS NOT NULL
)

SELECT
  month,
  SUM(previous_month_revenue) AS previous_month_total_revenue,
  SUM(current_month_revenue) AS current_month_total_revenue,
  ROUND(SUM(current_month_revenue) / SUM(previous_month_revenue), 4) AS nrr
FROM active_customers
GROUP BY month
ORDER BY month
```

</Details>

## Business Unit Patterns
### Major BUs show expansion, but with different patterns and downward trends
<LineChart 
    data={nrr_bu}
    x=month
    y=nrr
    yFmt=pct2
    yMax=1.08
    yMin=0.96
    series=business_unit
    chartAreaHeight=300
/>

- The Contractor business unit is volatile. Exceptional August (107%), near-flat September (100.84%), then stabilized around 102.5%:
- On the other hand the EOR business units has a steady decline from 102.40% to 101.57%. It is more predictable but consistently weakening.

<Details title="SQL query used for the Business Unit NRR analysis">

```sql
WITH customers_services_revenue AS (
  SELECT
    month,
    customer_id,
    service_id,
    total_saas_revenue_usd AS current_month_service_revenue,
    LAG(total_saas_revenue_usd) OVER (PARTITION BY customer_id, service_id ORDER BY month) AS previous_month_service_revenue
  FROM retention.customer_monthly_revenue
),

customers_total_revenue AS (
  SELECT 
    month,
    customer_id,
    SUM(current_month_service_revenue) as current_month_total_revenue,
    SUM(previous_month_service_revenue) as previous_month_total_revenue
  FROM customers_services_revenue
  GROUP BY month, customer_id
),

active_customers_services AS (
  SELECT
    csr.month,
    csr.customer_id,
    csr.service_id,
    s.business_unit,
    csr.current_month_service_revenue,
    csr.previous_month_service_revenue
  FROM customers_services_revenue csr
  INNER JOIN customers_total_revenue ctr
    ON csr.customer_id = ctr.customer_id
    AND csr.month = ctr.month
  INNER JOIN retention.dim_service s
    ON csr.service_id = s.id 
  WHERE ctr.previous_month_total_revenue >= 0
    AND ctr.previous_month_total_revenue IS NOT NULL
)

SELECT
  month,
  business_unit,
  SUM(previous_month_service_revenue) AS previous_month_total_revenue,
  SUM(current_month_service_revenue) AS current_month_total_revenue,
  SUM(current_month_service_revenue) /  SUM(previous_month_service_revenue) AS nrr
FROM active_customers_services
GROUP BY month, business_unit
HAVING SUM(previous_month_service_revenue) > 0
ORDER BY month, business_unit
```

</Details>

## Regional NRR Performance
### AMS performances are on the decline with a barely positive expansion

```sql nrr_ams
SELECT *
FROM ${nrr_region}
WHERE region = 'AMS'
```
<LineChart 
    data={nrr_ams}
    x=month
    y=nrr
    yFmt=pct2
    yMax=1.06
    yMin=0.96
    chartAreaHeight=300
/>

### EMEA follow a similar pattern with a gradual decline

```sql nrr_emea
SELECT *
FROM ${nrr_region}
WHERE region = 'EMEA'
```
<LineChart 
    data={nrr_emea}
    x=month
    y=nrr
    yFmt=pct2
    yMax=1.06
    yMin=0.96
    chartAreaHeight=300
/>

### APAC is the only region with accelerating expansion

```sql nrr_apac
SELECT *
FROM ${nrr_region}
WHERE region = 'APAC'
```
<LineChart 
    data={nrr_apac}
    x=month
    y=nrr
    yFmt=pct2
    yMax=1.06
    yMin=0.96
    chartAreaHeight=300
/>

<Details title="SQL query used for the Region NRR analysis">

```sql
WITH customers_services_revenue AS (
  SELECT
    month,
    customer_id,
    service_id,
    total_saas_revenue_usd AS current_month_service_revenue,
    LAG(total_saas_revenue_usd) OVER (PARTITION BY customer_id, service_id ORDER BY month) AS previous_month_service_revenue
  FROM retention.customer_monthly_revenue
),

customers_total_revenue AS (
  SELECT 
    month,
    customer_id,
    SUM(current_month_service_revenue) as current_month_total_revenue,
    SUM(previous_month_service_revenue) as previous_month_total_revenue
  FROM customers_services_revenue
  GROUP BY month, customer_id
),

active_customers_services AS (
  SELECT
    csr.month,
    csr.customer_id,
    csr.service_id,
    c.region,
    csr.current_month_service_revenue,
    csr.previous_month_service_revenue
  FROM customers_services_revenue csr
  INNER JOIN customers_total_revenue ctr
    ON csr.customer_id = ctr.customer_id
    AND csr.month = ctr.month
  LEFT JOIN retention.dim_customer c
    ON csr.customer_id = c.customer_id
  WHERE ctr.previous_month_total_revenue >= 0
    AND ctr.previous_month_total_revenue IS NOT NULL
)

SELECT
  month,
  region,
  SUM(previous_month_service_revenue) AS previous_month_total_revenue,
  SUM(current_month_service_revenue) AS current_month_total_revenue,
  SUM(current_month_service_revenue) /  SUM(previous_month_service_revenue) AS nrr
FROM active_customers_services
WHERE region IS NOT NULL
GROUP BY month, region
HAVING SUM(previous_month_service_revenue) > 0
ORDER BY month, region
```

</Details>