{{
  config(
    materialized='table'
  )
}}

SELECT
*

FROM {{ref('users_daily')}}

WHERE date = (SELECT MAX(date) FROM {{ ref("users_daily") }})
