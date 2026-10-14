WITH s_airports AS (
    SELECT *
    FROM {{ ref('src_airport') }}
)

SELECT
    *,
    CURRENT_TIMESTAMP() AS created_at
FROM s_airports