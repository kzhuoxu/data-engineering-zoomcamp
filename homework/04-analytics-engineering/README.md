# Homework 4 Solution

Built with [dbt](https://www.getdbt.com/) and Google BigQuery.

## Prerequisites
- A GCP service account key (JSON) with BigQuery access
- Raw taxi data loaded in BigQuery (dataset: `nyc_taxi_trips`, tables: `yellow_tripdata`, `green_tripdata`)

## Setup
1. Install dbt with BigQuery adapter
```bash
pip install dbt-bigquery
```
2. Check 
Ensure your profiles.yml is configured at `~/.dbt/profiles.yml` and pointing to your service account key and BigQuery project.

3. Run from the taxi_rides_ny directory
```bash
cd homework/04-analytics-engineering/taxi_rides_ny
dbt debug
dbt deps
dbt run --target prod
```

4. For HW question 6, I used Kestra to ingest fhv data to GCS Bucket. To run Kestra docker, cd to directory and run `docker compose up -d`, access `localhost:8080` to execute FHV backfill from 2019-01-01 to 2019-12-31.


