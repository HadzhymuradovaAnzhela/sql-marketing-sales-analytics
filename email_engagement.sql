/* SUMMARY:
This View automates the tracking of monthly email KPIs (Open Rate, Click Rate, CTOR).

Key Metrics:
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
This View automates the tracking of monthly email KPIs (Open Rate, Click Rate, CTOR).

SQL METHODS USED:
- Create View
- CTEs
- Date Functions
- Table Joins and Aggregations
*/

