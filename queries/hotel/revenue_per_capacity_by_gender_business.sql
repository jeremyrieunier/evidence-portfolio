SELECT 
   CASE 
      WHEN gender = 1 THEN 'Male' 
      WHEN gender = 2 THEN 'Female' 
      WHEN gender = 0 THEN 'Unknown'
   END || ' ' || business_segment AS gender_business_segment,
   COUNT(*) AS total_bookings,
   ROUND(AVG((night_cost_sum / night_count) / (occupied_space_sum)), 2) AS avg_night_revenue_per_occupied_capacity,
   ROUND(COUNT(*) / SUM(COUNT(*)) OVER(), 4) AS percentage_booking,
   ROUND(SUM(night_cost_sum), 2) AS total_revenue
FROM ${reservations}
WHERE occupied_space_sum > 0 AND night_count > 0
GROUP BY gender_business_segment
ORDER BY avg_night_revenue_per_occupied_capacity DESC
