-- Merges distinct fact tables to track users through the primary e-commerce flow.
WITH combined_funnel_stages AS (
  SELECT session_id, event_name FROM fct_events
  UNION ALL
  SELECT session_id, event_name FROM fct_product_interactions
),
session_flags AS (
  SELECT 
    session_id,
    MAX(CASE WHEN event_name = 'page_view' THEN 1 ELSE 0 END) AS step_view_page,
    MAX(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS step_view_item,
    MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS step_add_cart,
    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS step_purchase
  FROM combined_funnel_stages
  GROUP BY session_id
)
SELECT 
  SUM(step_view_page) AS total_sessions,
  SUM(step_view_item) AS product_views,
  SUM(step_add_cart) AS cart_adds,
  SUM(step_purchase) AS purchases,
  ROUND(100.0 * SUM(step_view_item) / NULLIF(SUM(step_view_page), 0), 2) AS page_to_item_pct,
  ROUND(100.0 * SUM(step_add_cart) / NULLIF(SUM(step_view_item), 0), 2) AS item_to_cart_pct,
  ROUND(100.0 * SUM(step_purchase) / NULLIF(SUM(step_add_cart), 0), 2) AS cart_to_purchase_pct
FROM session_flags;