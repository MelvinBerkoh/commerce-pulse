import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine


PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = PROJECT_ROOT / "tableau" / "data"

load_dotenv(PROJECT_ROOT / ".env")


EXPORTS = {
    "fact_orders": "analytics_marts.fact_orders",
    "fact_order_items": "analytics_marts.fact_order_items",
    "dim_customers": "analytics_marts.dim_customers",
    "dim_products": "analytics_marts.dim_products",
    "dim_sellers": "analytics_marts.dim_sellers",
    "dim_date": "analytics_marts.dim_date",
}


def get_engine():
    """Create a SQLAlchemy connection to PostgreSQL."""

    database_url = os.getenv("DATABASE_URL")

    if not database_url:
        raise ValueError("DATABASE_URL is not configured.")

    return create_engine(database_url)


def export_table(engine, export_name: str, table_name: str) -> None:
    """Export one analytics mart from PostgreSQL to CSV."""

    print(f"Exporting {table_name}...")

    dataframe = pd.read_sql(
        f"SELECT * FROM {table_name};",
        engine,
    )

    output_path = OUTPUT_DIR / f"{export_name}.csv"

    dataframe.to_csv(
        output_path,
        index=False,
    )

    print(
        f"  {len(dataframe):,} rows "
        f"-> {output_path.relative_to(PROJECT_ROOT)}"
    )


def main() -> None:
    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    engine = get_engine()

    try:
        for export_name, table_name in EXPORTS.items():
            export_table(
                engine,
                export_name,
                table_name,
            )

    finally:
        engine.dispose()

    print("\nTableau exports completed successfully.")


if __name__ == "__main__":
    main()
