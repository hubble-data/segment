WITH source AS (
    SELECT
    * EXCEPT(timestamp),
    timestamp AS user_activated_ts
    DATE(timestamp) AS user_activated_date,
    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY timestamp ASC) AS rank

    FROM {{var('segment_users_table')}}
),

SELECT
* EXCEPT(rank)

FROM source

WHERE rank = 1
