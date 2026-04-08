/* SUMMARY:
This View automates the tracking of monthly email KPIs (Open Rate, Click Rate, CTOR).

KEY METRICS:
- Monthly Open Rate
- Monthly Click Rate
- CTOR

SQL METHODS USED:
- Create View
- CTEs
- Date Functions
- Table Joins and Aggregations
*/

CREATE OR REPLACE VIEW `dataset.v_monthly_email_performance` AS
WITH email_dates AS (
  -- Reconstruct the actual sending date by adding the 'sent_date' interval to the session start
  SELECT
    es.id_account,
    es.id_message,
    DATE_ADD(sess.date, INTERVAL es.sent_date DAY) AS full_sent_date
  FROM `DA.email_sent` es
  JOIN `DA.account_session` acs ON es.id_account = acs.account_id
  JOIN `DA.session` sess ON acs.ga_session_id = sess.ga_session_id
),
monthly_metrics AS (
  -- Normalize dates to the first day of the month
  SELECT
    id_message,
    DATE(EXTRACT(YEAR FROM full_sent_date), EXTRACT(MONTH FROM full_sent_date), 1) AS sent_month
  FROM email_dates
),
email_funnel AS (
  -- Joining sent emails with opens and website visits
  SELECT
    mm.sent_month,
    mm.id_message,
    eo.id_message AS id_message_open,
    ev.id_message AS id_message_visit
  FROM monthly_metrics mm
  LEFT JOIN `DA.email_open` eo ON mm.id_message = eo.id_message
  LEFT JOIN `DA.email_visit` ev ON mm.id_message = ev.id_message
)
-- Final Aggregation
SELECT
  sent_month,
  COUNT(DISTINCT id_message) AS sent_msg,
  COUNT(DISTINCT id_message_open) AS open_msg,
  COUNT(DISTINCT id_message_visit) AS visit_msg,
  COUNT(DISTINCT id_message_open) / NULLIF(COUNT(DISTINCT id_message), 0) * 100 AS open_rate,
  COUNT(DISTINCT id_message_visit) / NULLIF(COUNT(DISTINCT id_message), 0) * 100 AS click_rate,
  COUNT(DISTINCT id_message_visit) / NULLIF(COUNT(DISTINCT id_message_open), 0) * 100 AS ctor
FROM email_funnel
GROUP BY 1
ORDER BY 1 DESC;







/* SUMMARY:
This analysis evaluates email marketing effectiveness by Operating Systems.

KEY METRICS:
- Open Rate by OS
- Click Rate by OS
- CTOR by OS 
*/

WITH account_session AS (
  -- Filtering active subscribers and mapping sessions to operating systems
  SELECT
    a.id AS account_id,
    sp.operating_system
  FROM `DA.account_session` acs
  JOIN `DA.account` a ON acs.account_id = a.id
  JOIN `DA.session_params` sp ON acs.ga_session_id = sp.ga_session_id
  WHERE a.is_unsubscribed = 0
),

email_funnel_base AS (
  -- Joining sent messages with opens and visits
  SELECT
    es.id_account AS id_account_sent,
    es.id_message AS id_message_sent,
    eo.id_message AS id_message_open,
    ev.id_message AS id_message_visit
  FROM `DA.email_sent` es
  LEFT JOIN `DA.email_open` eo ON es.id_message = eo.id_message
  LEFT JOIN `DA.email_visit` ev ON es.id_message = ev.id_message
),

joined_data AS (
  -- Сombining OS technical data with email engagement metrics
  SELECT
    acs.operating_system,
    ef.id_message_sent,
    ef.id_message_open,
    ef.id_message_visit
  FROM account_session acs
  JOIN email_funnel_base ef ON acs.account_id = ef.id_account_sent
)

-- Final aggregation
SELECT
  operating_system,
  COUNT(DISTINCT id_message_sent) AS sent_msg,
  COUNT(DISTINCT id_message_open) AS open_msg,
  COUNT(DISTINCT id_message_visit) AS visit_msg,
  -- Performance Metrics
  COUNT(DISTINCT id_message_open) / NULLIF(COUNT(DISTINCT id_message_sent), 0) * 100 AS open_rate,
  COUNT(DISTINCT id_message_visit) / NULLIF(COUNT(DISTINCT id_message_sent), 0) * 100 AS click_rate,
  COUNT(DISTINCT id_message_visit) / NULLIF(COUNT(DISTINCT id_message_open), 0) * 100 AS ctor
FROM joined_data
GROUP BY 1
ORDER BY sent_msg DESC;



