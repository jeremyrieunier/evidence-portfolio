WITH all_doctors AS (
  SELECT
    week,
    COUNT(DISTINCT CONCAT(country_code, '_', doctor_id)) AS total_doctor_count
  FROM chat.doctors
  GROUP BY week
),

chat_users AS (
  SELECT
    week,
    COUNT(DISTINCT CONCAT(country_code, '_', doctor_id)) AS chat_doctor_count
  FROM chat.messages
  WHERE sender = 'doctor' OR (sender = 'patient' AND message_status = 'read')
  GROUP BY week
)

SELECT
  a.week AS week,
  a.total_doctor_count AS total_doctor_count,
  COALESCE(c.chat_doctor_count, 0) AS chat_doctor_count,
  COALESCE(c.chat_doctor_count, 0) / a.total_doctor_count AS weekly_active_usage_rate
FROM all_doctors a
LEFT JOIN chat_users c ON a.week = c.week
ORDER BY a.week