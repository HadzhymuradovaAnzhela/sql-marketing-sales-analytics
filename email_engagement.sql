/* SUMMARY:
Monthly email engagement analysis, calculating sending frequency,
market share of messages per user, and tracking first/last activity dates.

SQL METHODS USED:
- CTEs
- Window Functions
- Date Functions
- Table Joins and Aggregations
*/

CREATE OR REPLACE VIEW `v_email_engagement_by_month` AS
WITH s_date_new AS (
  SELECT
    es.id_account,
    DATE_ADD(sess.date, INTERVAL es.sent_date DAY) AS sent_date_new
  FROM `DA.email_sent` es
  JOIN `DA.account_session` acs ON es.id_account = acs.account_id
  JOIN `DA.session` sess ON acs.ga_session_id = sess.ga_session_id
  GROUP BY 1, 2 
),
month_date AS (
  SELECT
    id_account,
    sent_date_new,
    DATE(EXTRACT(YEAR FROM sent_date_new), EXTRACT(MONTH FROM sent_date_new), 1) AS sent_month
  FROM s_date_new
)
SELECT
  sent_date_new,
  sent_month,
  id_account,
  COUNT(*) OVER(PARTITION BY id_account, sent_month) AS cnt_sent,
  COUNT(*) OVER(PARTITION BY sent_month) AS cnt_total,
  COUNT(*) OVER(PARTITION BY id_account, sent_month) / COUNT(*) OVER(PARTITION BY sent_month) * 100 AS sent_msg_percent_from_this_month,
  FIRST_VALUE(sent_date_new) OVER(PARTITION BY id_account, sent_month ORDER BY sent_date_new) AS first_sent_date,
  FIRST_VALUE(sent_date_new) OVER(PARTITION BY id_account, sent_month ORDER BY sent_date_new DESC) AS last_sent_date
FROM month_date
GROUP BY 1, 2, 3;

-- Final output query
SELECT DISTINCT 
  sent_month, id_account, sent_msg_percent_from_this_month, first_sent_date, last_sent_date
FROM `v_email_engagement_by_month`
ORDER BY 1 DESC, 2;
