# GA4 E-Commerce Data Mart: From Event Stream to Star Schema

## Context & Learning Goals
This is a hands-on learning project. My primary objective was to master the extraction and modeling of real-world, high-volume e-commerce data using the **Google BigQuery Sandbox** (zero-cost execution). 

To navigate the complex architecture of Google Analytics 4 (such as nested JSON arrays and identity resolution) and to learn senior-level data engineering best practices, I utilized **Google Gemini** as an AI pair-programmer and architectural mentor throughout the extraction and ELT process.

## Project Overview
When working with real-world GA4 data in Google BigQuery, querying raw, nested event streams directly is an expensive and slow anti-pattern. 
* **It is expensive** because BigQuery charges by data scanned. Querying raw tables forces the engine to scan gigabytes of unoptimized, nested JSON parameters every time a simple metric is requested.
* **It is slow** because dynamically un-nesting arrays (like a user's shopping cart) at runtime requires heavy compute power.

The goal of this project was to solve this by designing and engineering a production-grade data mart. Using the public Google Merchandise Store dataset, I extracted the complete 3-month dataset (Nov 1, 2020 - Jan 31, 2021) and transformed the deeply nested event stream into a clean, flat, 4-table Star Schema optimized for advanced product analytics.

## The Challenge
* **Data Volume & Integrity:** Standard row-limiting on event streams mathematically breaks user conversion funnels, requiring time-series extraction instead.
* **Nested Data:** E-commerce product data is stored inside a nested `items` array, making standard user-level analysis insufficient for product merchandising questions.
* **Session Fan-Out:** Mid-session device or IP network changes cause BigQuery to generate duplicate session rows, skewing conversion rates.

## The Solution & Architecture
I built an ELT (Extract, Load, Transform) pipeline to create a structured Data Mart:

1. **`dim_users`:** Tracks customer lifetime value (LTV), session stickiness, and acquisition dates.
2. **`dim_sessions`:** Tracks individual visits. I applied an `ANY_VALUE()` window function to device and geographic fields to eliminate the mid-session fan-out bug.
3. **`fct_events`:** A chronological behavioral ledger tracking the core funnel (`page_view` ➔ `add_to_cart` ➔ `purchase`).
4. **`fct_product_interactions`:** Solved the product blind spot by utilizing `LEFT JOIN UNNEST()` to flatten the `items` array, creating a dedicated table for product-specific abandonment and merchandising analysis.

---

## 📊 Advanced SQL Product & App Analytics
With the Star Schema successfully staged in PostgreSQL via DBeaver, I executed a series of advanced product analytics modules designed to mimic elite data team requirements. The core focus shifts away from basic operational counts into user psychology, velocity, and retention dynamics.

The full scripts are structured from core performance metrics to expert time-series implementations:

### 🟢 Level 1: Foundational Commerce & Hierarchies
* **Product Sales & Category Grain Matching:** Aggregates granular item-level transaction signals directly from `fct_product_interactions` without skewing root user dimensions or double-counting order totals.
* **Multi-Level Reporting (ROLLUP):** Builds optimized hierarchical dashboard datasets grouping active traffic metrics across `device_type`, `operating_system`, and explicit grand total layers in a single query pass.

### 🟡 Level 2: Intermediate User Engagement
* **Session Depth Distribution:** Tracks engagement densities by segmenting traffic volume into behavioral tiers (Bounces, Shallow Browse, Core Engagement, Deep Sessions) based on transaction ledgers.
* **Cross-Feature Adoption (Venn Diagram Overlap):** Validates feature stickiness by calculating the cross-talk conversion percentage between generic top-of-funnel browsers and bottom-of-funnel shoppers.
* **Top-N Regional Spenders:** Utilizes analytical window functions (`DENSE_RANK()`) to identify and isolate the top 3 high-value macro-purchasers partitioned across individual cities.

### 🟠 Level 3: Conversion Funnels & Performance Velocity
* **Multi-Stage Structural Funnel:** Bridges the clickstream ledger and product matrix to construct an end-to-end e-commerce funnel tracking drop-offs across: `page_view` ➔ `view_item` ➔ `add_to_cart` ➔ `purchase`.
* **Funnel Drop-off Velocity Analysis:** Tracks conversion speed (velocity) measuring the exact duration from initial site entry to a product milestone. 
  * *Data Anomaly Resolution:* Successfully root-caused a data desynchronization where conflicting source timezones (UTC vs Local Server offsets) caused massive negative values space. Resolved via robust typecasting and epoch-based interval conversions: `ROUND((EXTRACT(EPOCH FROM AVG(first_cart_add_time - session_start_time)) / 60)::numeric, 2)`.

### 🔴 Level 4: Retention Dynamics & Behavioral Pathing
* **Feature Stickiness (DAU / MAU Ratio):** Evaluates if the digital storefront creates habit-forming loops by measuring the density ratio of daily active footprints relative to monthly active pools.
* **Next-Event Forward Pathing:** Employs lead window offsets (`LEAD()`) to build string paths mapping exactly where a customer flows immediately after an error milestone or core action.
* **RFM Customer Segmentation:** Computes mathematical distribution quartiles using `NTILE(4)` across Recency, Frequency, and Monetary parameters to tag historical shoppers into action profiles (VIP Champions, High Spenders, At-Risk Loyalists).

### ⚫ Level 5: Time-Series Mastery (Gaps-and-Islands)
* **Day 0 to Day 7 ($D0 \rightarrow D7$) Rolling Retention:** Maps cohort-based behavioral longevity, calculating exact relative return rates 1, 3, and 7 days post-acquisition.
* **Consecutive Active Streaks:** Codes the classic **"Gaps and Islands"** database framework. By converting dense sequence row rankings into dynamic day intervals (`login_date - (date_rank * INTERVAL '1 day')`), the logic group-aggregates continuous day blocks to track maximum user engagement streaks.

---

## Tools Used
* **Google BigQuery Sandbox:** Zero-cost data extraction and schema engineering.
* **SQL:** JSON unnesting, time-series partitioning, window functions, and Gaps-and-Islands streak tracking.
* **Google Drive Export Pipeline:** Bypassed standard BigQuery local download limits (16k rows) to extract massive tables.
* **Google Gemini:** AI assistance for query optimization, analytical planning, and pipeline debugging.

## Project Resources
* 📖 **Guide to Download GMS Data using BigQuery Sandbox:** [Read Guide](https://github.com/csbishnoi670/Google_Merch_Store_Project/blob/main/Download_Data.md)
* 💻 **Advanced SQL Scripts Directory:** [Browse Scripts](./SQL%20Scripts/)
* 💾 **Download Raw & Staged Datasets:** [Google Drive Data Folder](https://drive.google.com/drive/folders/1EiUCDL-IY5cYualbwJxt3zipWlMNqzpT?usp=sharing)