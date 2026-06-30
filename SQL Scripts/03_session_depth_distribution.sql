-- Categorizes sessions by how many actions were taken to spot zombie traffic.
WITH session_event_counts AS (
  SELECT 
    session_id,
    COUNT(event_id) AS total_actions_performed
  FROM fct_events
  GROUP BY session_id
)
SELECT 
  CASE 
    WHEN total_actions_performed = 1 THEN '1. Bounce (1 Event)'
    WHEN total_actions_performed BETWEEN 2 AND 5 THEN '2. Shallow (2-5 Events)'
    WHEN total_actions_performed BETWEEN 6 AND 15 THEN '3. Core (6-15 Events)'
    ELSE '4. Deep (15+ Events)'
  END AS session_depth_segment,
  COUNT(session_id) AS session_volume,
  ROUND(100.0 * COUNT(session_id) / SUM(COUNT(session_id)) OVER(), 2) AS pct_of_total
FROM session_event_counts
GROUP BY 1
ORDER BY 1;