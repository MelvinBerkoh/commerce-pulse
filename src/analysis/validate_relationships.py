from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"


def load_csv(filename: str) -> pd.DataFrame:
    """Load a CSV file from the raw data directory."""

    return pd.read_csv(RAW_DATA_DIR / filename)


def main() -> None:
    customers = load_csv("olist_customers_dataset.csv")
    orders = load_csv("olist_orders_dataset.csv")
    order_items = load_csv("olist_order_items_dataset.csv")
    payments = load_csv("olist_order_payments_dataset.csv")
    reviews = load_csv("olist_order_reviews_dataset.csv")
    products = load_csv("olist_products_dataset.csv")
    sellers = load_csv("olist_sellers_dataset.csv")
    translations = load_csv("product_category_name_translation.csv")

    print("\n" + "=" * 80)
    print("CUSTOMER ANALYSIS")
    print("=" * 80)

    customer_order_counts = (
        customers.groupby("customer_unique_id")
        .size()
        .sort_values(ascending=False)
    )

    repeat_customers = (customer_order_counts > 1).sum()

    print(f"Customer records: {len(customers):,}")
    print(
        f"Unique customers: "
        f"{customers['customer_unique_id'].nunique():,}"
    )
    print(f"Customers with more than one order: {repeat_customers:,}")
    print(
        f"Maximum orders by one customer: "
        f"{customer_order_counts.max():,}"
    )

    print("\n" + "=" * 80)
    print("ORDER STATUS")
    print("=" * 80)

    print(orders["order_status"].value_counts().to_string())

    print("\n" + "=" * 80)
    print("ORDER RELATIONSHIPS")
    print("=" * 80)

    order_ids = set(orders["order_id"])
    item_order_ids = set(order_items["order_id"])
    payment_order_ids = set(payments["order_id"])
    review_order_ids = set(reviews["order_id"])

    orders_without_items = order_ids - item_order_ids
    orders_without_payments = order_ids - payment_order_ids
    orders_without_reviews = order_ids - review_order_ids

    print(
        f"Orders without order items: "
        f"{len(orders_without_items):,}"
    )
    print(
        f"Orders without payments: "
        f"{len(orders_without_payments):,}"
    )
    print(
        f"Orders without reviews: "
        f"{len(orders_without_reviews):,}"
    )
    print(
        f"Order items referencing unknown orders: "
        f"{len(item_order_ids - order_ids):,}"
    )
    print(
        f"Payments referencing unknown orders: "
        f"{len(payment_order_ids - order_ids):,}"
    )
    print(
        f"Reviews referencing unknown orders: "
        f"{len(review_order_ids - order_ids):,}"
    )

    print("\n" + "=" * 80)
    print("ORDERS WITHOUT ITEMS BY STATUS")
    print("=" * 80)

    no_item_orders = orders[
        orders["order_id"].isin(orders_without_items)
    ]

    print(
        no_item_orders["order_status"]
        .value_counts()
        .to_string()
    )

    print("\n" + "=" * 80)
    print("ORDERS WITHOUT PAYMENTS")
    print("=" * 80)

    no_payment_orders = orders[
        orders["order_id"].isin(orders_without_payments)
    ]

    if no_payment_orders.empty:
        print("None")
    else:
        print(
            no_payment_orders[
                [
                    "order_id",
                    "order_status",
                    "order_purchase_timestamp",
                ]
            ].to_string(index=False)
        )

    print("\n" + "=" * 80)
    print("ORDERS WITHOUT REVIEWS BY STATUS")
    print("=" * 80)

    no_review_orders = orders[
        orders["order_id"].isin(orders_without_reviews)
    ]

    print(
        no_review_orders["order_status"]
        .value_counts()
        .to_string()
    )

    print("\n" + "=" * 80)
    print("PRODUCT RELATIONSHIPS")
    print("=" * 80)

    product_ids = set(products["product_id"])
    item_product_ids = set(order_items["product_id"])

    print(
        f"Order items referencing unknown products: "
        f"{len(item_product_ids - product_ids):,}"
    )
    print(
        f"Products never appearing in order items: "
        f"{len(product_ids - item_product_ids):,}"
    )

    print("\n" + "=" * 80)
    print("SELLER RELATIONSHIPS")
    print("=" * 80)

    seller_ids = set(sellers["seller_id"])
    item_seller_ids = set(order_items["seller_id"])

    print(
        f"Order items referencing unknown sellers: "
        f"{len(item_seller_ids - seller_ids):,}"
    )
    print(
        f"Sellers never appearing in order items: "
        f"{len(seller_ids - item_seller_ids):,}"
    )

    print("\n" + "=" * 80)
    print("CATEGORY TRANSLATION")
    print("=" * 80)

    product_categories = set(
        products["product_category_name"].dropna()
    )

    translated_categories = set(
        translations["product_category_name"]
    )

    missing_translations = sorted(
        product_categories - translated_categories
    )

    print(f"Product categories: {len(product_categories):,}")
    print(
        f"Translated categories: "
        f"{len(translated_categories):,}"
    )
    print(
        f"Categories missing translations: "
        f"{len(missing_translations):,}"
    )

    if missing_translations:
        print("\nMissing category translations:")

        for category in missing_translations:
            print(f"- {category}")

    print("\n" + "=" * 80)
    print("PAYMENT GRAIN")
    print("=" * 80)

    payment_counts = (
        payments.groupby("order_id")
        .size()
        .value_counts()
        .sort_index()
    )

    print("Number of payment rows per order:")
    print(payment_counts.to_string())

    print("\n" + "=" * 80)
    print("REVIEW GRAIN")
    print("=" * 80)

    review_counts = (
        reviews.groupby("order_id")
        .size()
        .value_counts()
        .sort_index()
    )

    print("Number of review rows per order:")
    print(review_counts.to_string())

    multiple_review_orders = (
        reviews.groupby("order_id")
        .size()
        .loc[lambda counts: counts > 1]
    )

    print(
        f"\nOrders with multiple reviews: "
        f"{len(multiple_review_orders):,}"
    )


if __name__ == "__main__":
    main()
