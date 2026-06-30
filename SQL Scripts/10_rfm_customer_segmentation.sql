-- Uses NTILE to bucket users into quartiles based on Recency, Frequency, and Monetary value.
WITH user_rfm_metrics AS (
  SELECT 
    user_id,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - MAX(event_time))) AS recency_days,
    COUNT(DISTINCT transaction_id) AS frequency_count,
    SUM(revenue_usd) AS monetary_total
  FROM fct_events
  WHERE revenue_usd IS NOT NULL
  GROUP BY user_id
),
rfm_scores AS (
  SELECT 
    user_id,
    NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(4) OVER (ORDER BY frequency_count ASC) AS f_score,
    NTILE(4) OVER (ORDER BY monetary_total ASC) AS m_score
  FROM user_rfm_metrics
)
SELECT 
  user_id,
  CASE 
    WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'VIP Champion'
    WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk Customer'
    WHEN m_score >= 3 THEN 'High Spender'
    ELSE 'Low Engagement'
  END AS segment_profile
FROM rfm_scores;