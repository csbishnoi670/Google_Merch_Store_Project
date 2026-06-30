-- Ranks the top 3 spenders inside every single geographic city.
WITH user_regional_spend AS (
  SELECT 
    fe.user_id,
    ds.country,
    ds.city,
    SUM(fe.revenue_usd) AS total_spend
  FROM fct_events fe
  INNER JOIN dim_sessions ds ON fe.session_id = ds.session_id
  WHERE fe.revenue_usd > 0
  GROUP BY fe.user_id, ds.country, ds.city
),
ranked_users AS (
  SELECT 
    user_id,
    country,
    city,
    total_spend,
    DENSE_RANK() OVER(PARTITION BY country, city ORDER BY total_spend DESC) AS ranking
  FROM user_regional_spend
)
SELECT * FROM ranked_users 
WHERE ranking <= 3
ORDER BY country, city, ranking;