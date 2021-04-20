{{
  config(
    materialized='table'
  )
}}

WITH source AS (
    SELECT
    * EXCEPT(id, uuid_ts),
    id AS user_id,
    uuid_ts AS user_activated_ts,
    DATE(uuid_ts) AS user_activated_date,
    ROW_NUMBER() OVER(PARTITION BY id ORDER BY uuid_ts ASC) AS rank

    FROM {{var('segment_users_table')}}
)

SELECT
* EXCEPT(rank)

FROM source

WHERE rank = 1
