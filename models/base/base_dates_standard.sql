WITH date_array AS (
    SELECT
    date,
    DATE_TRUNC(date, WEEK) AS week, -- week starting on Sunday
    DATE_TRUNC(date, MONTH) AS month, -- first day of month
    DATE_TRUNC(date, QUARTER) AS quarter, -- first day of quarter
    DATE_TRUNC(date, YEAR) AS year, -- first day of year
    EXTRACT(DAYOFWEEK FROM date) AS day_of_week, -- 1-7 index, 1 being Sunday
    EXTRACT(DAY FROM date) AS day_of_month,
    EXTRACT(DAYOFYEAR FROM date) AS day_of_year,
    EXTRACT(WEEK FROM date) AS week_of_year, -- dates before first Sunday of year are week 0
    EXTRACT(MONTH FROM date) AS month_of_year,
    EXTRACT(QUARTER FROM date) AS quarter_of_year,
    EXTRACT(YEAR FROM date) AS year_extract,

    FROM UNNEST(GENERATE_DATE_ARRAY(
            '2015-01-01',
            DATE_ADD(CURRENT_DATE(), INTERVAL 1500 DAY),
            INTERVAL 1 DAY
        )
    ) AS date
),

add_date_intervals AS (
    SELECT
    date,
    week,
    DATE_ADD(week, INTERVAL 6 DAY) AS week_lastday,
    month,
    DATE_SUB(DATE_ADD(month, INTERVAL 1 MONTH), INTERVAL 1 DAY) AS month_lastday,
    quarter,
    DATE_SUB(DATE_ADD(quarter, INTERVAL 1 QUARTER), INTERVAL 1 DAY) AS quarter_lastday, -- last day of quarter
    year,
    DATE_SUB(DATE_ADD(year, INTERVAL 1 YEAR), INTERVAL 1 DAY) AS year_lastday, -- last day of year

    day_of_week,
    day_of_month,
    day_of_year,
    week_of_year,
    month_of_year,
    quarter_of_year,
    year_extract,

    IF(day_of_week IN (1,7), TRUE, FALSE) AS is_weekend,
    IF(week = DATE_TRUNC(CURRENT_DATE(), WEEK), TRUE, FALSE) AS is_partial_week,
    IF(month = DATE_TRUNC(CURRENT_DATE(), MONTH), TRUE, FALSE) AS is_partial_month

    FROM date_array
)

SELECT
*
FROM add_date_intervals
