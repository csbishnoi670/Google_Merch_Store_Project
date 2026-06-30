-- Calculates the exact average minutes it takes to find a product and add to cart.
WITH session_starts AS (
  SELECT 
    session_id, 
    MIN(event_time AT TIME ZONE 'UTC') AS session_start_time
  FROM fct_events 
  WHERE event_name = 'page_view' 
  GROUP BY session_id
),
cart_milestones AS (
  SELECT 
    pi.session_id, 
    ss.session_start_time, 
    MIN(pi.event_time AT TIME ZONE 'UTC') AS first_cart_add_time
  FROM fct_product_interactions pi
  INNER JOIN session_starts ss ON pi.session_id = ss.session_id
  WHERE pi.event_name = 'add_to_cart'
  GROUP BY pi.session_id, ss.session_start_time
)
SELECT 
  COUNT(session_id) AS total_converting_sessions,
  ROUND((EXTRACT(EPOCH FROM AVG(first_cart_add_time - session_start_time)) / 60)::numeric, 2) AS avg_minutes_to_cart
FROM cart_milestones;