import os
from pathlib import Path

import psycopg2
from dotenv import load_dotenv


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"
SCHEMA_FILE = PROJECT_ROOT / "sql" / "create_raw_schema.sql"

load_dotenv(PROJECT_ROOT / ".env")


DATASETS = {
    "olist_customers_dataset.csv": "raw.customers",
    "olist_geolocation_dataset.csv": "raw.geolocation",
    "olist_order_items_dataset.csv": "raw.order_items",
    "olist_order_payments_dataset.csv": "raw.order_payments",
    "olist_order_reviews_dataset.csv": "raw.order_reviews",
    "olist_orders_dataset.csv": "raw.orders",
    "olist_products_dataset.csv": "raw.products",
    "olist_sellers_dataset.csv": "raw.sellers",
    "product_category_name_translation.csv": (
        "raw.product_category_translation"
    ),
}


def get_connection():
    """Create and return a PostgreSQL connection."""

    database_url = os.getenv("DATABASE_URL")

    if not database_url:
        raise ValueError("DATABASE_URL is not configured.")

    return psycopg2.connect(database_url)


def create_raw_schema(connection) -> None:
    """Create the raw schema and tables."""

    sql = SCHEMA_FILE.read_text()

    with connection.cursor() as cursor:
        cursor.execute(sql)

    connection.commit()

    print("Raw schema created successfully.")


def load_csv(
    connection,
    file_path: Path,
    table_name: str,
) -> None:
    """Load one CSV file into a PostgreSQL raw table."""

    print(f"\nLoading {file_path.name} -> {table_name}")

    with connection.cursor() as cursor:
        cursor.execute(f"TRUNCATE TABLE {table_name};")

        with file_path.open(
            "r",
            encoding="utf-8",
            newline="",
        ) as csv_file:
            copy_sql = f"""
                COPY {table_name}
                FROM STDIN
                WITH (
                    FORMAT CSV,
                    HEADER TRUE
                );
            """

            cursor.copy_expert(
                copy_sql,
                csv_file,
            )

        cursor.execute(
            f"SELECT COUNT(*) FROM {table_name};"
        )

        row_count = cursor.fetchone()[0]

    connection.commit()

    print(f"Loaded {row_count:,} rows.")


def validate_source_files() -> None:
    """Ensure all expected raw CSV files exist."""

    missing_files = []

    for filename in DATASETS:
        file_path = RAW_DATA_DIR / filename

        if not file_path.exists():
            missing_files.append(filename)

    if missing_files:
        missing_list = "\n".join(
            f"- {filename}"
            for filename in missing_files
        )

        raise FileNotFoundError(
            "Missing required dataset files:\n"
            f"{missing_list}"
        )


def main() -> None:
    validate_source_files()

    connection = get_connection()

    try:
        create_raw_schema(connection)

        for filename, table_name in DATASETS.items():
            file_path = RAW_DATA_DIR / filename

            load_csv(
                connection,
                file_path,
                table_name,
            )

        print("\n" + "=" * 80)
        print("RAW DATA INGESTION COMPLETE")
        print("=" * 80)
        print(
            f"Successfully loaded "
            f"{len(DATASETS)} datasets."
        )

    except Exception:
        connection.rollback()
        raise

    finally:
        connection.close()


if __name__ == "__main__":
    main()
