# Homework 2 Solution

## Docker Setup
First, configure the environment setup in `docker-compose.yaml` by adding `env_file: - .env` in the kestra service section. Refer to https://github.com/kestra-io/docs/issues/2068, create a `.env` file, write `SECRET_GCP_CREDS=` and copy paste in the generated base 64 encoded string using this command:

```
cat service-account.json | base64 -w 0
```

Then, navigate to the directory and run:
    ```
    docker compose up -d
    ```

## Run Kestra Flow
Open up `localhost:8080`, enter username `admin@kestra.io` and password `Admin1234`. Go to Flows and import flow `gcp_kv.yaml` and `gcp_taxi_scheduled.yaml` file. Using the backfill feature, run the flow to process both green and yellow taxi trip datasets from `2019-01-01` to `2021-08-01`. 