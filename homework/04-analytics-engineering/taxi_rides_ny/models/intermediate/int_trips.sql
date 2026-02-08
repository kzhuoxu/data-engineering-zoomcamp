-- Enrich and deduplicate trip data
-- Demonstrates enrichment and surrogate key generation
-- Note: Data quality analysis available in analyses/trips_data_quality.sql

WITH unioned AS (
    SELECT * FROM {{ ref('int_trips_unioned') }}
),

cleaned_and_enriched AS (
    SELECT
        -- Generate a unique trip identifier
        {{ dbt_utils.generate_surrogate_key([
            'vendor_id', 
            'pickup_datetime', 
            'pickup_location_id', 
            'service_type'
        ]) }} AS trip_id,
        
        -- Identifiers
        vendor_id,
        service_type,
        rate_code_id,

        -- Location IDs
        pickup_location_id,
        dropoff_location_id,

        -- Timestamps
        pickup_datetime,
        dropoff_datetime,

        -- Trip details
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        trip_type,

        -- Payment breakdown
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        ehail_fee,
        improvement_surcharge,
        total_amount,
        payment_type,
        -- Enriched with payment type description
        COALESCE({{ get_payment_type_description('payment_type') }}, 'Unknown') AS payment_type_description
    FROM unioned
)

SELECT * FROM cleaned_and_enriched
-- Deduplicate: if multiple trips match (same vendor, second, location, service), keep first
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY trip_id
    -- PARTITION BY vendor_id, pickup_datetime, dropoff_datetime, pickup_location_id, service_type 
    ORDER BY dropoff_datetime
) = 1

-- trips_row AS (
--     SELECT 
--         *,
--         ROW_NUMBER() OVER (
--             PARTITION BY trip_id 
--             ORDER BY trip_id) AS row_num 
--     FROM cleaned_and_enriched
-- )

-- -- Find duplicates
-- SELECT 
--     *
-- FROM trips_row
-- WHERE trip_id IN (
--     SELECT trip_id
--     FROM trips_row
--     WHERE row_num > 1
--     )
-- ORDER BY trip_id, row_num

-- duplicates is due to payment type: 
    -- dispute (4) and cash (2)
    -- no charge (3) and cash (2)
    -- credit card (1) and no charge (3)
    -- 1 and 4


/*
TODO:
- one row per trip (can be yellow or green)
- add a primary key (trip_id), unique
- find all duplicates, understand why and fix
- find a way to enrich the column payment_type
*/