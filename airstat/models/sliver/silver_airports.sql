WITH s_airports AS (
    SELECT *
    FROM {{ ref('src_airport') }}
)

SELECT
    *,
    CURRENT_TIMESTAMP() AS silver_created_at
FROM s_airports