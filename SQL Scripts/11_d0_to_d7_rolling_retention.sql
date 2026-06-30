-- Tracks the precise drop-off of users on exact days relative to their sign-up date.
WITH user_acquisition AS (
  SELECT 
    user_id,
    first_seen_date::date AS d0_date
  FROM dim_users
),
user_activity_days AS (
  SELECT DISTINCT
    user_id,
    event_time::date AS active_date
  FROM fct_events
),
retention_deltas AS (
  SELECT 
    ua.user_id,
    ua.d0_date,
    (uad.active_date - ua.d0_date) AS days_since_join
  FROM user_acquisition ua
  INNER JOIN user_activity_days uad ON ua.user_id = uad.user_id
  WHERE (uad.active_date - ua.d0_date) BETWEEN 0 AND 7
),
cohort_sizes AS (
  SELECT d0_date, COUNT(DISTINCT user_id) AS cohort_volume
  FROM user_acquisition
  GROUP BY d0_date
)
SELECT 
  rd.d0_date AS acquisition_cohort,
  cs.cohort_volume,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN rd.days_since_join = 1 THEN rd.user_id END) / cs.cohort_volume, 2) AS d1_retention_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN rd.days_since_join = 3 THEN rd.user_id END) / cs.cohort_volume, 2) AS d3_retention_pct,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN rd.days_since_join = 7 THEN rd.user_id END) / cs.cohort_volume, 2) AS d7_retention_pct
FROM retention_deltas rd
INNER JOIN cohort_sizes cs ON rd.d0_date = cs.d0_date
GROUP BY rd.d0_date, cs.cohort_volume
ORDER BY rd.d0_date DESC;