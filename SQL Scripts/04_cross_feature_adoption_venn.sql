-- Evaluates what percentage of standard page viewers also interact with products.
WITH product_users AS (
  SELECT DISTINCT fe.user_id
  FROM fct_events fe
  INNER JOIN fct_product_interactions fpi ON fe.session_id = fpi.session_id
),
core_events_users AS (
  SELECT DISTINCT user_id 
  FROM fct_events 
  WHERE event_name = 'page_view'
)
SELECT 
  COUNT(DISTINCT c.user_id) AS total_viewers,
  COUNT(DISTINCT p.user_id) AS total_shoppers,
  COUNT(DISTINCT CASE WHEN c.user_id IS NOT NULL AND p.user_id IS NOT NULL THEN c.user_id END) AS overlap_users,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN c.user_id IS NOT NULL AND p.user_id IS NOT NULL THEN c.user_id END) / NULLIF(COUNT(DISTINCT c.user_id), 0), 2) AS view_to_shop_pct
FROM core_events_users c
FULL OUTER JOIN product_users p ON c.user_id = p.user_id;