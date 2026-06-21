# Olist E-Commerce ETL and Data Warehouse Project

## Introduction

The Olist dataset contains e-commerce data about customers, orders, products,
payments, reviews, and sellers.

This project builds a complete ETL pipeline. It takes raw CSV files,
cleans them, organizes them into fact and dimension tables, and creates simple
CSV reports for analysis.

## Project Workflow

1. **Extract** - Read the raw Olist CSV files from `Dataset/Raw-Dataset/E-Commerce`.
2. **Transform** - Clean duplicates, missing values, text, dates, and numbers with SQL.
3. **Load** - Store fact, dimension, and reporting tables in SQLite.
4. **Export** - Save the final business reports as CSV files in `Output`.

```text
Raw CSV files -> Raw tables -> Clean tables -> Fact/Dimension tables -> Reports
```

## ETL Method

### Extract

`Extract/extract.py` reads each CSV file and loads it into a raw table. Raw
tables keep the source data almost unchanged.

### Transform

`Transform/transform.py` runs the SQL files in `Schemas` in number order. The
SQL removes duplicate orders, fixes text values, converts numbers, handles
missing product categories, and calculates delivery performance.

### Load

`Load/load.py` exports the final report tables to CSV. The reports can be opened
in Excel, Power BI, Tableau, or any text editor.

## Database Schema

![Source database schema](./Schemas/Source%20Database%20Schema.png)

## Data Warehouse Schema

![Dimensional model](./Schemas/Dimensional%20Model.png)

The warehouse has three table types:

- **Dimensions** describe customers, products, sellers, dates, and locations.
- **Facts** store orders, order items, and payments.
- **Marts** answer common business questions using ready-made summaries.

## Tech Stack Used

- **Python** - controls the ETL steps
- **SQL** - cleans data and builds warehouse tables
- **SQLite** - local database included with Python
- **CSV** - source files and final reporting files
- **GitHub** - simple portfolio sharing

No external Python packages are required.

## Project Structure

```text
E-Commerce-ETL/
|-- Dataset/
|   |-- Raw-Dataset/
|   |   `-- E-Commerce/        # Original Olist CSV files
|   `-- Processed-Dataset/     # Reserved for processed files
|-- Extract/
|   `-- extract.py             # CSV files -> raw tables
|-- Transform/
|   `-- transform.py           # Runs cleaning and modeling SQL
|-- Load/
|   `-- load.py                # Final tables -> report CSV files
|-- Schemas/
|   |-- 01_raw_tables.sql
|   |-- 02_staging_tables.sql
|   |-- 03_dimension_tables.sql
|   |-- 04_fact_tables.sql
|   `-- 05_marts.sql
|-- dataflow-architecture/
|   `-- Architecture Diagram.png
|-- Output/
|-- run_pipeline.py
|-- run_pipeline.cmd
|-- requirements.txt
`-- README.md
```

## How to Run

### Windows: easiest method

Double-click `run_pipeline.cmd`.

You can also run it from Command Prompt:

```bat
run_pipeline.cmd
```

### Any operating system

From the project folder, run:

```bash
python run_pipeline.py
```

The included sample data runs immediately. To use the full Olist dataset,
replace the nine CSV files inside `Dataset/Raw-Dataset/E-Commerce` with the
files downloaded from the
[Olist dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## Output

After the pipeline finishes, open the `Output` folder:

| File | Meaning |
|---|---|
| `row_counts.csv` | Number of rows in every ETL table |
| `mart_sales_summary.csv` | Monthly orders, revenue, and average order value |
| `mart_customer_summary.csv` | Customer spending and customer segment |
| `mart_product_performance.csv` | Product sales and revenue |
| `mart_delivery_performance.csv` | Delivery speed and delay rate |

## Data Quality Checks

The pipeline demonstrates these checks:

- removes duplicate order IDs
- changes blank product categories to `unknown`
- converts prices and payments into numbers
- standardizes city and state text
- keeps missing delivery dates when an order was not delivered
- compares actual and estimated delivery dates
- records row counts after every ETL layer

## Key Analytical Questions

1. What is the monthly revenue trend?
2. Which customers spend the most?
3. Which products generate the most revenue?
4. What is the average delivery time?
5. What percentage of delivered orders are late?
