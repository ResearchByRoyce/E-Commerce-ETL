from pathlib import Path


TRANSFORM_FILES = [
    "02_staging_tables.sql",
    "03_dimension_tables.sql",
    "04_fact_tables.sql",
    "05_marts.sql",
]


def transform_all(connection, schema_dir: Path) -> None:
    """Run the SQL cleaning, warehouse, and reporting steps."""
    print("\nTRANSFORM")
    for file_name in TRANSFORM_FILES:
        sql = (schema_dir / file_name).read_text(encoding="utf-8")
        connection.executescript(sql)
        print(f"  Ran {file_name}")

