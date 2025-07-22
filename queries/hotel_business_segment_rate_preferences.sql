SELECT
  res.business_segment,
  r.rate_name AS booking_rate,
  COUNT(*) AS total_bookings,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY res.business_segment), 4) AS percentage_within_age_group,
  DENSE_RANK() OVER (PARTITION BY res.business_segment ORDER BY COUNT(*) DESC) AS rank
FROM ${hotel_reservations} res
JOIN ${hotel_rates} r
  ON res.rate_id = r.rate_id
GROUP BY res.business_segment, booking_rate 
ORDER BY res.business_segment, rank