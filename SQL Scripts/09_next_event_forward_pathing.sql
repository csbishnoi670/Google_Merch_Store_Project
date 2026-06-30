-- Uses LEAD to map out exactly what users do immediately after viewing an item.
WITH next_event_sequence AS (
  SELECT 
    session_id,
    event_name AS current_step,
    LEAD(event_name, 1) OVER (PARTITION BY session_id ORDER BY event_time) AS step_2,
    LEAD(event_name, 2) OVER (PARTITION BY session_id ORDER BY event_time) AS step_3
  FROM fct_events
)
SELECT 
  current_step || ' -> ' || COALESCE(step_2, 'DROP') || ' -> ' || COALESCE(step_3, 'DROP') AS downstream_path,
  COUNT(*) AS occurrence_count
FROM next_event_sequence
WHERE current_step = 'view_item'
GROUP BY 1
ORDER BY occurrence_count DESC
LIMIT 5;