# Advanced E-Commerce Product Analytics (SQL Portfolio)

This project contains advanced PostgreSQL queries designed to extract deep behavioral product analytics from a structured Star Schema database (`fct_events`, `fct_product_interactions`, `dim_sessions`, `dim_users`). 

The analysis progresses from foundational data validations to complex time-series and user-retention frameworks.

## 🟢 Level 1: Foundational Commerce & Hierarchies
1. **Product Sales & Category Grain Matching:** Calculate total units sold and revenue grouped by product category, ensuring that table granularity mismatches do not artificially inflate financial metrics.
2. **Multi-Level Reporting (ROLLUP):** Generate an executive matrix that aggregates active users and revenue simultaneously by device type, operating system, and a combined grand total.

## 🟡 Level 2: Intermediate User Segmentation & Engagement
3. **Session Depth Distribution:** Segment all historical sessions into categorical buckets (Bounce, Shallow, Core, Deep) based on the absolute volume of events triggered per session.
4. **Cross-Feature Adoption (Venn Diagram):** Evaluate feature siloization by determining the exact percentage of standard page viewers who cross over to interact with specific product catalog elements.
5. **Top-N Regional Users:** Utilize window functions to identify and rank the top 3 highest-spending users isolated within every geographical city.

## 🟠 Level 3: Advanced Product Funnels & Velocity
6. **Multi-Stage Structural Funnel:** Combine standard clickstream data with item-level interactions to build a unified conversion funnel (View Page -> View Item -> Add to Cart -> Purchase), outputting step-by-step drop-off percentages.
7. **Funnel Drop-off Velocity Analysis:** Calculate the exact average time (in minutes) it takes a user to progress from their first session pageview to their first cart addition, handling cross-table timezone offsets and fractional epoch extraction.

## 🔴 Level 4: Expert Retention, Behavior & Pathing
8. **Feature Stickiness (DAU/MAU Ratio):** Assess platform habit-formation by calculating the Daily Active Users to Monthly Active Users ratio on a rolling basis.
9. **Next Event Forward Pathing:** Implement sequence tracking to map the most common 3-step behavioral paths users take immediately after viewing a product item.
10. **RFM Customer Segmentation:** Statistically bin the entire user base into distribution quartiles based on Recency, Frequency, and Monetary factors to label users as VIPs, At-Risk, or Low-Engagement.

## ⚫ Level 5: Master Time-Series & Gaps-and-Islands
11. **D0 to D7 Rolling Retention:** Measure the precise acquisition drop-off rate by tracking the percentage of users who return exactly 1, 3, and 7 days after their initial `first_seen_date`.
12. **Consecutive User Streaks (Gaps and Islands):** Resolve the classic "Gaps and Islands" algorithm using dynamic date-interval subtraction to calculate the longest consecutive streak of daily logins for every user.