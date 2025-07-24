WITH booking_metrics AS (
  SELECT
    CONCAT(country_code, '_', doctor_id) AS doctor_composite_id,
    SUM(bookings) AS total_bookings,
    AVG(bookings) AS avg_bookings_per_week
  FROM chat.doctors
  GROUP BY doctor_composite_id
),

doctor_chat_status AS (
  SELECT
    CONCAT(country_code, '_', doctor_id) AS doctor_composite_id,
    CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS is_chat_user
  FROM chat.messages
  WHERE sender = 'doctor' OR (sender = 'patient' AND message_status = 'read')
  GROUP BY doctor_composite_id
)

SELECT
  CASE WHEN d.is_chat_user = 1 THEN 'Chat Users' ELSE 'Non-Chat Users' END AS user_group,
  COUNT(DISTINCT b.doctor_composite_id) AS doctor_count,
  ROUND(AVG(b.avg_bookings_per_week), 2) AS avg_bookings_per_week,
  SUM(b.total_bookings) AS total_bookings
FROM booking_metrics b
LEFT JOIN doctor_chat_status d
  ON b.doctor_composite_id = d.doctor_composite_id
GROUP BY user_group
ORDER BY user_group