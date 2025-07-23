SELECT
    RateId AS rate_id,
    RateName AS rate_name,
    ShortRateName AS short_rate_name,
    SettlementAction AS settlement_action,
    SettlementTrigger AS settement_trigger,
    SettlementValue AS settlement_value,
    SettlementType AS settlement_type
FROM hotel.rates
