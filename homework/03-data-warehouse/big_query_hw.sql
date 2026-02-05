-- Question 1. Counting records
-- What is count of records for the 2024 Yellow Taxi Data?

SELECT COUNT(*) FROM `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`
-- query result: 20332093


-- Question 2. Data read estimation
-- Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
SELECT COUNT(DISTINCT PULocationID) FROM `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`
-- This query will process 155.12 MB when run.

SELECT COUNT(DISTINCT PULocationID) FROM `fit-reference-447221-v2.hw3_dataset.external_yellow_tripdata_2024`
-- This query will process 0 B when run. (because BQ doesn't know the exact size)


-- Question 3. Understanding columnar storage

-- Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery. 
SELECT PULocationID FROM `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`
-- This query will process 155.12 MB when run.

-- Now write a query to retrieve the PULocationID and DOLocationID on the same table.
SELECT PULocationID, DOLocationID from `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`
-- This query will process 310.24 MB when run.


-- Question 4. Counting zero fare trips
-- How many records have a fare_amount of 0?
SELECT 
    COUNT(*)
FROM `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`
WHERE fare_amount = 0
-- query result: 8333


-- Question 5. Partitioning and clustering
-- What is the best strategy to make an optimized table in Big Query if your query will always filter based on tpep_dropoff_datetime and order the results by VendorID (Create a new table with this strategy)
-- Partition by tpep_dropoff_datetime and Cluster on VendorID
CREATE OR REPLACE TABLE `fit-reference-447221-v2.hw3_dataset.partitioned_clustered_yellow_tripdata_2024`
PARTITION BY DATE(tpep_dropoff_datetime) 
CLUSTER BY VendorID AS
SELECT * FROM `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`;


-- Question 6. Partition benefits
-- Write a query to retrieve the distinct VendorIDs 
-- between tpep_dropoff_datetime 2024-03-01 and 2024-03-15 (inclusive)
-- Use the materialized table you created earlier in your from clause and note the estimated bytes. 
SELECT DISTINCT VendorID
FROM `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15'
-- This query will process 310.24 MB when run.

-- Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values?
SELECT DISTINCT VendorID
FROM `fit-reference-447221-v2.hw3_dataset.partitioned_clustered_yellow_tripdata_2024`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15'
-- This query will process 26.84 MB when run.

-- Question 9. Understanding table scans
-- No Points: Write a SELECT count(*) query FROM the materialized table you created. 
-- How many bytes does it estimate will be read? Why?
SELECT COUNT(*)
FROM `fit-reference-447221-v2.hw3_dataset.regular_yellow_tripdata_2024`
-- This query will process 0 B when run.
-- Because the database is retrieving the result from its metadata rather than scanning the actual data rows.