-- Aggregates item-level purchases without duplicating session data.
SELECT 
  item_category,
  SUM(item_quantity) AS total_units_sold,
  SUM(item_quantity * item_price) AS total_category_revenue
FROM fct_product_interactions
WHERE event_name = 'purchase'
GROUP BY item_category
ORDER BY total_category_revenue DESC;