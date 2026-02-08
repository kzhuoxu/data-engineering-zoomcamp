-- Dimension table for taxi technology vendors

WITH trips_unioned AS (
    SELECT * FROM {{ ref('int_trips_unioned') }}
),

vendors AS (
    SELECT
        DISTINCT vendor_id,
        {{ get_vendor_data('vendor_id') }} AS vendor_name
    FROM trips_unioned
)

SELECT * FROM vendors
ORDER BY vendor_id