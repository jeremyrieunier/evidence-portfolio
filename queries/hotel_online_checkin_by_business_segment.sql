SELECT
  business_segment,
  COUNT(*) as total_booking,
  SUM(CASE WHEN is_online_checkin = 1 THEN 1 ELSE 0 END) AS online_checkins,
  ROUND(SUM(CASE WHEN is_online_checkin = 1 THEN 1 ELSE 0 END) / COUNT(*), 4) AS online_checkin_rate
FROM ${hotel_reservations}
GROUP BY business_segment
ORDER BY total_booking DESC