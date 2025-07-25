SELECT
  CAMPAIGN_GROUP AS campaign,
  NB_COMPANIES_TOUCHED AS companies_touched,
  NB_COMPANIES_TOUCHED_ICP AS icp_companies_touched,
  NB_COMPANIES_TOUCHED_ICP / NB_COMPANIES_TOUCHED AS icp_targeting_accuracy
FROM outbound.campaigns
ORDER BY 2 DESC