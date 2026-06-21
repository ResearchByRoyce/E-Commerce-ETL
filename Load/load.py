import csv
from pathlib import Path


MART_TABLES = [
    "mart_sales_summary",
    "mart_customer_summary",
    "mart_product_performance",
    "mart_delivery_performance",
]

COUNT_TABLES = [
    "raw_customers",
    "raw_geolocation",
    "raw_orders",
    "raw_order_items",
    "raw_payments",
    "raw_reviews",
    "raw_products",
    "raw_sellers",
    "raw_category_translation",
    "stg_customers",
    "stg_geolocation",
    "stg_orders",
    "stg_order_items",
    "stg_payments",
    "stg_reviews",
    "stg_products",
    "stg_sellers",
    "stg_category_translation",
    "dim_customers",
    "dim_geolocation",
    "dim_products",
    "dim_sellers",
    "dim_date",
    "fact_orders",
    "fact_order_items",
    "fact_payments",
    *MART_TABLES,
]


def export_table(connection, table_name: str, output_path: Path) -> None:
    cursor = connection.execute(f"SELECT * FROM {table_name}")
    columns = [column[0] for column in cursor.description]

    with output_path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(columns)
        writer.writerows(cursor.fetchall())


def export_row_counts(connection, output_path: Path) -> None:
    with output_path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["table_name", "row_count"])
        for table_name in COUNT_TABLES:
            count = connection.execute(
                f"SELECT count(*) FROM {table_name}"
            ).fetchone()[0]
            writer.writerow([table_name, count])


def load_all(connection, output_dir: Path) -> None:
    """Load the final reporting tables into easy-to-open CSV files."""
    print("\nLOAD")
    output_dir.mkdir(parents=True, exist_ok=True)
    export_row_counts(connection, output_dir / "row_counts.csv")
    print("  Created row_counts.csv")

    for table_name in MART_TABLES:
        export_table(connection, table_name, output_dir / f"{table_name}.csv")
        print(f"  Created {table_name}.csv")

