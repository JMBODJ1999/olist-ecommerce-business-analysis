/*
PART 2: Customer behaviour
Metric convention:
- customer_unique_id identifies a real customer across potentially multiple
  customer_id/order records.
- Delivered orders only are used for completed purchase behaviour.
- Revenue is item price; freight is excluded from customer product spend.
*/

-- 2.1 Customer base and repeat-purchase KPIs
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        SUM(i.price) AS order_product_revenue
    FROM "Olist_orders" o
    JOIN "Olist_customers" c ON c.customer_id = o.customer_id
    JOIN "Olist_items" i ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, o.order_id, o.order_purchase_timestamp
),
customer_summary AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(order_product_revenue) AS lifetime_product_revenue
    FROM customer_orders
    GROUP BY customer_unique_id
)
SELECT
    COUNT(*) AS unique_purchasing_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE order_count > 1) / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_pct,
    ROUND(AVG(order_count::numeric), 2) AS avg_orders_per_customer,
    ROUND(AVG(lifetime_product_revenue)::numeric, 2) AS avg_lifetime_product_revenue
FROM customer_summary;


-- 2.2 Distribution of orders per customer
WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM "Olist_orders" o
    JOIN "Olist_customers" c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    order_count,
    COUNT(*) AS number_of_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_share_pct
FROM customer_order_counts
GROUP BY order_count
ORDER BY order_count;


-- 2.3 Monthly active purchasing customers and orders
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS purchase_month,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    COUNT(DISTINCT o.order_id) AS delivered_orders
FROM "Olist_orders" o
JOIN "Olist_customers" c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY purchase_month;


-- 2.4 Customer revenue segmentation (quartiles by lifetime product revenue)
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(i.price) AS lifetime_product_revenue
    FROM "Olist_orders" o
    JOIN "Olist_customers" c ON c.customer_id = o.customer_id
    JOIN "Olist_items" i ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
segmented AS (
    SELECT
        customer_unique_id,
        lifetime_product_revenue,
        NTILE(4) OVER (ORDER BY lifetime_product_revenue) AS revenue_quartile
    FROM customer_revenue
)
SELECT
    revenue_quartile,
    COUNT(*) AS customers,
    ROUND(AVG(lifetime_product_revenue)::numeric, 2) AS avg_customer_revenue,
    SUM(lifetime_product_revenue) AS quartile_revenue
FROM segmented
GROUP BY revenue_quartile
ORDER BY revenue_quartile;


-- 2.5 Customer acquisition cohorts by first delivered purchase month
WITH delivered_customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
        ))::date AS cohort_month
    FROM "Olist_orders" o
    JOIN "Olist_customers" c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
)
SELECT
    cohort_month,
    DATE_TRUNC('month', order_purchase_timestamp)::date AS activity_month,
    (
        EXTRACT(YEAR FROM AGE(
            DATE_TRUNC('month', order_purchase_timestamp),
            cohort_month
        )) * 12
        + EXTRACT(MONTH FROM AGE(
            DATE_TRUNC('month', order_purchase_timestamp),
            cohort_month
        ))
    )::int AS months_since_first_purchase,
    COUNT(DISTINCT customer_unique_id) AS active_customers
FROM delivered_customer_orders
GROUP BY cohort_month, DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY cohort_month, activity_month;
