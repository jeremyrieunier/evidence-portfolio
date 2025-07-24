WITH messages_from_doctors AS (
  SELECT
    week,
    CONCAT(country_code, '_', doctor_id) AS doctor_composite_id,
    message_status,
    COUNT(*) as message_count
  FROM chat.messages
  WHERE sender = 'doctor'
  GROUP BY week, doctor_composite_id, message_status
)

SELECT
  week,
  SUM(
    CASE WHEN message_status = 'read'THEN message_count ELSE 0 END) AS nsm_doctor_messages_read_by_patients,
  ROUND((SUM(CASE WHEN message_status = 'read' THEN message_count ELSE 0 END) - LAG(SUM(CASE WHEN message_status = 'read' THEN message_count ELSE 0 END)) OVER (ORDER BY week)) / LAG(SUM(CASE WHEN message_status = 'read' THEN message_count ELSE 0 END)) OVER (ORDER BY week), 2) AS nsm_wow_growth,
  SUM(CASE WHEN message_status = 'not read' THEN message_count ELSE 0 END) AS doctor_messages_not_read,
  SUM(message_count) AS total_messages_sent_by_doctor,
  SUM(message_count) / COUNT(DISTINCT doctor_composite_id) AS avg_messages_sent_per_doctor,
  ROUND(SUM(CASE WHEN message_status = 'not read' THEN message_count ELSE 0 END) / SUM(message_count), 2) AS patient_unread_rate,
FROM messages_from_doctors
GROUP BY week
ORDER BY week