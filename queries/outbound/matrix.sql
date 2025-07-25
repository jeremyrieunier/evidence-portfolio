SELECT
  CAMPAIGN_GROUP AS campaign,
  NB_COMPANIES_TOUCHED AS companies_touched,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME AS pipeline_value_created,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME / NB_COMPANIES_TOUCHED AS pipeline_value_per_company
FROM outbound.campaigns
ORDER BY companies_touched DESC