SELECT
  CAMPAIGN_GROUP AS campaign,
  PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME AS pipeline_value_created,
  NEW_ARR_FROM_OB_ALL_TIME AS arr_value_created,
  NEW_ARR_FROM_OB_ALL_TIME / PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME AS pipeline_revenue_win_rate
FROM outbound.campaigns
ORDER BY 2 DESC