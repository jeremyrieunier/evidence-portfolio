WITH all_doctors AS (
  SELECT 
    doctor_specialization,
    CONCAT(country_code, '_', doctor_id) AS doctor_composite_id,
    AVG(bookings) AS avg_bookings_per_week
  FROM chat.doctors
  WHERE doctor_specialization IS NOT NULL
  GROUP BY doctor_specialization, doctor_composite_id
),

chat_users AS (
  SELECT
    DISTINCT CONCAT(country_code, '_', doctor_id) AS doctor_composite_id,
    COUNT(DISTINCT patient_id) AS unique_patients,
    SUM(CASE WHEN sender = 'doctor' THEN 1 ELSE 0 END) AS messages_sent,
    SUM(CASE WHEN sender = 'patient' THEN 1 ELSE 0 END) AS messages_received
  FROM chat.messages
  WHERE sender = 'doctor' OR (sender = 'patient' AND message_status = 'read') 
  GROUP BY doctor_composite_id, country_code, doctor_id
)

SELECT
  d.doctor_specialization AS doctor_specialization,
  COUNT(DISTINCT d.doctor_composite_id) AS total_doctors,
  ROUND(COUNT(DISTINCT CASE WHEN c.doctor_composite_id IS NOT NULL THEN d.doctor_composite_id ELSE NULL END) / COUNT(DISTINCT d.doctor_composite_id), 2) AS chat_used_rate,
  ROUND(AVG(d.avg_bookings_per_week), 2) AS avg_weekly_bookings_per_doctor
FROM all_doctors d
LEFT JOIN chat_users c
  ON d.doctor_composite_id = c.doctor_composite_id
GROUP BY d.doctor_specialization
HAVING COUNT(DISTINCT d.doctor_composite_id) >= 100
ORDER BY total_doctors DESC