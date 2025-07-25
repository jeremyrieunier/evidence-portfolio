---
title: Outbound Campaign ROI Analysis
queries:
    - pipeline_value_company: outbound/pipeline_value_company.sql
    - pipeline_win_rate: outbound/pipeline_win_rate.sql
    - arr_value_company: outbound/arr_value_company.sql
    - icp_targeting: outbound/icp_targeting.sql
    - matrix: outbound/matrix.sql
---

# Business Problem
A growing e-commerce SaaS platform serving Shopify merchants needed to evaluate the effectiveness and scalability of their outbound marketing campaigns across different market segments.

With 16 campaigns targeting various customer segments and a goal to scale from $3M to $10M ARR, the company required data-driven insights to:

- Assess current outbound campaign performance and identify top performers
- Estimate revenue potential from scaling successful approaches to the total addressable market - (127k Shopify brands with >$1M GMV)
- Compare outbound effectiveness against other acquisition channels (inbound, paid ads)
- Develop strategic recommendations for optimizing campaign ROI and resource allocation

# Key Business Questions
- Campaign Effectiveness: Which outbound campaigns deliver the highest ROI and should be prioritized?
- Market Opportunity: What's the potential ARR from scaling outbound efforts to the entire TAM?
- Channel Strategy: How does outbound compare to inbound and paid acquisition channels for reaching $10M ARR?
- Growth Optimization: What are the key bottlenecks and optimization opportunities?

# Campaign Performance Analysis
The growth team at Polar is responsible for lead generation, with the sales team handling conversion of these opportunities into customers. Thus, the goals of these outbound campaigns are:

- Generate qualified pipeline opportunities for the sales team to work on
- Engage ICP companies with relevant messaging

## Primary KPI: Pipeline Value per Company Touched
Given these goals, the ideal Top KPI for the outbound campaigns is Pipeline Value per Company Touched because it:

- Directly measures how efficiently outbound efforts generate pipeline value
- Aligns with the growth team's primary goal of creating opportunities for the sales team while keeping it accountable
- Accounts for both the quality and quantity of outreach

This metric is calculated as follows:

> Pipeline Value Created / Companies Touched

<DataTable data={pipeline_value_company} wrapTitles=true totalRow=true>
  <Column id=campaign />
  <Column id=pipeline_value_created fmt=usd />
  <Column id=companies_touched />
  <Column id=pipeline_value_per_company_touched fmt=usd contentType=bar totalAgg="average of $8.7"/>
</DataTable>

## Supporting Metrics
### Pipeline Revenue Win Rate
While the growth team does not own this metric, it measures how effectively the sales team converts pipeline opportunities into actual revenue. It highlights alignment between growth and sales teams and identifies which types of opportunities close at a higher rate.

This metric is calculated as follows:
> ARR Value Created / Pipeline Value Created

<DataTable data={pipeline_win_rate} wrapTitles=true totalRow=true>
  <Column id=campaign />
  <Column id=pipeline_value_created fmt=usd0 />
  <Column id=arr_value_created fmt=usd0 />
  <Column id=pipeline_revenue_win_rate totalAgg="average of 53.30%" fmt=pct />
</DataTable>

### ARR Value per Company Touched
This metric shows the complete business impact of outbound efforts, capturing both pipeline generation efficiency and sales conversion effectiveness.

This metric is calculated as follows:
> ARR Value Created / Companies Touched