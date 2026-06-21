import csv
from pathlib import Path


SOURCE_FILES = {
    "raw_customers": "olist_customers_dataset.csv",
    "raw_geolocation": "olist_geolocation_dataset.csv",
    "raw_orders": "olist_orders_dataset.csv",
    "raw_order_items": "olist_order_items_dataset.csv",
    "raw_payments": "olist_order_payments_dataset.csv",
    "raw_reviews": "olist_order_reviews_dataset.csv",
    "raw_products": "olist_products_dataset.csv",
    "raw_sellers": "olist_sellers_dataset.csv",
    "raw_category_translation": "product_category_name_translation.csv",
}


def load_csv_to_table(connection, table_name: str, csv_path: Path) -> int:
    """Read one CSV file and insert its rows into a raw database table."""
    if not csv_path.exists():
        raise FileNotFoundError(f"Missing source file: {csv_path}")

    total_rows = 0
    with csv_path.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        columns = reader.fieldnames or []
        placeholders = ", ".join(["?"] * len(columns))
        column_names = ", ".join(columns)
        insert_sql = (
            f"INSERT INTO {table_name} ({column_names}) "
            f"VALUES ({placeholders})"
        )

        batch = []
        for row in reader:
            batch.append([row.get(column) for column in columns])
            if len(batch) == 10000:
                connection.executemany(insert_sql, batch)
                total_rows += len(batch)
                batch = []

        if batch:
            connection.executemany(insert_sql, batch)
            total_rows += len(batch)

    return total_rows


def extract_all(connection, data_dir: Path) -> None:
    """Extract every source CSV into its matching raw table."""
    print("\nEXTRACT")
    for table_name, file_name in SOURCE_FILES.items():
        row_count = load_csv_to_table(connection, table_name, data_dir / file_name)
        print(f"  {file_name} -> {table_name}: {row_count} rows")

