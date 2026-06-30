-- Determines if the app is habit-forming by dividing daily traffic by monthly traffic.
WITH daily_active AS (
  SELECT 
    DATE_TRUNC('day', event_time) AS active_day,
    COUNT(DISTINCT user_id) AS dau
  FROM fct_events
  GROUP BY 1
),
monthly_active AS (
  SELECT 
    DATE_TRUNC('month', event_time) AS active_month,
    COUNT(DISTINCT user_id) AS mau
  FROM fct_events
  GROUP BY 1
)
SELECT 
  d.active_day,
  d.dau,
  m.mau,
  ROUND((d.dau::float / m.mau) * 100, 2) AS stickiness_pct
FROM daily_active d
INNER JOIN monthly_active m ON DATE_TRUNC('month', d.active_day) = m.active_month
ORDER BY d.active_day DESC;