# Olist E-commerce Business Analysis

> **Portfolio project | PostgreSQL · SQL · Power BI**
>
> An end-to-end analysis of Olist's Brazilian e-commerce marketplace, translating transactional data into commercial, customer, operational and customer-experience insights.

## 1. Executive summary

This project analyses Olist's marketplace performance across four business dimensions:

1. Commercial performance
2. Customer behaviour
3. Delivery and operations
4. Customer satisfaction

The analysis points to three strategic themes:

- **Customer retention is a major opportunity.** The customer dashboard reports a repeat-customer rate of approximately 3% and an average of 1.03 orders per customer.
- **Revenue is concentrated geographically and by customer value.** São Paulo is the largest revenue-generating state in the displayed top-10 comparison, while the highest customer-revenue quartile contributes the largest share of product revenue.
- **Delivery reliability is closely associated with customer experience.** The Power BI comparison shows a substantially lower average review score for late deliveries than for on-time deliveries.

The project uses delivered orders for completed-sales and purchasing-behaviour KPIs unless a section explicitly states otherwise. Values are rounded and should be interpreted using the metric definitions and limitations below.

## 2. Project objectives and business questions

| Workstream | Business question |
|---|---|
| Commercial performance | How has Olist's commercial performance evolved, and which geographical markets contribute most to revenue? |
| Customer behaviour | Who are Olist's customers, how do they purchase, and to what extent do they return? |
| Delivery & operations | How efficiently does Olist fulfil orders, and where do delivery delays occur? |
| Customer satisfaction | What factors are associated with customer satisfaction, and how does delivery performance relate to reviews? |

## 3. Dataset and scope

The project uses six supplied Olist CSV datasets:

| Dataset | Rows | Main analytical use |
|---|---:|---|
| Customers | 99,441 | Customer identity and state |
| Geolocation | 1,000,163 | Geographic reference data |
| Order items | 112,650 | Product prices and freight |
| Order payments | 103,886 | Payment methods and payment values |
| Order reviews | 99,224 | Review scores and response timestamps |
| Orders | 99,441 | Order status and lifecycle timestamps |

The order data spans **4 September 2016 to 17 October 2018**.

### Scope limitations

- The supplied files do not include the products, sellers or product-category translation datasets. Product-category and seller-level conclusions are therefore outside the scope of this version.
- Customer state is used for geographical comparisons. Geolocation is available for possible future mapping work.
- October 2018 is incomplete and should not be compared directly with full months.
- Review metrics describe submitted reviews, not necessarily every customer's experience.

## 4. Data preparation and analytical safeguards

The SQL scripts use PostgreSQL and the following source tables:

- `"Olist_orders"`
- `"Olist_items"`
- `"Olist_payments"`
- `"Olist_customers"`
- `"Olist_reviews"`
- `"Olist_geolocation"`

Important modelling and data-quality decisions:

- **Customer identity:** `customer_unique_id` is used for repeat-purchase analysis because one real customer can be associated with multiple `customer_id` records.
- **Delivered-order scope:** completed-sales and customer-purchase KPIs use `order_status = 'delivered'`.
- **Revenue definition:** product revenue is `SUM(price)`; freight is reported separately.
- **Join fan-out:** order items and payments can contain multiple rows per order. They are aggregated to order level before being joined, preventing duplicated revenue or payment values.
- **Review grain:** 547 orders have more than one review row in the supplied data. Reviews are aggregated to order level for order-level delivery comparisons.
- **Missing timestamps:** duration and punctuality calculations exclude records missing the timestamps required for the calculation.
- **On-time delivery:** actual delivery date is on or before the estimated delivery date.

## 5. Commercial performance

### 5.1 Key results

| KPI | Result |
|---|---:|
| Delivered orders | 96,478 |
| Purchasing customer accounts (`customer_id`) | 96,478 |
| Product revenue | R$13,221,498.11 |
| Freight revenue | R$2,198,275.64 |
| Product + freight value | R$15,419,773.75 |
| Items sold | 110,197 |
| Average product revenue per delivered order | R$137.04 |

**Interpretation:** Delivered orders generated approximately R$13.22 million in product revenue. Freight contributed a further R$2.20 million. Product revenue and freight should remain separate in commercial reporting because they represent different components of transaction value.

![Delivered-order revenue composition](charts/revenue_composition.png)

### 5.2 Revenue trend

The monthly revenue dashboard shows a strong increase in monthly product revenue during 2017, followed by a higher but fluctuating revenue level during 2018.

**Business insight — Growth followed by stabilisation**

- **Evidence:** The monthly product-revenue line rises substantially during 2017 and remains at a higher level through much of 2018.
- **Interpretation:** Olist expanded strongly during 2017, but the subsequent pattern suggests that the growth rate did not continue uniformly.
- **Business implication:** Understanding the drivers of the 2017 increase and the later fluctuations can help management distinguish sustainable growth from temporary changes in demand.
- **Recommendation:** Monitor monthly revenue and order volume together, then investigate the customer and geographical segments contributing most to changes.

*October 2018 is incomplete in the supplied dataset.*

### 5.3 Geographical revenue concentration

The Power BI top-10 state comparison identifies:

| State | Approximate product revenue |
|---|---:|
| São Paulo (SP) | R$5.1M |
| Rio de Janeiro (RJ) | R$1.7M |
| Minas Gerais (MG) | R$1.5M |

**Business insight — São Paulo is the leading revenue market**

- **Evidence:** São Paulo generates substantially more product revenue than the other states in the displayed top-10 comparison.
- **Interpretation:** Olist's revenue is geographically concentrated, with São Paulo as its dominant market.
- **Business implication:** Performance in a small number of major markets has a material influence on overall commercial results.
- **Recommendation:** Protect service quality in established high-revenue markets while evaluating expansion opportunities in other states using demand, delivery and customer-satisfaction indicators.

*State figures are approximate readings from the dashboard visual.*

### 5.4 Payment method mix

| Payment method | Share of payment value |
|---|---:|
| Credit card | 78.46% |
| Boleto | 17.96% |
| Other payment methods combined | 3.58% |

![Payment method mix](charts/payment_method_mix.png)

**Business insight — Payment value is concentrated in credit cards**

- **Evidence:** Credit cards account for approximately 78.46% of payment value, followed by boleto at 17.96%.
- **Interpretation:** Credit cards are the dominant payment channel in the analysed delivered-order payment mix.
- **Business implication:** A reliable and secure credit-card payment experience is important to the transaction journey.
- **Recommendation:** Monitor payment failures and checkout friction, while evaluating whether alternative methods can improve access for customer segments with different payment preferences.

### 5.5 Freight and payment reconciliation

Across all orders with both item and payment records, the analysis found:

| Metric | Result |
|---|---:|
| Orders with items and payments | 98,665 |
| Product revenue | R$13,591,508.73 |
| Freight value | R$2,251,901.05 |
| Payment value | R$15,846,280.17 |
| Net difference: payment less product and freight | R$2,870.39 |

This reconciliation covers orders with both items and payment records; it is **not** the same population as the delivered-only commercial KPIs. Differences can arise from discounts, vouchers, adjustments and dataset definitions.

## 6. Customer behaviour

### 6.1 Customer retention and purchasing frequency

The customer dashboard reports:

| KPI | Dashboard result |
|---|---:|
| Repeat customers | 2,801 |
| Repeat customer rate | Approximately 3% |
| Average orders per customer | 1.03 |

![Customer repeat-purchase rate](charts/customer_repeat_rate.png)

**Business insight — Repeat purchasing is limited**

- **Evidence:** The dashboard reports a repeat-customer rate of approximately 3%, with an average of 1.03 orders per customer.
- **Interpretation:** Most purchasing customers appear to make only one delivered purchase during the observed period.
- **Business implication:** Olist may need to rely heavily on customer acquisition to maintain transaction volume if repeat purchasing remains limited.
- **Recommendation:** Test post-purchase engagement, relevant second-purchase incentives and customer reactivation campaigns. Measure whether these initiatives increase the repeat-purchase rate and orders per customer.

**Data validation note:** The dashboard's one-time-customer card and repeat-customer card do not reconcile cleanly with the distinct-customer total in the supplied data summary. The approximate 3% repeat rate and 1.03 average orders per customer are reported here as dashboard results; the exact one-time-customer count should be reconciled before publication as a headline KPI.

### 6.2 Customer revenue segmentation

Customers were divided into four quartiles based on lifetime product revenue. The dashboard shows that the fourth quartile contributes the largest share of total customer product revenue.

**Business insight — Higher-value customers contribute disproportionately to revenue**

- **Evidence:** Revenue contribution increases across the displayed customer revenue quartiles, with the fourth quartile contributing the largest share.
- **Interpretation:** A relatively high-value customer segment accounts for a disproportionate amount of product revenue.
- **Business implication:** Retaining higher-value customers may have a meaningful impact on revenue.
- **Recommendation:** Profile the highest-value segment, compare its purchasing patterns with other quartiles, and test targeted retention initiatives.

### 6.3 Cohort analysis: validation required

The SQL project includes customer acquisition cohorts based on the month of first delivered purchase and tracks active customers by months since first purchase.

A cohort-retention measure was also added to the Power BI matrix. However, the current visual's total row aggregates percentages and produces totals above 100%, which are not meaningful retention metrics.

**This cohort-retention result is not used as a business conclusion in this document.** Before publishing it, validate the denominator (cohort size at month zero), month-level row grouping, and total/subtotal behaviour. The matrix should show each cohort month against months since first purchase, with grand totals disabled or otherwise excluded from interpretation.

## 7. Delivery and operations

The operational SQL analysis is designed to evaluate:

- Average purchase-to-delivery duration.
- Average carrier-to-customer duration.
- On-time and late order counts.
- On-time delivery rate.
- Delivery duration and punctuality by customer state.
- Monthly delivery performance.
- Time between purchase, approval and carrier handoff.
- Overall order-status distribution.

### Business questions and recommended interpretation

| Analysis | What it helps identify |
|---|---|
| Purchase-to-delivery duration | Overall customer waiting time |
| Carrier-to-customer duration | Delivery-stage performance after carrier handoff |
| On-time delivery rate | Reliability against the estimated delivery date |
| Delivery performance by state | Geographical differences in fulfilment |
| Monthly late-delivery rate | Changes in operational reliability over time |
| Purchase-to-approval and approval-to-carrier time | Potential delays before carrier handoff |
| Order-status distribution | The overall order lifecycle and unresolved statuses |

**Business insight — Delivery reliability should be managed as both an operational and customer-experience priority**

The satisfaction dashboard shows a clear difference in average review score between on-time and late deliveries (see Section 8). This makes delivery punctuality a relevant operational priority.

**Recommendation:** Prioritise the states and process stages with the weakest validated on-time performance. Track delivery KPIs alongside customer review outcomes.

**Quantitative limitation:** The current project summary does not contain the final numerical outputs for the overall delivery KPIs or state-level delivery table. Those values should be added only after checking the executed SQL results; they are not estimated here.

## 8. Customer satisfaction

### 8.1 Overall satisfaction

| KPI | Result |
|---|---:|
| Review records | 99,224 |
| Reviewed orders | 98,673 |
| Average review score | 4.09 / 5 |
| Low-score reviews (1 or 2 stars) | 14,575 |
| Low-score review rate | 14.69% |

![Review score distribution](charts/review_score_distribution.png)

The review distribution shown in the dashboard is:

| Score | Share of review records |
|---|---:|
| 5 stars | 57.78% |
| 4 stars | 19.29% |
| 3 stars | 11.51% |
| 2 stars | 8.24% |
| 1 star | 3.18% |

**Business insight — Positive average ratings coexist with a meaningful dissatisfied segment**

- **Evidence:** The average score is 4.09/5, while 14.69% of reviews are rated one or two stars.
- **Interpretation:** Overall feedback is positive, but the average conceals a meaningful group of dissatisfied customers.
- **Business implication:** Focusing only on the average review score could hide recurring service problems.
- **Recommendation:** Analyse low-score review comments, group recurring complaint themes, and monitor the low-score rate alongside the average score.

### 8.2 Delivery performance and review scores

The Power BI dashboard displays approximate average review scores of:

| Delivery performance | Average review score |
|---|---:|
| On time | Approximately 4.3 / 5 |
| Late | Approximately 2.2 / 5 |

![Average review score by delivery performance](charts/review_score_by_delivery.png)

**Business insight — Late deliveries are associated with lower customer satisfaction**

- **Evidence:** The displayed average review score is substantially lower for late deliveries than for on-time deliveries.
- **Interpretation:** Delivery punctuality is strongly associated with the customer experience in this dataset.
- **Business implication:** Delivery reliability is not only an operational metric; it is also relevant to customer satisfaction and reputation.
- **Recommendation:** Investigate the causes of late deliveries, improve delivery estimates and customer communication, and monitor review outcomes after operational improvements.

*This is an observed association, not proof that late delivery alone causes a lower review score.*

### 8.3 Geographical differences in low-score reviews

The dashboard's state comparison highlights relatively high low-score order rates in states including Roraima (RR), Alagoas (AL), Maranhão (MA), Sergipe (SE), Ceará (CE) and Pará (PA).

**Business insight — Customer dissatisfaction may vary by market**

- **Evidence:** These states appear toward the higher end of the displayed low-score-rate comparison.
- **Interpretation:** Customer experience may vary geographically.
- **Business implication:** National averages can conceal local service issues.
- **Recommendation:** Compare state-level review rates with review counts, order volumes, delivery punctuality and freight costs before deciding where to intervene.

*The comparison should be interpreted with sample sizes in mind. The SQL query excludes states with fewer than 30 reviewed orders.*

## 9. Cross-functional business priorities

| Priority | Evidence from the analysis | Recommended action |
|---|---|---|
| Improve customer retention | Approximately 3% repeat-customer rate; 1.03 orders per customer | Test reactivation and second-purchase initiatives |
| Protect high-value customer relationships | Fourth revenue quartile contributes the largest revenue share | Profile and retain high-value customers |
| Strengthen delivery reliability | Late deliveries have substantially lower average review scores | Investigate weak delivery stages and markets |
| Address geographical differences | Revenue and low-score rates vary across states | Combine commercial, delivery and satisfaction indicators by state |
| Improve payment experience | Credit cards represent 78.46% of payment value | Monitor payment reliability and checkout friction |
| Reduce recurring customer dissatisfaction | 14.69% low-score review rate | Analyse review comments and address recurring complaints |

## 10. Dashboard and graph inventory

The Power BI report is organised into four analytical pages.

### Page 1 — Commercial performance

Recommended visuals:
- KPI cards: delivered orders, product revenue, freight revenue, average product revenue per order.
- Monthly product-revenue trend.
- Product revenue by customer state (Top 10).
- Payment method distribution.
- Optional reconciliation view for product value, freight and payment value.

### Page 2 — Customer behaviour

Recommended visuals:
- KPI cards: average orders per customer, repeat-customer rate, repeat customers, unique purchasing customers, average lifetime product revenue.
- Monthly delivered orders and unique purchasing customers.
- Customer order-count distribution.
- Revenue contribution by customer quartile.
- Cohort-retention heat map, after validation.

### Page 3 — Delivery and operations

Recommended visuals:
- KPI cards: average delivery days, on-time delivery rate, late orders, average carrier-to-customer days.
- Delivery performance by month.
- Average delivery days and on-time rate by state.
- Purchase-to-approval and approval-to-carrier duration.
- Order-status distribution.

### Page 4 — Customer satisfaction

Recommended visuals:
- KPI cards: average review score, low-score review rate, review records, reviewed orders, low-score reviews.
- Review-score distribution.
- Review volume over time.
- Average review score and low-score order rate by delivery performance.
- Low-score order rate by state.
- Review response time.

## 11. Limitations and next steps

### Limitations

1. The analysis covers the supplied data through 17 October 2018; it does not describe current Olist performance.
2. October 2018 is incomplete.
3. Product-category and seller-level analyses are unavailable because the corresponding source files were not supplied.
4. Review-based findings reflect submitted feedback and may not represent all purchasers.
5. State-level rates should be interpreted with their underlying order/review counts.
6. The cohort matrix requires validation before its retention percentages are used as evidence.
7. Delivery KPI values should be added from final SQL outputs, not inferred from visual appearance.

### Next steps

- Reconcile customer totals and repeat-customer definitions across SQL and Power BI.
- Validate the cohort-retention denominator and matrix totals.
- Add the final delivery KPI outputs from the executed SQL queries.
- Capture final Power BI dashboard screenshots and add them to the repository.
- Add a short methodology note describing how each exported Power BI table was generated.
- Recheck all headline figures against the source SQL outputs before publishing.

## 12. Conclusion

The Olist analysis identifies customer retention, delivery reliability and customer-value development as important business opportunities.

The data suggests that Olist has a large base of one-time purchasers, a concentration of revenue in leading states and higher-value customer segments, and a clear association between late delivery and lower review scores.

The most actionable opportunity is to connect commercial and operational decision-making: retain valuable customers, understand why customers do not return, and improve the delivery experience that shapes customer satisfaction.

---

## Appendix — SQL scripts

The analysis is supported by the following PostgreSQL scripts in the repository:

- `sql/01_commercial_performance.sql`
- `sql/02_customer_behaviour.sql`
- `sql/03_delivery_and_operations.sql`
- `sql/04_customer_satisfaction.sql`

See `docs/data_dictionary.md` for the source fields and dataset structure.
