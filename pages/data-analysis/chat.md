---
title: Chat Feature Analysis
queries:
  - nsm: chat/nsm.sql
  - active_week: chat/active_week.sql
  - matrix: chat/matrix_adoption.sql
  - booking: chat/booking_metrics.sql
---

A leading healthcare technology platform needed to evaluate the impact of their newly launched chat feature that enables direct communication between doctors and patients.

The feature was designed to:
- Improve patient management capabilities for doctors
- Enable secure file and medical record sharing
- Create an additional consultation and follow-up channel
- Increase platform value proposition and reduce doctors churn

Key questions included:
- How should we track feature success?
- What are current usage patterns and adoption rates?
- Does the feature deliver measurable value to doctors?
- What are the main barriers to user engagement?
- Where are the biggest growth opportunities?

# Data Schema

## Doctors data table
<table class="markdown text-left"><thead class="markdown"><tr class="markdown"><th class="markdown"><strong class="markdown">Column</strong></th> <th class="markdown"><strong class="markdown">Data Type</strong></th> <th class="markdown"><strong class="markdown">Description</strong></th></tr></thead> <tbody class="markdown"><tr class="markdown"><td class="markdown">doctor_id</td> <td class="markdown">STRING</td> <td class="markdown">Unique doctor identifier</td></tr> <tr class="markdown"><td class="markdown">doctor_specialization</td> <td class="markdown">STRING</td> <td class="markdown">Medical specialty</td></tr> <tr class="markdown"><td class="markdown">doctor_type</td> <td class="markdown">STRING</td> <td class="markdown">Doctor classification (paramedical, medical)</td></tr> <tr class="markdown"><td class="markdown">became_customer_date</td> <td class="markdown">DATE</td> <td class="markdown">Platform registration date</td></tr> <tr class="markdown"><td class="markdown">country_code</td> <td class="markdown">STRING</td> <td class="markdown">Geographic market</td></tr> <tr class="markdown"><td class="markdown">week</td> <td class="markdown">DATE</td> <td class="markdown">Analysis week</td></tr> <tr class="markdown"><td class="markdown">bookings</td> <td class="markdown">INTEGER</td> <td class="markdown">Weekly appointment bookings received</td></tr> <tr class="markdown"><td class="markdown">days_with_session</td> <td class="markdown">INTEGER</td> <td class="markdown">Platform engagement days per week</td></tr></tbody></table>


## Messages data table
<table class="markdown text-left"><thead class="markdown"><tr class="markdown"><th class="markdown"><strong class="markdown">Column</strong></th> <th class="markdown"><strong class="markdown">Data Type</strong></th> <th class="markdown"><strong class="markdown">Description</strong></th></tr></thead> <tbody class="markdown"><tr class="markdown"><td class="markdown">doctor_id</td> <td class="markdown">STRING</td> <td class="markdown">Doctor identifier</td></tr> <tr class="markdown"><td class="markdown">patient_id</td> <td class="markdown">STRING</td> <td class="markdown">Patient identifier</td></tr> <tr class="markdown"><td class="markdown">sender</td> <td class="markdown">STRING</td> <td class="markdown">Message sender (doctor/patient)</td></tr> <tr class="markdown"><td class="markdown">message_status</td> <td class="markdown">STRING</td> <td class="markdown">Read/not_read status</td></tr> <tr class="markdown"><td class="markdown">message_type</td> <td class="markdown">STRING</td> <td class="markdown">Content type (text, file, etc.)</td></tr> <tr class="markdown"><td class="markdown">week</td> <td class="markdown">DATE</td> <td class="markdown">Message week</td></tr> <tr class="markdown"><td class="markdown">country_code</td> <td class="markdown">STRING</td> <td class="markdown">Geographic market (br, mx)</td></tr></tbody></table>


# North Star Metric: Messages Sent by Doctors and Read by Patients per Week
This metric focuses on successful communication: messages that doctors send and patients actually read.

This metric was chosen because it captures both doctors and patients engagement - critical factors for the feature's success. It measures actual successful communication rather than just activity, ensuring we track meaningful interactions that drive business value.

### Chat feature is facilitating communication, with volumes trending positively

<BarChart 
    data={nsm}
    x=week
    y=messages_sent_by_doctors_read_by_patients
    y2=wow_growth
    y2SeriesType=line
    y2Fmt=pct
    lineWidth=15
    yAxisTitle=true
    chartAreaHeight=350
/>

<DataTable data={nsm} >
  <Column id=week />
  <Column id=messages_sent_by_doctors_read_by_patients />
  <Column id=wow_growth fmt=pct />
</DataTable>

## Key Insights
- **Volume scale**: The platform facilitates over 43,000 messages sent by doctors on average every week, demonstrating significant adoption.
- **Positive growth trend**: We observe a clear upward trajectory in the last 3 weeks of the analysis period (Feb 22-Mar 8), with read messages increasing from ~31,000 to ~35,000 weekly.

There's however a communication gap that represents a clear opportunity for improvement:

### 25-29% of messages sent by doctors go unread by patients

<BarChart 
    data={nsm} 
    x=week 
    y=total_messages_sent_by_doctor
    y2=patient_unread_rate
    y2SeriesType=line
    y2Fmt=pct
    y2Max=1
    chartAreaHeight=350
    
/>

<Details title="SQL query used for thr north star metric analysis">

```sql
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
    CASE WHEN message_status = 'read'THEN message_count ELSE 0 END) AS messages_sent_by_doctors_read_by_patients,
  ROUND((SUM(CASE WHEN message_status = 'read' THEN message_count ELSE 0 END) - LAG(SUM(CASE WHEN message_status = 'read' THEN message_count ELSE 0 END)) OVER (ORDER BY week)) / LAG(SUM(CASE WHEN message_status = 'read' THEN message_count ELSE 0 END)) OVER (ORDER BY week), 2) AS wow_growth,
  SUM(CASE WHEN message_status = 'not read' THEN message_count ELSE 0 END) AS doctor_messages_not_read,
  SUM(message_count) AS total_messages_sent_by_doctor,
  SUM(message_count) / COUNT(DISTINCT doctor_composite_id) AS avg_messages_sent_per_doctor,
  ROUND(SUM(CASE WHEN message_status = 'not read' THEN message_count ELSE 0 END) / SUM(message_count), 2) AS patient_unread_rate,
FROM messages_from_doctors
GROUP BY week
ORDER BY week
```

</Details>

# Feature Adoption and Usage Patterns
Analysis of weekly chat usage reveals that while the feature has gained traction among doctors, there remains significant **opportunity for deeper integration into their workflows**.

### 27-29% of doctors actively use the chat feature in any given week
<BarChart 
    data={active_week} 
    x=week 
    y=total_doctor_count
    y2=weekly_active_usage_rate
    y2SeriesType=line
    y2Fmt=pct
    y2Min=0
    y2Max=1
    chartAreaHeight=350
/>

## Key Insights
- **Consistent weekly usage**: Between 27-29% of doctors actively use the chat feature in any given week, representing approximately 8,200-9,100 active doctors.
- **Stable engagement**: Despite the total doctor base growing from 30,530 to 31,818 over these 10 weeks, the percentage of active users remained relatively stable, suggesting successful onboarding of new doctors to the feature.

## Initial Observations
- **Adoption oppportunity**: With 1 in 4 doctors using chat weekly, there is significant potential to expand usage across the platform.
- **Consistency**: The stability of weekly usage suggests the feature has found a core user base but may need enhancements to appeal to a broader audience.

To better understand usage patterns, we'll next examine how chat adoption varies across different doctor specializations, which will help identify targeted growth opportunities.

<Details title="SQL query used for the feature adoption analysis">

```sql
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
```

</Details>

# Chat Adoption by Specialization and Business Impact
Now that we understand the overall weekly usage rate, the next analysis examines how chat adoption varies across medical specializations and its relationship with our core business metric: bookings.

<BubbleChart
  data={matrix}
  x=chat_used_rate
  y=avg_weekly_bookings_per_doctor
  series=doctor_specialization
  size=total_doctors
  scaleTo=1.2
  xFmt=pct
  xMax=1
  yMin=0
  chartAreaHeight=350
  xLabelWrap=true
>

  <ReferenceArea 
    xMin=0.62
    xMax=0.8
    yMin=2.5
    yMax=4
    label="High-impact Specializations" 
    color="positive"
    border={true}
    labelPosition="center"
  />

  <ReferenceArea 
    xMin=0.3
    xMax=0.6
    yMin=0.5
    yMax=1.7
    label="Growth Opportunities" 
    color="info"
    border={true}
    labelPosition="center"
  />
</BubbleChart>

## Key Insights
- **Wide usage variation**: Chat usage rates range dramatically across specializations, from as low as 8.7% (Radiology) to as high as 74.0% (Proctology), with an overall average of 60.2%.
- **Practice pattern influence**: Specializations requiring ongoing patient relationships (Endocrinology 73.5%, Obsterics and Gyneacology 70.7%) show much higher usage than those focused on one-time diagnostics (Radiology 8.7%).

### High-impact Specializations
Several large specializations show both high adoption and strong booking performance:
- **Dermatology & Venereology**: 66.3% usage, 3.84 bookings/doctor (highest booking rate)
- **Obstetrics & Gynecology**: 70.7% usage, 3.40 bookings/doctor (3,010 doctors)
- **Pulmonology**: 64.6% usage, 3.46 bookings/doctor

### Growth Opportunities
Several specializations with significant doctor numbers show below-average chat usage:
- **General Medicine**: 34.3% usage (lowest among major specialties), 1.04 bookings/doctor (1,187 doctors)
- **Orthopedics**: 60.7% usage, 1.71 bookings/doctor (1,772 doctors)
- **Ophthalmology**: 56.5% usage, 1.95 bookings/doctor (1,606 doctors)

<Details title="SQL query used for the chat adoption analysis by specialization">

```sql
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
```

</Details>


# Business Value Analysis
Our analysis reveals a striking correlation between chat feature usage and booking performance:

<DataTable data={booking} >
  <Column id=user_group />
  <Column id=doctor_count />
  <Column id=avg_bookings_per_week />
  <Column id=total_bookings />
</DataTable>

## Key Insights
- **Clear value proposition**: Doctors who use chat receive approximately 8.5x more bookings than those who don't, demonstrating a strong business case for the feature.
- **Revenue driver**: Chat users (+61% of doctors) account for nearly 94% of all bookings on the platform, making this feature a critical revenue driver.

<Details title="SQL query used the business value analysis">

```sql 
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
```

</Details>

# Strategic Recommendations

## This quarter
- **Reduce Unread Rate**: Implement improved notification systems to reduce the 25-29% unread rate.
- **Targeted adoption**: Focus on high-volume, low-adoption specializations like General Medicine (34% adoption, 1,187 doctors).

## Next quarter
- **Specialization-specific features**: Develop templates and workflows tailored to the needs of different medical specialties.
- **Re-engagement campaign**: Target the doctors who tried chat but don't use it weekly.
- **Value communication**: Highlight the booking correlation in marketing materials to drive adoption.

# Conclusion
The chat feature demonstrates strong business value with a clear correlation to increased bookings. Primary challenges are:

- Expanding consistent usage beyond the current 27-29% weekly active users
- Reducing the 25-29% unread rate to improve communication effectiveness
- Addressing specialty-specific needs to increase adoption in underperforming segments
