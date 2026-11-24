# Olist E-commerce Business Analysis

An end-to-end SQL portfolio project analysing Olist's Brazilian e-commerce marketplace across four business dimensions: commercial performance, customer behaviour, delivery operations, and customer satisfaction.

## Project objective

Turn raw transactional data into actionable business insights. The analysis is designed around questions a business manager could ask:

1. How are sales and order volumes evolving?
2. How frequently do customers return, and how is customer value distributed?
3. Where does delivery performance fall short?
4. How is customer satisfaction associated with delivery experience?

## Dataset

The project currently uses six Olist CSV datasets:

| Dataset | Rows | Analytical use |
|---|---:|---|
| Customers | 99,441 | Customer identity and state |
| Geolocation | 1,000,163 | Geographic reference data |
| Order items | 112,650 | Product prices and freight |
| Order payments | 103,886 | Payment methods and payment values |
| Order reviews | 99,224 | Review scores and response timestamps |
| Orders | 99,441 | Order status and lifecycle timestamps |

The supplied order data spans 4 September 2016 to 17 October 2018.

**Scope note:** The supplied files do not include the products, sellers or product-category translation datasets. Therefore, this version does not claim product-category or seller-level findings. Geolocation is available for possible later mapping, but the first SQL release uses customer state for geographic comparisons.

## Repository structure

```text
olist-ecommerce-business-analysis/
├── README.md
├── sql/
│   ├── 01_commercial_performance.sql
│   ├── 02_customer_behaviour.sql
│   ├── 03_delivery_and_operations.sql
│   └── 04_customer_satisfaction.sql
└── docs/
    └── data_dictionary.md
```

## Tools

- PostgreSQL
- Supabase (database hosting)
- SQL
- Power BI (planned dashboard layer)

## Database setup and table names

The SQL scripts are written for PostgreSQL and currently expect these quoted table names:

- `"Olist_orders"`
- `"Olist_items"`
- `"Olist_payments"`
- `"Olist_customers"`
- `"Olist_reviews"`
- `"Olist_geolocation"`

The source columns retain the original Olist CSV names. If your Supabase tables use different names or casing, update the `FROM`/`JOIN` identifiers before execution.

## Analytical sections

### 1. Commercial performance
- Delivered order volume
- Product revenue and freight value
- Monthly revenue trend and month-over-month change
- Sales by customer state
- Payment method mix
- Reconciliation of item value, freight and payment value

### 2. Customer behaviour
- Unique purchasing customers
- Repeat-customer rate
- Orders per customer
- Monthly active customers
- Customer revenue quartiles
- First-purchase cohort activity

### 3. Delivery and operations
- Purchase-to-delivery duration
- Carrier-to-customer duration
- On-time delivery rate
- Delivery performance by state and month
- Purchase approval and carrier handoff delays
- Order-status distribution

### 4. Customer satisfaction
- Average review score
- Review score distribution
- Low-score review rate
- Monthly review trends
- Review scores by delivery punctuality
- Review scores by customer state
- Review response time

## Metric definitions and data safeguards

- **Product revenue:** sum of `price` from order-item rows. Freight is shown separately.
- **Delivered orders:** orders whose `order_status = 'delivered'` for completed-sales and delivered-customer analysis.
- **Customer:** `customer_unique_id` for repeat-purchase analysis; `customer_id` is the order-level customer record.
- **On-time delivery:** `order_delivered_customer_date` is on or before `order_estimated_delivery_date`.
- **Average review score:** average of the supplied 1-to-5 review score.
- **Join fan-out:** order items and payments can have multiple rows per order. Aggregate them to order level before joining to avoid multiplying amounts.
- **Multiple reviews:** review data contains multiple review rows for some orders. The satisfaction scripts aggregate reviews to order level for order-level comparisons.
- **Missing timestamps:** delivery-duration calculations exclude records missing the required timestamps.

## Data quality observations from the supplied files

- 99,441 order rows and 99,441 distinct order IDs.
- 98,666 distinct orders appear in the order-items dataset.
- 99,440 distinct orders appear in payments.
- 98,673 distinct orders appear in reviews.
- 96,478 orders have `delivered` status.
- 96,096 distinct `customer_unique_id` values appear in the customer table.
- The orders table contains missing approval and delivery timestamps; these are not treated as zero-duration events.

## Current status

This is the first SQL draft generated from the six supplied CSVs. It must be executed against the user's Supabase database and validated against the actual imported table names and results before being described as fully tested. Business conclusions and dashboard screenshots will be added after query execution and result interpretation.
