SELECT 
   created_utc::DATE AS booking_date
FROM ${hotel_reservations}
GROUP BY 1