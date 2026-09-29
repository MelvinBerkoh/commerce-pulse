import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


load_dotenv()


def main() -> None:
    database_url = os.getenv("DATABASE_URL")

    if not database_url:
        raise ValueError("DATABASE_URL is not configured.")

    engine = create_engine(database_url)

    with engine.connect() as connection:
        database_name = connection.execute(
            text("SELECT current_database();")
        ).scalar_one()

        postgres_version = connection.execute(
            text("SELECT version();")
        ).scalar_one()

    print("Database connection successful.")
    print(f"Database: {database_name}")
    print(f"PostgreSQL: {postgres_version}")


if __name__ == "__main__":
    main()
