import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"

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


def get_engine():
    """Create a SQLAlchemy database engine."""

    database_url = os.getenv("DATABASE_URL")

    if not database_url:
        raise ValueError("DATABASE_URL is not configured.")

    return create_engine(database_url)


def count_csv_rows(file_path: Path) -> int:
    """Count the number of data rows in a CSV file."""

    dataframe = pd.read_csv(file_path)

    return len(dataframe)


def count_database_rows(connection, table_name: str) -> int:
    """Count rows in a PostgreSQL table."""

    result = connection.execute(
        text(f"SELECT COUNT(*) FROM {table_name};")
    )

    return result.scalar_one()


def main() -> None:
    engine = get_engine()

    validation_results = []

    with engine.connect() as connection:
        for filename, table_name in DATASETS.items():
            file_path = RAW_DATA_DIR / filename

            csv_rows = count_csv_rows(file_path)
            database_rows = count_database_rows(
                connection,
                table_name,
            )

            matches = csv_rows == database_rows

            validation_results.append(
                {
                    "dataset": filename,
                    "table": table_name,
                    "csv_rows": csv_rows,
                    "database_rows": database_rows,
                    "matches": matches,
                }
            )

    results = pd.DataFrame(validation_results)

    print("\n" + "=" * 90)
    print("INGESTION VALIDATION")
    print("=" * 90)

    print(
        results.to_string(
            index=False,
        )
    )

    failed = results[results["matches"] == False]

    print("\n" + "=" * 90)

    if failed.empty:
        print("VALIDATION PASSED")
        print(
            f"All {len(results)} datasets match their "
            "PostgreSQL row counts."
        )
    else:
        print("VALIDATION FAILED")

        print(
            failed[
                [
                    "dataset",
                    "csv_rows",
                    "database_rows",
                ]
            ].to_string(index=False)
        )

        raise ValueError(
            f"{len(failed)} dataset(s) failed validation."
        )


if __name__ == "__main__":
    main()
