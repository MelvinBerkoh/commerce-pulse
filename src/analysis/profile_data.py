from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"
REPORTS_DIR = PROJECT_ROOT / "reports"

REPORTS_DIR.mkdir(parents=True, exist_ok=True)


def profile_dataset(file_path: Path) -> dict:
    """Return basic profiling information for a CSV dataset."""

    dataframe = pd.read_csv(file_path)

    total_rows = len(dataframe)
    total_columns = len(dataframe.columns)
    duplicate_rows = dataframe.duplicated().sum()

    missing_values = int(dataframe.isna().sum().sum())
    total_cells = total_rows * total_columns

    missing_percentage = (
        (missing_values / total_cells) * 100 if total_cells else 0
    )

    return {
        "dataset": file_path.name,
        "rows": total_rows,
        "columns": total_columns,
        "duplicate_rows": int(duplicate_rows),
        "missing_values": missing_values,
        "missing_percentage": round(missing_percentage, 2),
    }


def print_column_details(file_path: Path) -> None:
    """Print column names, data types, uniqueness, and null counts."""

    dataframe = pd.read_csv(file_path)

    print(f"\n{'=' * 80}")
    print(file_path.name)
    print("=" * 80)

    details = pd.DataFrame(
        {
            "column": dataframe.columns,
            "dtype": dataframe.dtypes.astype(str).values,
            "non_null": dataframe.notna().sum().values,
            "null_count": dataframe.isna().sum().values,
            "unique_values": dataframe.nunique(dropna=True).values,
        }
    )

    print(details.to_string(index=False))


def main() -> None:
    csv_files = sorted(RAW_DATA_DIR.glob("*.csv"))

    if not csv_files:
        raise FileNotFoundError(
            f"No CSV files found in {RAW_DATA_DIR}. "
            "Add the Olist datasets before running this script."
        )

    profiles = []

    for file_path in csv_files:
        profiles.append(profile_dataset(file_path))
        print_column_details(file_path)

    summary = pd.DataFrame(profiles)

    output_path = REPORTS_DIR / "data_profile_summary.csv"
    summary.to_csv(output_path, index=False)

    print(f"\n{'=' * 80}")
    print("DATASET SUMMARY")
    print("=" * 80)
    print(summary.to_string(index=False))

    print(f"\nProfile report saved to:")
    print(output_path)


if __name__ == "__main__":
    main()
