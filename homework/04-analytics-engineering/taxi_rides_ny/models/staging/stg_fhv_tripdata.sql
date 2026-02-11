with source as (
    select * from {{ source('raw_data', 'fhv_tripdata') }}
),

-- Rename fields to match your project's naming conventions (e.g., `PUlocationID` → `pickup_location_id`)
renamed as (
    select
        -- identifiers
        dispatching_base_num,
        cast(PUlocationID as integer) as pickup_location_id,
        cast(DOlocationID as integer) as dropoff_location_id,

        -- timestamps
        cast(pickup_datetime as timestamp) as pickup_datetime, 
        cast(dropOff_datetime as timestamp) as dropoff_datetime,

        -- trip info
        coalesce(cast(SR_Flag as integer), 0) as sr_flag,
        Affiliated_base_number as affiliated_base_number

    from source
    -- Filter out records where `dispatching_base_num IS NULL`
    where dispatching_base_num is not null
)

select * from renamed

-- Sample records for dev environment using deterministic date filter
{% if target.name == 'dev' %}
where pickup_datetime >= '2019-01-01' and pickup_datetime < '2019-02-01'
{% endif %}

{% if target.name == 'prod' %}
where pickup_datetime >= '2019-01-01' and pickup_datetime < '2020-01-01'
{% endif %}