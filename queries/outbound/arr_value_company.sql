SELECT
  CAMPAIGN_GROUP AS campaign,
  NEW_ARR_FROM_OB_ALL_TIME AS arr_value_created,
  NB_COMPANIES_TOUCHED AS companies_touched,
  NEW_ARR_FROM_OB_ALL_TIME / NB_COMPANIES_TOUCHED AS arr_per_company_touched
FROM outbound.campaigns
ORDER BY 2 DESC