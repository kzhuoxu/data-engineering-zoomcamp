# dbt Learning Notes

## Project Structure
- `analyses`: for sql files, use it for data quality reports, people dont use it
- `dbt_project.yml`:  defaults for dbt, need it to run dbt commands
- `macros`: behave like python functions, e.g. tax rates conversion, definition changes
- `README.md`: documentation, installation/setup guide, contacts
- `seeds`: to upload csv and flat files to add them to dbt later, quick and dirty approach (don’t use it)
- `snapshots`: snapshot of a table at a moment in time, track history of a column that overwrites itself
- `tests`: put assertions in SQL format, singular tests,
    - if this SQL command returns more than 0 rows. the dbt build fails
- `models`: 3 sub folders
    - `staging`:
        - sources (raw table from database)
        - staging files: 1 to 1 copy of data with minimal cleaning (data types, renaming columns), same # of rows, # of columns
    - `intermediate`:  anything not in the other two categoreis
    - `marts`: ready for consumption, for dashboards, properly modeled, clean tables

## dbt Sources
1. In `models/staging/sources.yaml`, source GCP project and BigQuery dataset and tables.
2. Stage source tables in `models/staging/stg_{dataset}.sql` using
    ```sql
    with source as (
        select * from {{ source('<source-name>', '<source-table>') }}
    ),
    ```
3. Minimally clean the data
    - changing data types
    - renaming column names to fit naming conventions
    - grouping columns
    - filtering out records with null vendor_id (data quality requirement)

## dbt Models
1. In `models/marts`, plan mart layer structure, create placeholder files for
    - dashboards in `models/marts/reporting`  
        - e.g. monthly revenue per location
    - dimensional models in `models/marts` 
        - Fact tables `fct_trips.sql`
            - measurements, metrics or facts
            - corresponds to a business process
            - “verbs”
        - Dimension tables `dim_locations.sql` `dim_vendors.sql`
            - corresponds to a business entity
            - provides context to a business process
            - “nouns”
2. Understand business context
3. Use `models/intermediate` to process dataset
    - handling discrepancy
    - union dataset
4. Use ref() to reference models, source() only used in staging
    ```sql
    select * from {{ ref('stg_green_tripdata') }}
    ```

## dbt Seeds
1. In `seeds`, put down the lookup file (small and non-confidential) `seeds/taxi_zone_lookup.csv`, and run to make them accessible to dbt
    ```bash
    dbt seed
    ```
2. Access the seed in other model using
    ```sql
    select * from {{ ref('taxi_zone_lookup') }}
    ```

## dbt Macros
1. In `macros`, write resuable sql functions
    ```sql
    {% macro get_vendor_name(vendor_id) -%}
        case
            when {{vendor_id}} = 1 then 'Creative Mobile Technologies, LLC'
            when {{vendor_id}} = 2 then 'VeriFone Inc.'
            when {{vendor_id}} = 4 then 'Unknown'
        end
    {%- endmacro %}
    ```
2. Use the defined sql functions in models
    ```sql
    select 
        distinct vendor_id, -- the function variable
        {{ get_vendor_names('vendor_id') }}  -- calling the function
    from {{ ref('stg_green_tripdata') }}
    ```

## dbt Documentation
- Using `schema.yaml` to document everything
    - name, description, columns...
- Using `dbt docs generate` to generate `./target/catalog.json`
    - command `dbt docs serve` to host the documentation website

## dbt Tests
- singular test 
    - For custom SQL-based validation of business logic
    - in `tests/assert_{}.sql`: error = more than 0 rows returned
- source freshness test 
    - To monitor the timeliness of your source data
    - Defined in `.yaml`: by adding a freshness flag, and the field indicating when the data was loaded 
        ```yaml
        sources:
            - name: nyc_taxi_trips
            freshness: # default
                warn_after: (count: 12, period: hour)
                error_after: (count: 24, period: hour)
            tables:
                - name: yellow_tripdata
                freshness: null # don't check for this table
        ```
    - You test them by running the `dbt source freshness`  command in the command line
- generic test 
    - Common data validation checks to ensure data quality and referential integrity
    - Use in dbt documentation yaml file for models
        - dbt ships with 4 built-in types: `unique`, `not_null`, `accepted_values`, and `relationships` 
        - custom generic tests in `tests/generic/warn_if_odd.sql`: 
            ```sql 
            {% test warn_if_odd(model, column_name) %}
                {{ config(severity="warn") }}
                select
                    {{ column_name }}
                from {{ model }}
                where {{ column_name }} % 2 <> 0
            {% endtest %}   
            ```
- unit test
    - To defensively test complex SQL logic, especially with rolling windows or regular expressions. 
    - This allows you to test how models behave with specific inputs before encountering real data issues
    - define input data as "fixtures" and specify the expected output 
        ```yaml
        unit_tests:
            - name: test_is_valid_email
              model: 
              given:
                - input: ref('')
                  rows: 
                    - {email: xxx@yyy.com}
              expect: 
                rows: 
                    - {email: xxx@yyy.com, is_valid: true}
        ```
- model contracts: 
    - To enforce data types and constraints, ensuring that incoming data matches predefined agreements with stakeholders
    - Within the model's config block in YAML
        ```yaml
        model:
            - name: 
            config: 
                contract: 
                    enforced: true
            columns:
                - name:
                  data_type:
                  constraints:S
                    - type: not_null
        ```

## dbt Packages
Like python packages: https://hub.getdbt.com/ 
1. create a `./package.yml` file to indicate which pacakge to use
2. run command `dbt deps` to install the packages

## dbt Commands
- Project Setup Commands 
    - `dbt init:` Initializes a `dbt` project and creates the necessary directory structure for `models`, `seeds`, `snapshots`, and `tests`.
    - `dbt debug`: Checks the `profiles.yml` file to ensure a valid connection to the database.
    - `dbt deps`: Reinstalls project dependencies.
    - `dbt clean`: Deletes compiled files and packages from the dbt project, with configurable clean targets.

- Documentation and Feature Commands
    - `dbt seed`: Ingests CSV files located in the `seeds` folder into the database.
    - `dbt snapshot`: Used for managing snapshots, though not demonstrated in this video.
    - `dbt source freshness`: Checks the freshness of data sources if specified.
    - `dbt docs generate`: Creates a `catalog.json` artifact, used to build the dbt documentation website.
    - `dbt docs serve`: Allows browsing the generated documentation website locally. (Note: dbt Cloud handles this automatically.)

- Core Workflow Commands 
    - `dbt compile`: Takes dbt models with Jinja and `ref/source` statements and compiles them into pure SQL files for the database, useful for spotting Jinja errors quickly.
    - `dbt run`: Materializes every model in the dbt project, defaulting to views unless otherwise specified (e.g., table, incremental, ephemeral).
    - `dbt test`: Runs all tests within the dbt project (unit, generic, singular tests).
    - `dbt build`: A smart, all-in-one command that combines `dbt run`, `dbt test`, `dbt seed`, and `dbt snapshot`. It intelligently orders operations and stops on failures, skipping dependent computations.
    - `dbt retry`: Restarts a failed dbt build or dbt run from the point of failure, saving compute resources.

- Advanced Important Flags
    - `--help` or `-h`: Provides an overview of command possibilities.
    - `--version` or `-v`: Displays the installed dbt version.
    - `--full-refresh`: When used with `dbt run`, it drops and reloads incremental models from scratch, useful for handling historical data changes or duplicates.
    - `--fail-fast`: Makes dbt runs stricter by failing on warnings, ideal for rigorous testing.
    - `--target` or `-t`: Allows switching between different dbt targets (e.g., dev vs. prod), overriding the default target.

- Model Selection with Upstream/Downstream Dependencies 
    - `dbt run --select <model_name>` or `dbt run -s`: Runs only a specific model.
    - `dbt run -s +<model_name>`: Builds the specified model and all its upstream dependencies.
    - `dbt run -s <model_name>+`: Builds the specified model and all its downstream dependencies.
    - `dbt run -s +<model_name>+`: Builds the specified model and both its upstream and downstream dependencies.
    - `dbt run -s <dir_name>` also supports selecting models by location (e.g., models/intermediate) or by tags.

- Advanced: State-based Deployments and Artifacts
    - `dbt run -s state:modified` dbt can use state (e.g., new for newly created files or modified for changed files) to run only relevant models, crucial for CI/CD workflows.
    - For dbt Core users, this requires manually copying dbt artifacts (JSON files like `manifest.json`) to a separate location, as these files contain information about previous runs.
    - The `--state` flag then points to the location of these copied artifacts to enable comparison and detection of changes.