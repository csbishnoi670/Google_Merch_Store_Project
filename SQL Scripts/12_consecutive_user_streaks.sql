-- Uses dynamic interval subtraction to group uninterrupted consecutive active days.
WITH unique_user_days AS (
  SELECT DISTINCT user_id, event_time::date AS login_date
  FROM fct_events
),
ranked_login_dates AS (
  SELECT 
    user_id, 
    login_date,
    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date) AS date_rank
  FROM unique_user_days
),
streak_groups AS (
  SELECT 
    user_id, 
    login_date,
    login_date - (date_rank * INTERVAL '1 day') AS streak_island_id
  FROM ranked_login_dates
),
calculated_streaks AS (
  SELECT 
    user_id, 
    streak_island_id,
    COUNT(*) AS streak_length
  FROM streak_groups
  GROUP BY user_id, streak_island_id
)
SELECT 
  user_id,
  MAX(streak_length) AS longest_consecutive_day_streak
FROM calculated_streaks
GROUP BY user_id
ORDER BY longest_consecutive_day_streak DESC;