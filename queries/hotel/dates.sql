SELECT 
   created_utc::DATE AS booking_date
FROM ${reservations}
GROUP BY 1