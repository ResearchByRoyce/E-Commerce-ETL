import os
import sqlite3
from datetime import datetime
from pathlib import Path

from Extract.extract import extract_all
from Load.load import load_all
from Transform.transform import transform_all


PROJECT_ROOT = Path(__file__).resolve().parent
DATA_DIR = Path(
    os.environ.get(
        "ECOMMERCE_DATA_DIR",
        PROJECT_ROOT / "Dataset" / "Raw-Dataset" / "E-Commerce",
    )
)
SCHEMA_DIR = PROJECT_ROOT / "Schemas"
OUTPUT_DIR = PROJECT_ROOT / "Output"
DATABASE_PATH = OUTPUT_DIR / "ecommerce_etl.db"


def date_diff_days(later_value, earlier_value):
    """Return the whole-day difference between two date-time strings."""
    if not later_value or not earlier_value:
        return None
    later = datetime.fromisoformat(later_value[:19])
    earlier = datetime.fromisoformat(earlier_value[:19])
    return (later.date() - earlier.date()).days


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    if DATABASE_PATH.exists():
        DATABASE_PATH.unlink()

    connection = sqlite3.connect(DATABASE_PATH)
    connection.create_function("date_diff_days", 2, date_diff_days)

    try:
        raw_schema = (SCHEMA_DIR / "01_raw_tables.sql").read_text(encoding="utf-8")
        connection.executescript(raw_schema)

        print("OLIST E-COMMERCE ETL PIPELINE")
        print(f"Source: {DATA_DIR}")
        extract_all(connection, DATA_DIR)
        transform_all(connection, SCHEMA_DIR)
        load_all(connection, OUTPUT_DIR)
        connection.commit()
    finally:
        connection.close()

    print(f"\nFinished. Open the CSV files in: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()

