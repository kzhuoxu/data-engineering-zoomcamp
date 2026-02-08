-- Data mart for monthly revenue analysis by pickup zone and service type
-- This aggregation is optimized for business reporting and dashboards
-- Enables analysis of revenue trends across different zones and taxi types

SELECT
    -- Grouping dimensions
    COALESCE(pickup_zone, 'Unknown Zone') AS pickup_zone,
    CAST(DATE_TRUNC(pickup_datetime, MONTH) AS DATE) AS revenue_month, -- using BigQuery
    service_type,

    -- Revenue breakdown
    SUM(fare_amount) AS revenue_monthly_fare,
    SUM(extra) AS revenue_monthly_extra,
    SUM(mta_tax) AS revenue_monthly_mta_tax,
    SUM(tip_amount) AS revenue_monthly_tip_amount,
    SUM(tolls_amount) AS revenue_monthly_tolls_amount,
    SUM(ehail_fee) AS revenue_monthly_ehail_fee,
    SUM(improvement_surcharge) AS revenue_monthly_improvement_surcharge,
    SUM(total_amount) AS revenue_monthly_total_amount,

    -- Additional metrics for operational analsysis
    COUNT(trip_id) AS total_monthly_trips,
    AVG(passenger_count) AS avg_monthly_passenger_count,
    AVG(trip_distance) AS avg_monthly_trip_distance

FROM {{ ref('fct_trips') }}
GROUP BY
    pickup_zone,
    revenue_month,
    service_type

