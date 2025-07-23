SELECT
  business_segment,
  COUNT(*) AS total_bookings,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER(), 4) AS percentage
FROM ${reservations}
GROUP BY business_segment
ORDER BY total_bookings DESC