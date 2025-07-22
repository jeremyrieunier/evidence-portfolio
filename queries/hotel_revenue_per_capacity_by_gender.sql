SELECT 
    CASE
      WHEN gender = 1 THEN 'Male'
      WHEN gender = 2 THEN 'Female'
      WHEN gender = 0 THEN 'Unknown'
    END AS gender,    
    ROUND(AVG((night_cost_sum / night_count) / (occupied_space_sum)), 2) AS avg_night_revenue_per_occupied_capacity,
    COUNT(*) AS total_booking,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER(), 4) AS percentage_booking,
    SUM(night_cost_sum) AS total_revenue
FROM ${hotel_reservations}
GROUP BY gender, 
ORDER BY avg_night_revenue_per_occupied_capacity DESC;