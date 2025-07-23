SELECT
  CASE
    WHEN gender = 0 then 'Unknown'
    WHEN gender = 1 then 'Male'
    WHEN gender = 2 then 'Female'
  END AS gender,
  COUNT(*) AS total_bookings,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER(), 4) AS percentage
FROM ${reservations}
GROUP BY gender
ORDER BY total_bookings DESC