---
title: Outbound Campaign Analysis
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

# Executive Summary
Outbound alone can generate $589K-$1.15M additional ARR (8-16% of $7M growth target), requiring a balanced acquisition mix to reach $10M ARR goal.

## Key Ingishts

### Clear Performance Hierarchy Identified
- **Top Performers**: Technology Intent ($27.38 per company) and Ask Platform Lite ($26.23 per company)
- **Scale Leaders**: GA4 (19.3k companies) and Loom (19k companies) campaigns provide volume but lower efficiency
- **Overall Average**: $8.70 pipeline value per company touched with 53.3% pipeline revenue win rate

### Significant Scaling Opportunity Within Current Capacity
- TAM Potential: 127,000 Shopify merchants ($1M-$500M GMV) represent massive untapped market
- Sales Capacity: Current team can handle projected growth (optimistic scenario uses only 27.4% of $4.2M capacity)
- Resource Efficiency: Best campaigns show 10x performance gap vs. underperformers

### Channel Diversification Critical for Growth Goals
- Outbound Ceiling: Even optimistic scaling scenarios fall short of $7M ARR gap
- Multi-Channel Necessity: Inbound content marketing and paid acquisition required to complement outbound precision targeting
- Strategic Balance: Each channel addresses different stages of customer journey and market segments

# Campaign Performance Analysis
The growth team is responsible for lead generation, with the sales team handling conversion of these opportunities into customers. Thus, the goals of these outbound campaigns are:

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

<DataTable data={arr_value_company} wrapTitles=true totalRow=true >
  <Column id=campaign />
  <Column id=arr_value_created fmt=usd0 />
  <Column id=companies_touched  />
  <Column id=arr_per_company_touched fmt=usd totalAgg="average of $4.64" />
</DataTable> 

### ICP Targeting Accuracy
This metric measures how well campaigns focus on the Ideal Customer Profile (ICP).

This metric is calculated as follows:
> (ICP Companies Touched / Companies Touched) × 100%

<DataTable data={icp_targeting} wrapTitles=true totalRow=true >
  <Column id=campaign />
  <Column id=companies_touched />
  <Column id=icp_companies_touched  />
  <Column id=icp_targeting_accuracy fmt=pct totalAgg="average of 49%" />
</DataTable> 

# Top Performing Campaigns
To properly evaluate campaign performance, we must consider both efficiency (Pipeline Value per Company Touched), scale (number of companies touched), and impact (total pipeline generated) using a matrix bubble chart:


<BubbleChart
  data={matrix}
  x=companies_touched
  y=pipeline_value_per_company
  series=campaign
  size=pipeline_value_created
  yFmt=usd
  yMin=0
  chartAreaHeight=350
  xLabelWrap=true
>
  <ReferenceLine
    x=7500
    label="Average Companies Touched"
  />
  <ReferenceLine
    y=8.70
    label="Average Pipeline Value"
  />
  <ReferenceArea 
    xMin=15000 
    xMax=20000 
    yMin=3
    yMax=12 
    label="Optimization Needed" 
    color="warning"
    border={true}
    labelPosition="center"
  />

  <ReferenceArea 
    xMin=7000 
    xMax=13000 
    yMin=12 
    yMax=27 
    label="Best Overall Performers" 
    color="positive"
    border={true}
    labelPosition="center"
  />

  <ReferenceArea 
    xMin=1000 
    xMax=6000 
    yMin=22
    yMax=30
    label="Growth Potential" 
    color="info"
    border={true}
    labelPosition="center"
  />

  <ReferenceArea 
    xMin=0 
    xMax=5000 
    yMin=0
    yMax=15
    label="Reconsider"
    color="negative"
    border={true}
    labelPosition="center"
  />
</BubbleChart>

## Best Overall Performers
These campaigns generate a substantial pipeline with good efficiency, striking a balance between reach and performance.

```best
select
  CAMPAIGN_GROUP as campaign,
  NB_COMPANIES_TOUCHED as companies_touched,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME as pipeline_value_created,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME / NB_COMPANIES_TOUCHED as pipeline_value_per_company,
  NEW_ARR_FROM_OB_ALL_TIME as arr_value_created,
  NB_CUSTOMERS_FROM_OB_ALL_TIME as accounts_acquired,
  NEW_ARR_FROM_OB_ALL_TIME / NB_CUSTOMERS_FROM_OB_ALL_TIME as avg_deal_size
from outbound.campaigns
where campaign in ('GPT V3 - CAPI', 'Klaviyo flows enrich')
order by companies_touched desc
```
<DataTable data={best}/>

Action Plan:
- Conduct segmentation analysis to the highest-performing subgroups
- Optimize messaging and improve efficiency
- Maintain current scale while working to push efficiency metrics above $25 per company


## High Efficiency, Low Scale (Growth Potential)
These campaigns show promising efficiency but need expansion.

```growth
select
  CAMPAIGN_GROUP as campaign,
  NB_COMPANIES_TOUCHED as companies_touched,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME as pipeline_value_created,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME / NB_COMPANIES_TOUCHED as pipeline_value_per_company,
  NEW_ARR_FROM_OB_ALL_TIME as arr_value_created,
  NB_CUSTOMERS_FROM_OB_ALL_TIME as accounts_acquired,
  NEW_ARR_FROM_OB_ALL_TIME / NB_CUSTOMERS_FROM_OB_ALL_TIME as avg_deal_size
from outbound.campaigns
where campaign in ('Technology intent', 'Ask Polar Lite')
order by companies_touched desc
```
<DataTable data={growth}/>

Action Plan:
- Scale up these campaigns to reach more companies while monitoring efficiency metrics
- Preserve the targeting precision and messaging quality
- Consider developing similar campaigns with high-quality messaging

## Low Efficiency, High Scale (Optimization Needed)
These campaigns reach a significant number of companies but underperform in generating pipeline value per company touched.

```optimization
select
  CAMPAIGN_GROUP as campaign,
  NB_COMPANIES_TOUCHED as companies_touched,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME as pipeline_value_created,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME / NB_COMPANIES_TOUCHED as pipeline_value_per_company,
  NEW_ARR_FROM_OB_ALL_TIME as arr_value_created,
  NB_CUSTOMERS_FROM_OB_ALL_TIME as accounts_acquired,
  NEW_ARR_FROM_OB_ALL_TIME / NB_CUSTOMERS_FROM_OB_ALL_TIME as avg_deal_size
from outbound.campaigns
where campaign in ('GA4', 'Loom')
order by companies_touched desc
```
<DataTable data={optimization}/>

Action plan:
- Improve messaging or targeting to increase efficiency
- Develop segment-specific messaging based on industry and company size

## Low Efficiency, Low Scale (Reconsider)
These campaigns underperform on both critical dimensions, indicating fundamental issues.

```reconsider
select
  CAMPAIGN_GROUP as campaign,
  NB_COMPANIES_TOUCHED as companies_touched,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME as pipeline_value_created,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME / NB_COMPANIES_TOUCHED as pipeline_value_per_company,
  NEW_ARR_FROM_OB_ALL_TIME as arr_value_created,
  NB_CUSTOMERS_FROM_OB_ALL_TIME as accounts_acquired,
  NEW_ARR_FROM_OB_ALL_TIME / NB_CUSTOMERS_FROM_OB_ALL_TIME as avg_deal_size
from outbound.campaigns
where campaign in ('Fashion / Multiple Products', 'GPT V4 (GPT-4o)', 'Creative Studio', 'GPT V3 - French')
order by companies_touched desc
```
<DataTable data={reconsider}/>

Action plan:
- Identify specific failure points
- Test new messaging if the segment remains important
- Consider relocating resources to other campaigns

# Market Opportunity Sizing
## Total Addressable Market (TAM)
127,000 Shopify merchants with a GMV between $1M and $500M:

| **GMV Category** | **Number of Merchants** | **% of Total** |
| ------------ | --------- | ---------- |
| $1-5M | 84,881 | 66.8% |
| $5-10M | 36,377 | 28.6% | 
| $10-50M | 4,804 | 3.8% |
| $50-100M | 619 | 0.5% |
| $100-500M | 319 | 0.25% |

## Methodology Calculation
> Potential New ARR = (TAM × Pipeline Value per Company) × Pipeline Revenue Win Rate (53.3%)

### Key Caveats
- **Data limited to historical performance**: This analysis assumes future campaigns will perform similarly to past ones, which may not account for market changes, or diminishing returns as we scale.

- **Varying conversion by GMV tier**:  Different GMV tiers likely have different propensities to convert, though our current data doesn't explicitly segment performance by customer size.

- **Pipeline-to-revenue conversion**: I use the historical Pipeline Revenue Win Rate (53.3%) to convert pipeline into ARR, which assumes the sales team will maintain similar close rates at scale.

- **Market saturation effects**: This analysis doesn't account for potential saturation effects from repeatedly targeting the same TAM with similar messaging.

## Revenue Potential Scenarios
### Conservative Scenario
Using the average Pipeline Value per Company Touched ($8.70):

| **TAM** | **Pipeline Value/Company** | **Pipeline Value** | **Pipeline Revenue Win Rate** | **Potential ARR** |
| --- | ---------------------- | -------------- | ------------------------- | ------------- |
| 127,000 | $8.70 | $1,104,900 | 53.3% | $588,965 |

### Moderate Scenario
Using a midpoint value between average and top performers ($12.85):

| **TAM** | **Pipeline Value/Company** | **Pipeline Value** | **Pipeline Revenue Win Rate** | **Potential ARR** |
| --- | ---------------------- | -------------- | ------------------------- | ------------- |
| 127,000 | $12.85 | $1,631,950 | 53.3% | $869,881 |

### Optimistic Scenario
Using values from our best-performing campaigns ($17.00):

| **TAM** | **Pipeline Value/Company** | **Pipeline Value** | **Pipeline Revenue Win Rate** | **Potential ARR** |
| --- | ---------------------- | -------------- | ------------------------- | ------------- |
| 127,000 | $17.00 | $2,159,000| 53.3% | $1,150,798 |

## Accounting for Sales Capacity
Current sales capacity: 7 quota-carrying reps × $600K quota = $4.2M yearly capacity

All scenarios fall well within our current sales capacity:

- Conservative scenario: $588,965 (14.0% of capacity)
- Moderate scenario: $869,881 (20.7% of capacity)
- Optimistic scenario: $1,150,798 (27.4% of capacity)

This analysis suggests that scaling our outbound efforts to our entire TAM could generate between $589K and $1.15M in new ARR. This represents a significant achievable growth opportunity that can be handled by the current sales team capacity.

# Strategic Channel Recommendations
## Growth Challenge
- Current ARR: $3M
- Target ARR: $10M (requires additional $7M)
- Outbound Potential: $870K-$1.15M in new ARR

This creates a clear need for a multi-channel approach to bridge the remaining gap.

## Inbound Foundation
- Create authoritative industry benchmarks using client e-commerce data
- Develop compelling case studies highlighting specific pain points and measurable outcomes
- Amplify content through owned channels (LinkedIn, Twitter) while securing placement in targeted industry publications and podcasts.
- **Strategic Value**: Sustainable growth engine + sales enablement content

## Paid Acquisition
- Build broader market awareness beyond existing database
- Test sponsored content in industry communities (EcommerceFuel, 2PM, draft.nu)
- Sponsor influential podcasts (Honest Ecommerce, Unofficial Shopify Podcast)
- **Strategic Value**: Rapid testing + audience expansion

## Enhanced Outbound Approach
- Scale highest-performing campaigns (Technology Intent, Ask Platform Lite)
- Focus on personalization depth vs. volume increases
- Integrate content insights to enhance message relevance

This balanced approach leverages each channel's strengths while building multiple growth engines that can help deliver the ambitious growth target.