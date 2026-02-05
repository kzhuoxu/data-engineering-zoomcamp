# Homework 3 Solution

## Load Data
0. Navigate to the hw directory.
1. Using Terraform to create the GCS bucket and BigQuery dataset
    ```
    terraform init
    terraform plan
    terraform apply
    ```
2. Fill the bucket name that just created in the script and run
    ```
    python web_to_gcs.py
    ```

## BigQuery
Navigate to BigQuery dataset we just created and run queries in `big_query_setup.sql` first, and then answer homework questions using `big_query_hw.sql`.
