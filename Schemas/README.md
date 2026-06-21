# SQL Layers

The numbered SQL files run in this order:

1. `01_raw_tables.sql` creates empty source tables.
2. `02_staging_tables.sql` cleans and standardizes the raw data.
3. `03_dimension_tables.sql` builds descriptive dimension tables.
4. `04_fact_tables.sql` builds measurable business-event tables.
5. `05_marts.sql` builds final reporting tables.

