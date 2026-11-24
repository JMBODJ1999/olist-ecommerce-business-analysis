/*
PART 4: Customer satisfaction
- Reviews are first aggregated to order level because 547 orders in the supplied
  dataset have more than one review row.
- Review score is on the original 1-to-5 scale.
- Delivery comparisons use delivered orders only.
*/

-- 4.1 Overall review KPIs and score distribution
SELECT
    COUNT(*) AS review_records,
    COUNT(DISTINCT order_id) AS reviewed_orders,
    ROUND(AVG(review_score)::numeric, 2) AS average_review_score,
    COUNT(*) FILTER (WHERE review_score <= 2) AS low_score_reviews,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE review_score <= 2) / NULLIF(COUNT(*), 0),
        2
    ) AS low_score_review_rate_pct
FROM "Olist_reviews";


-- 4.2 Review score distribution
SELECT
    review_score,
    COUNT(*) AS review_records,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_of_reviews_pct
FROM "Olist_reviews"
GROUP BY review_score
ORDER BY review_score;


-- 4.3 Monthly average review score
SELECT
    DATE_TRUNC('month', review_creation_date)::date AS review_month,
    COUNT(*) AS review_records,
    ROUND(AVG(review_score)::numeric, 2) AS avg_review_score
FROM "Olist_reviews"
GROUP BY DATE_TRUNC('month', review_creation_date)
ORDER BY review_month;


-- 4.4 Relationship between delivery punctuality and review score
WITH review_by_order AS (
    SELECT
        order_id,
        AVG(review_score)::numeric AS avg_review_score,
        COUNT(*) AS review_count
    FROM "Olist_reviews"
    GROUP BY order_id
),
delivery_group AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date::date <= order_estimated_delivery_date::date
                THEN 'On time'
            WHEN order_delivered_customer_date::date > order_estimated_delivery_date::date
                THEN 'Late'
            ELSE 'Unknown'
        END AS delivery_performance
    FROM "Olist_orders"
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    d.delivery_performance,
    COUNT(*) AS reviewed_orders,
    ROUND(AVG(r.avg_review_score), 2) AS avg_review_score,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE r.avg_review_score <= 2) / NULLIF(COUNT(*), 0),
        2
    ) AS low_score_order_rate_pct
FROM delivery_group d
JOIN review_by_order r USING (order_id)
GROUP BY d.delivery_performance
ORDER BY d.delivery_performance;


-- 4.5 Review score by customer state
WITH review_by_order AS (
    SELECT order_id, AVG(review_score)::numeric AS avg_review_score
    FROM "Olist_reviews"
    GROUP BY order_id
)
SELECT
    c.customer_state,
    COUNT(*) AS reviewed_orders,
    ROUND(AVG(r.avg_review_score), 2) AS avg_review_score,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE r.avg_review_score <= 2) / NULLIF(COUNT(*), 0),
        2
    ) AS low_score_order_rate_pct
FROM review_by_order r
JOIN "Olist_orders" o ON o.order_id = r.order_id
JOIN "Olist_customers" c ON c.customer_id = o.customer_id
GROUP BY c.customer_state
HAVING COUNT(*) >= 30
ORDER BY avg_review_score ASC, reviewed_orders DESC;


-- 4.6 Review response time (days between review creation and answer)
SELECT
    COUNT(*) FILTER (
        WHERE review_answer_timestamp IS NOT NULL
          AND review_creation_date IS NOT NULL
    ) AS reviews_with_response_timestamps,
    ROUND(AVG(EXTRACT(EPOCH FROM (
        review_answer_timestamp - review_creation_date
    )) / 86400)::numeric, 2) AS avg_review_response_days
FROM "Olist_reviews"
WHERE review_answer_timestamp IS NOT NULL
  AND review_creation_date IS NOT NULL;
