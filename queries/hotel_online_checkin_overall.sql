SELECT 
  COUNT(*) AS total_booking,
  SUM(CASE WHEN is_online_checkin = 1 THEN 1 ELSE 0 END) AS online_checkins,
  ROUND(SUM(CASE WHEN is_online_checkin = 1 THEN 1 ELSE 0 END) / COUNT(*), 4) AS online_checkins_rate
FROM ${hotel_reservations}