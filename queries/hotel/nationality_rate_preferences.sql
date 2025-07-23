WITH nationalities_above_40_booking AS (
  SELECT nationality_code
  FROM ${reservations}
  GROUP BY nationality_code
  HAVING COUNT(*) > 40
)
SELECT
  res.nationality_code,
  r.rate_name AS booking_rate,
  COUNT(*) AS total_bookings,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY res.nationality_code), 4) AS percentage_within_nationality,
  DENSE_RANK() OVER (PARTITION BY res.nationality_code ORDER BY COUNT(*) DESC) AS rank
FROM ${reservations} res
JOIN ${rates} r
  ON res.rate_id = r.rate_id
JOIN nationalities_above_40_booking n
  ON res.nationality_code = n.nationality_code
GROUP BY res.nationality_code, booking_rate
ORDER BY SUM(COUNT(*)) OVER(PARTITION BY res.nationality_code) DESC, rank