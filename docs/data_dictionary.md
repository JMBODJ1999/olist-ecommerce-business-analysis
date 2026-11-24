# Data dictionary (supplied Olist files)

This dictionary records the source columns inspected in the six uploaded CSV files.

## Customers (`olist_customers_dataset.csv`)
- `customer_id`
- `customer_unique_id`
- `customer_zip_code_prefix`
- `customer_city`
- `customer_state`

## Geolocation (`olist_geolocation_dataset.csv`)
- `geolocation_zip_code_prefix`
- `geolocation_lat`
- `geolocation_lng`
- `geolocation_city`
- `geolocation_state`

## Order items (`olist_order_items_dataset.csv`)
- `order_id`
- `order_item_id`
- `product_id`
- `seller_id`
- `shipping_limit_date`
- `price`
- `freight_value`

## Order payments (`olist_order_payments_dataset.csv`)
- `order_id`
- `payment_sequential`
- `payment_type`
- `payment_installments`
- `payment_value`

## Order reviews (`olist_order_reviews_dataset.csv`)
- `review_id`
- `order_id`
- `review_score`
- `review_comment_title`
- `review_comment_message`
- `review_creation_date`
- `review_answer_timestamp`

## Orders (`olist_orders_dataset 2.csv`)
- `order_id`
- `customer_id`
- `order_status`
- `order_purchase_timestamp`
- `order_approved_at`
- `order_delivered_carrier_date`
- `order_delivered_customer_date`
- `order_estimated_delivery_date`

## Not supplied in this upload
The original Olist dataset may include other files, but the current upload does not include product, seller or product-category translation tables. This version therefore avoids category- and seller-specific analysis.
