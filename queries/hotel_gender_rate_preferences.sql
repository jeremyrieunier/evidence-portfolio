SELECT
  CASE
    WHEN gender = 0 THEN 'Unknown'
    WHEN gender = 1 THEN 'Male'
    WHEN gender = 2 THEN 'Female'
  END AS gender,
  r.rate_name AS booking_rate,
  COUNT(*) AS total_bookings,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY gender), 4) AS percentage_within_gender,
  DENSE_RANK() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rank
FROM ${hotel_reservations} res
JOIN ${hotel_rates} r
  ON res.rate_id = r.rate_id
GROUP BY gender, booking_rate
ORDER BY gender DESC, rank