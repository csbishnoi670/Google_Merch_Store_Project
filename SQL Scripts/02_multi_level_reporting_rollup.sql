-- Creates an executive summary grouping by device, OS, and a grand total.
SELECT 
  ds.device_type,
  ds.operating_system,
  COUNT(DISTINCT fe.user_id) AS active_users,
  SUM(fe.revenue_usd) AS total_revenue
FROM fct_events fe
INNER JOIN dim_sessions ds ON fe.session_id = ds.session_id
GROUP BY ROLLUP (ds.device_type, ds.operating_system)
ORDER BY ds.device_type NULLS LAST, ds.operating_system NULLS LAST;