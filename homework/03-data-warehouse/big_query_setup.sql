-- Create an external table using the Yellow Taxi Trip Records.
-- Data Store in GCS, BQ only have schemas
CREATE OR REPLACE EXTERNAL TABLE `fit-reference-447221-v2.hw3_dataset.external_yellow_tripdata_2024`
OPTIONS (
	format = 'PARQUET',
	uris = ['gs://fit-reference-447221-v2-hw3-bucket/yellow_trip_data_2024-*.parquet']
)

-- Create a (regular/materialized) table in BQ using the Yellow Taxi Trip Records (do not partition or cluster this table).
-- Data move from GCS to BQ, cheaper cost
CREATE OR REPLACE TABLE `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`
AS SELECT * FROM `fit-reference-447221-v2.hw3_dataset.external_yellow_tripdata_2024`