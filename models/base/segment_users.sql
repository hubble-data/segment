WITH source AS (
    SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY timestamp ASC) AS rank

    FROM {{var('segment_users_table')}}
),

SELECT
*

FROM source

WHERE rank = 1
