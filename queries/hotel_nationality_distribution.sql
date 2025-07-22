SELECT
  CASE
    WHEN nationality_code = 'NULL' THEN 'Unknown'
    ELSE nationality_code
  END AS nationality_code,
  COUNT(*) AS total_bookings,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER(), 4) AS percentage
FROM ${hotel_reservations}
GROUP BY nationality_code
ORDER BY total_bookings DESC
LIMIT 10