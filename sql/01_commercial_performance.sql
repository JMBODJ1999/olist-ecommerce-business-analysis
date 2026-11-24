/*
PROJECT: Olist E-commerce Business Analysis
PART 1: Commercial performance
DIALECT: PostgreSQL

Expected source tables (quoted mixed-case names):
  "Olist_orders"    - orders dataset
  "Olist_items"     - order items dataset
  "Olist_payments"  - order payments dataset
  "Olist_customers" - customers dataset

Metric conventions:
- Product sales = SUM(item price); freight is reported separately.
- Delivered orders are used for completed-sales metrics.
- Orders are counted with COUNT(DISTINCT order_id).
- Payment rows are aggregated to order level before joining to avoid fan-out.
*/

-- 1.1 Overall commercial KPIs (delivered orders)
WITH delivered_orders AS (
    SELECT order_id, customer_id, order_purchase_timestamp
    FROM "Olist_orders"
    WHERE order_status = 'delivered'
),
item_totals AS (
    SELECT
        order_id,
        SUM(price) AS product_revenue,
        SUM(freight_value) AS freight_revenue,
        COUNT(*) AS items_sold
    FROM "Olist_items"
    GROUP BY order_id
)
SELECT
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT o.customer_id) AS purchasing_customer_accounts,
    SUM(i.product_revenue) AS product_revenue,
    SUM(i.freight_revenue) AS freight_revenue,
    SUM(i.product_revenue + i.freight_revenue) AS product_plus_freight,
    SUM(i.items_sold) AS items_sold,
    ROUND(AVG(i.product_revenue)::numeric, 2) AS avg_product_revenue_per_order
FROM delivered_orders o
JOIN item_totals i USING (order_id);


-- 1.2 Monthly sales trend
WITH item_totals AS (
    SELECT order_id, SUM(price) AS product_revenue, SUM(freight_value) AS freight_revenue
    FROM "Olist_items"
    GROUP BY order_id
)
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS sales_month,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(i.product_revenue) AS product_revenue,
    SUM(i.freight_revenue) AS freight_revenue,
    ROUND(
        (
            100.0 * (
                SUM(i.product_revenue)
                - LAG(SUM(i.product_revenue)) OVER (
                    ORDER BY DATE_TRUNC('month', o.order_purchase_timestamp)
                )
            ) / NULLIF(
                LAG(SUM(i.product_revenue)) OVER (
                    ORDER BY DATE_TRUNC('month', o.order_purchase_timestamp)
                ), 0
            )
        )::numeric,
        2
    ) AS month_over_month_growth_pct
FROM "Olist_orders" o
JOIN item_totals i USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY sales_month;


-- 1.3 Sales performance by customer state
WITH item_totals AS (
    SELECT order_id, SUM(price) AS product_revenue, SUM(freight_value) AS freight_revenue
    FROM "Olist_items"
    GROUP BY order_id
)
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(i.product_revenue) AS product_revenue,
    SUM(i.freight_revenue) AS freight_revenue,
    ROUND(
        (
            SUM(i.product_revenue)::numeric
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        ),
        2
    ) AS avg_product_revenue_per_order
FROM "Olist_orders" o
JOIN "Olist_customers" c ON c.customer_id = o.customer_id
JOIN item_totals i ON i.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY product_revenue DESC;


-- 1.4 Payment method mix (aggregate payments before joining)
WITH delivered_orders AS (
    SELECT order_id
    FROM "Olist_orders"
    WHERE order_status = 'delivered'
),
payment_by_order_method AS (
    SELECT
        p.order_id,
        p.payment_type,
        SUM(p.payment_value) AS payment_amount
    FROM "Olist_payments" p
    GROUP BY p.order_id, p.payment_type
)
SELECT
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS orders_using_payment_type,
    SUM(p.payment_amount) AS payment_value,
    ROUND(
        (
            100.0 * SUM(p.payment_amount)
            / NULLIF(SUM(SUM(p.payment_amount)) OVER (), 0)
        )::numeric,
        2
    ) AS share_of_payment_value_pct
FROM payment_by_order_method p
JOIN delivered_orders d USING (order_id)
GROUP BY p.payment_type
ORDER BY payment_value DESC;


-- 1.5 Reconciliation: item value + freight vs customer payment value
-- Differences can arise from discounts, vouchers, adjustments and dataset definitions.
WITH item_totals AS (
    SELECT order_id, SUM(price) AS product_revenue, SUM(freight_value) AS freight_value
    FROM "Olist_items"
    GROUP BY order_id
),
payment_totals AS (
    SELECT order_id, SUM(payment_value) AS payment_value
    FROM "Olist_payments"
    GROUP BY order_id
)
SELECT
    COUNT(*) AS orders_with_items_and_payments,
    SUM(i.product_revenue) AS product_revenue,
    SUM(i.freight_value) AS freight_value,
    SUM(p.payment_value) AS payment_value,
    SUM(p.payment_value - (i.product_revenue + i.freight_value)) AS net_difference
FROM item_totals i
JOIN payment_totals p USING (order_id);
