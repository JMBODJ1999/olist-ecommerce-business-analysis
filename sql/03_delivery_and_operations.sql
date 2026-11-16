/*
PART 3: Delivery and operational performance
- Delivery duration: purchase timestamp to delivered-to-customer timestamp.
- On-time delivery: actual delivery date <= estimated delivery date.
- Only delivered orders with both timestamps are included in duration/accuracy.
*/

-- 3.1 Overall delivery KPIs
WITH delivered AS (
    SELECT
        order_id,
        order_purchase_timestamp,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM "Olist_orders"
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(EXTRACT(EPOCH FROM (
        order_delivered_customer_date - order_purchase_timestamp
    )) / 86400)::numeric, 2) AS avg_purchase_to_delivery_days,
    ROUND((AVG(EXTRACT(EPOCH FROM (
        order_delivered_customer_date - order_delivered_carrier_date
    )) / 86400) FILTER (
        WHERE order_delivered_carrier_date IS NOT NULL
    ))::numeric, 2) AS avg_carrier_to_customer_days,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date::date <= order_estimated_delivery_date::date
    ) AS on_time_orders,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date::date > order_estimated_delivery_date::date
    ) AS late_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_delivered_customer_date::date <= order_estimated_delivery_date::date
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS on_time_delivery_rate_pct
FROM delivered;


-- 3.2 Delivery performance by customer state
SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(EXTRACT(EPOCH FROM (
        o.order_delivered_customer_date - o.order_purchase_timestamp
    )) / 86400)::numeric, 2) AS avg_delivery_days,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date::date <= o.order_estimated_delivery_date::date
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS on_time_delivery_rate_pct
FROM "Olist_orders" o
JOIN "Olist_customers" c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 30
ORDER BY on_time_delivery_rate_pct ASC, delivered_orders DESC;


-- 3.3 Monthly delivery performance
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS purchase_month,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(EXTRACT(EPOCH FROM (
        o.order_delivered_customer_date - o.order_purchase_timestamp
    )) / 86400)::numeric, 2) AS avg_delivery_days,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date::date > o.order_estimated_delivery_date::date
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_rate_pct
FROM "Olist_orders" o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY purchase_month;


-- 3.4 Delay between purchase, approval and carrier handoff
SELECT
    COUNT(*) FILTER (
        WHERE order_approved_at IS NOT NULL
          AND order_delivered_carrier_date IS NOT NULL
    ) AS orders_with_complete_handoff_timestamps,
    ROUND(AVG(EXTRACT(EPOCH FROM (
        order_approved_at - order_purchase_timestamp
    )) / 3600)::numeric, 2) AS avg_purchase_to_approval_hours,
    ROUND((AVG(EXTRACT(EPOCH FROM (
        order_delivered_carrier_date - order_approved_at
    )) / 3600) FILTER (
        WHERE order_approved_at IS NOT NULL
          AND order_delivered_carrier_date IS NOT NULL
    ))::numeric, 2) AS avg_approval_to_carrier_hours
FROM "Olist_orders"
WHERE order_status = 'delivered';


-- 3.5 Delivery status overview (all orders, not only delivered)
SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_of_all_orders_pct
FROM "Olist_orders"
GROUP BY order_status
ORDER BY orders DESC;
