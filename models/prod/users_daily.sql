{{
  config(
    materialized='table'
  )
}}

WITH web_sessions AS (
  SELECT
  blended_user_id AS user_id,
  DATE(session_start_tstamp) AS session_start_date,
  COUNT(DISTINCT(session_id)) AS num_web_sessions

  FROM {{ref('segment_web_sessions')}}

  GROUP BY 1, 2
),

stg_1 AS (
  SELECT
  grid.*,
  web_sessions.num_web_sessions

  FROM {{ref('stg_users_dates_grid')}} AS grid
  LEFT JOIN web_sessions ON web_sessions.user_id = grid.user_id AND web_sessions.session_start_date = grid.date
)

SELECT
*,
IF(SUM(num_web_sessions) OVER(user_7d_rolling) > 0, TRUE, FALSE) AS is_7d_web_active,
SUM(num_web_sessions) OVER(user_7d_rolling) AS num_web_sessions_prev_7d,
SUM(num_web_sessions) OVER(user_30d_rolling) AS num_web_sessions_prev_30d,
SUM(num_web_sessions) OVER(user_cum) AS num_web_sessions_cum

FROM stg_1

WINDOW
  user_cum AS (PARTITION BY user_id ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
  user_7d_rolling AS (PARTITION BY user_id ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),
  user_30d_rolling AS (PARTITION BY user_id ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
