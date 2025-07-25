SELECT
    CAMPAIGN_GROUP AS campaign,
    PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME AS pipeline_value_created,
    NB_COMPANIES_TOUCHED AS companies_touched,
    (PIPELINE_OPP_AMOUNT_FROM_OB_ALL_TIME / NB_COMPANIES_TOUCHED) AS pipeline_value_per_company_touched
FROM outbound.campaigns
ORDER BY 2 desc