SELECT
  CASE
    WHEN res.age_group = 0 THEN 'Unknowm'
    WHEN res.age_group = 25 THEN '0-25'
    WHEN res.age_group = 35 THEN '25-35'
    WHEN res.age_group = 45 THEN '35-45'
    WHEN res.age_group = 55 THEN '45-55'
    WHEN res.age_group = 65 THEN '55-65'
    WHEN res.age_group = 100 THEN '> 65'
  END AS age_group,
  r.rate_name AS booking_rate,
  COUNT(*) AS total_bookings,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY res.age_group), 4)  percentage_within_age_group,
  DENSE_RANK() OVER (PARTITION BY res.age_group ORDER BY COUNT(*) DESC) AS rank
FROM ${hotel_reservations} res
JOIN ${hotel_rates} r
  ON res.rate_id = r.rate_id
GROUP BY res.age_group, booking_rate 
ORDER BY res.age_group, rank