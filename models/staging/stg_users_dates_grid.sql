{{
  config(
    materialized='table'
  )
}}

WITH user_activated AS (
  SELECT
  user_id,
  user_activated_date

  FROM {{ref('base_segment_users')}}
)

SELECT
d.*,
user_activated.user_id,
user_activated.user_activated_date,
DATE_DIFF(d.date, user_activated.user_activated_date, DAY) AS days_since_activated

FROM
(SELECT * FROM {{ ref('base_dates_standard') }} WHERE date < current_date()) AS d
CROSS JOIN user_activated
LEFT JOIN {{ ref('base_dates_standard') }} AS d2 ON DATE(TIMESTAMP(user_activated.user_activated_date)) = d2.date

WHERE user_activated.user_activated_date <= d.date -- in general it's safe to extend those dates backwards, it doesn't change any key stats as we look only at activated users later on
and d.date < current_date()
