---
title: Merchants Analysis
queries:
  - merchants_distribution: ecommerce/merchants_distribution.sql
  - top_merchants: ecommerce/top_merchants.sql
  - merchant_metrics: ecommerce/merchant_metrics.sql
  - top_shipping_carriers: ecommerce/top_shipping_carriers.sql
  - print_providers_score: ecommerce/print_providers_score.sql
---

# What Characteristics Do the Most Successful Merchants Share?

## Defining Successful Merchants
Before analyzing merchant characteristics, we must first establish a clear definition of successful merchants. This requires both identifying the right metric and ensuring we're analyzing the appropriate merchant population.

### Revenue as the Primary Success Metric
We define merchant success based on total revenue (`total_cost`). This metric directly reflects business performance and value creation, making it the most appropriate measure for identifying successful merchants on the platform.

### Filtering for Active Merchants
Initial analysis of our 27,960 merchants revealed a significant data quality issue that would skew any meaningful analysis:

<DataTable data={merchants_distribution}/>

We excluded merchants with ≤10 orders from our analysis for the following reasons:

- Business vs. Hobbyist Activity: Merchants with ≤10 orders over 6 months might either represent occasional sellers or new sellers rather than active businesses
- Analytical Integrity: Including dormant accounts would make our "successful merchant" analysis meaningless
- Sample Quality: Focusing on 3,471 active merchants provides cleaner, more actionable insights

### Sucess Definition
The analysis reveals a classic power law distribution with a hockey stick curve:

<BarChart 
    data={top_merchants} 
    x=percentile
    y=cumulative_revenue
    sort=false
    yFmt=usd0k
    y2=cumulative_revenue_percent
    y2SeriesType=line
    y2Max=1
    y2Fmt=pct
    chartAreaHeight=350
/>

<DataTable data={top_merchants} >

  <Column id=percentile/> 
	<Column id=cumulative_revenue fmt=usd0/> 
  <Column id=cumulative_revenue_percent fmt=pct/> 
  <Column id=avg_revenue fmt=usd0/> 
	<Column id=min_revenue fmt=usd0/> 
  <Column id=max_revenue fmt=usd0/> 
</DataTable>

We define "successful merchants" as the top 15% by revenue (≥$1,323 over 6 months) because:

- Natural Breakpoint: The hockey stick curve's steep rise ends around percentile 15, where revenue concentration reaches 63.8%
- Sample Size: 525 merchants provide robust data for meaningful characteristic analysis
- Business Relevance: $1,323 threshold represents serious business activity (≥$220/month average)

## Merchant Characteristics Analysis

After identifying the top 15% of merchants (524 merchants with ≥$1,323 revenue), we analyzed key business characteristics to understand what differentiates successful merchants from other active merchants:


<DataTable data={merchant_metrics}>
	<Column id=metric />
	<Column id=top_15_percent />
	<Column id=others />
  <Column id=difference contentType=delta fmt=pct />
</DataTable>

### What Makes Successful Merchants Different
#### Massive Scale Difference
The most striking difference is in order volume: successful merchants average 50 orders per month compared to just 5.5 for others. This suggests that sustained high activity is the primary driver of success.

#### Geographic Diversification
Successful merchants serve 2.3x more countries on average (5.5 vs 2.4), indicating that geographic expansion is a key growth strategy. This broader reach likely drives higher overall revenue through market diversification.

#### Supply Chain Diversification
Top merchants work with 88% more print providers (9.3 vs 5.0), suggesting they optimize for quality, cost, or capacity.

#### Product Portfolio Breadth
50% more product types (5.6 vs 3.8), indicating diversified offerings rather than single-product focus.

### Business Implications
Merchant success requires both operational scale and sophisticated business strategy, rather than simply being active on the platform. The combination of high volume, geographic reach and supplier diversification creates a sustainable competitive advantage that drives performance.

Interestingly, both groups use approximately the same number of sales channels (1.11 vs 1.12), indicating that channel diversification is not a key differentiator among active merchants. Success appears more related to execution within existing channels rather than multi-channel presence.


# Top Shipping Carriers Analysis

## Current Carrier Distribution
<DataTable data={top_shipping_carriers}>
	<Column id=shipment_carrier />
	<Column id=total_orders />
	<Column id=percent_total_orders fmt=pct />
  <Column id=countries_served />
</DataTable>

### Arguments Against Full Consolidation
- USPS primarily serves North America effectively, with limited international reach (24 countries)
- UPS Mail Innovations covers 36 countries but may not provide optimal service in all regions
- 82.5% reliance on USPS creates a single point of failure
- Different regions require different service levels and delivery expectations
- Local carriers often provide superior last-mile delivery in their home markets

While the top 2 carriers handle 89% of volume efficiently, full consolidation would create unnecessary risks and service gaps. The current high market share reflects merchant preferences for these carriers in their optimal regions, not universal superiority across all markets.

# Print Provider Analysis
## Methodology

A weighted scoring approach is essential for this business decision because:
- Print providers impact 3 critical business areas: quality, speed, and volume. These can't be evaluated in isolation
- Different metrics have different business impacts, requiring weighted prioritization
- Scores eliminate subjective bias and provide clear, defensible rationale for contract decisions

### Scoring Framework Justification
| **Metric** | **Weight** | **Rationale** |
| ------ | ------ | --------- |
| Quality (Reprint Rate) | 30% | Poor quality = customer complaints, returns, brand damage. Critical for reputation |
|Speed (Production Time) | 20% | Faster fulfillment = competitive advantage, but external factors limit control
| Volume (Total Orders) |50% | Business impact and partnership value. High-volume providers deserve investment |

Why not equal weighting: A small provider with perfect metrics but 1% market share doesn't deserve the same consideration as a major partner driving half our business. The scoring system ensures strategic business decisions rather than purely operational ones.

## Recommended Actions
### Discount: Best 2 Providers

```sql best_2_providers
SELECT *
FROM ${print_providers_score}
LIMIT 2
```
<DataTable data={best_2_providers}>
	<Column id=print_provider_id />
  <Column id=total_orders />
	<Column id=total_items />
  <Column id=reprint_rate fmt=pct />
  <Column id=avg_production_days />
  <Column id=final_score />
</DataTable>

- Provider 29: Highest volume + exceptional quality + fastest production
- Provider 39: Strong volume + best quality metrics + reasonable speed
- Combined Impact: These 2 handle 51% of total orders with exceptional performance metrics


### End Contracts: Worst 2 Providers

```sql worst_2_providers
SELECT *
FROM ${print_providers_score}
ORDER BY final_score ASC
LIMIT 2
```
<DataTable data={worst_2_providers}>
	<Column id=print_provider_id />
  <Column id=total_orders />
	<Column id=total_items />
  <Column id=reprint_rate fmt=pct />
  <Column id=avg_production_days />
  <Column id=final_score />
</DataTable>

- Provider 74: Poor quality, slow production, minimal volume
- Provider 52: Below-average performance across all metrics, minimal business impact

## Quality vs Speed by Volume

<BubbleChart 
    data={print_providers_score}
    x=avg_production_days
    y=reprint_rate
    yFmt=pct
    series=print_provider_id
    size=total_orders
    chartAreaHeight=350
    scaleTo=1.2
    xLabelWrap=true
    legend=false
/>

The chart clearly shows Providers 29 and 39 (large bubbles in bottom-left) occupy the optimal position with low reprint rates, fast production times, and massive volume. This validates our scoring methodology perfectly.

On the other hand, small bubbles scattered in the upper-right represent low-volume providers with poor performance—exactly the ones our scoring system flagged for contract termination.