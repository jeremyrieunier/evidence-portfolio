SELECT
    StartUtc AS start_utc,
    EndUtc AS end_utc,
    CreatedUtc AS created_utc,
    NightCount AS night_count,
    NightCost_Sum AS night_cost_sum,
    OccupiedSpace_Sum AS occupied_space_sum,
    GuestCount_Sum AS guest_count_sum,
    LeadTime AS lead_time,
    StayLength AS stay_length,
    CancellationReASon AS cancellation_reASon,
    SettlementType AS settlement_type,
    ReservationState AS reservation_state,
    Origin AS origin,
    CommanderOrigin AS commander_origin,
    TravelAgency AS travel_agency,
    IsOnlineCheckin AS is_online_checkin,
    NationalityCode AS nationality_code,
    Gender AS gender,
    ClASsification AS clASsification,
    AgeGroup AS age_group,
    HASEmail AS hAS_email,
    EnterpriseTimeZone AS enterprise_time_zone,
    BusinessSegment AS business_segment,
    Tier AS tier,
    RateId AS rate_id
FROM hotel.reservations