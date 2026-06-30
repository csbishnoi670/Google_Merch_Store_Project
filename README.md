# GA4 E-Commerce Data Mart: From Raw Event Stream to Advanced Analytics

## 🎯 Executive Summary
This project demonstrates end-to-end data engineering and advanced product analytics using high-volume e-commerce data from the **Google BigQuery Sandbox**. The objective was to bypass the inefficiencies of querying raw, nested JSON event streams by architecting a production-grade Star Schema, subsequently uncovering deep behavioral insights through advanced SQL.

---

## 🏗️ Phase 1: Data Architecture & ELT Pipeline
Querying nested GA4 event streams directly is an expensive and slow anti-pattern. To optimize compute performance and query efficiency, I extracted three months of Google Merchandise Store data and engineered a **4-table Star Schema**:

* **`dim_users`:** Centralizes customer lifetime value (LTV) and acquisition dates for cohort tracking.
* **`dim_sessions`:** Aggregates individual visits. *Engineering note: Resolved mid-session device/IP fan-out duplicates utilizing `ANY_VALUE()` window functions.*
* **`fct_events`:** A chronological behavioral ledger tracking the core user journey (`page_view` ➔ `view_item` ➔ `add_to_cart`).
* **`fct_product_interactions`:** Flattened the deeply nested `items` array using `LEFT JOIN UNNEST()`, isolating granular product-level merchandising data.

---

## 📊 Phase 2: Advanced SQL Product Analytics
Migrating the staged schema to PostgreSQL via DBeaver, I executed complex analytical modules targeting core business metrics, user psychology, and retention dynamics:

### 🔹 Foundational Mechanics & Hierarchies
* **Grain Matching:** Aggregated category revenue without duplicating root dimensions or inflating order totals.
* **Executive Reporting (`ROLLUP`):** Generated multi-level hierarchical summaries of traffic metrics across devices and operating systems in a single optimized pass.

### 🔹 Engagement & Conversion Velocity
* **Session Depth Matrix:** Segmented traffic volume into distinct behavioral tiers (Bounce, Shallow, Core, Deep) based on interaction density.
* **Cross-Feature Adoption:** Quantified the exact overlap percentage between top-of-funnel browsers and bottom-of-funnel shoppers.
* **Conversion Velocity:** Measured the average time elapsed from site entry to `add_to_cart`. *Successfully debugged and resolved a cross-system timezone anomaly (UTC vs. Local Offset) using epoch-based interval casting.*

### 🔹 Retention & Time-Series Mastery
* **Feature Stickiness ($DAU / MAU$):** Calculated daily vs. monthly active user ratios to evaluate platform habit formation.
* **RFM Segmentation:** Classified the user base into actionable profiles (VIP, At-Risk, High-Spender) utilizing `NTILE(4)` across Recency, Frequency, and Monetary parameters.
* **Rolling Cohort Retention ($D0 \rightarrow D7$):** Mapped precise return rates 1, 3, and 7 days post-acquisition.
* **Gaps-and-Islands (Active Streaks):** Converted sequence row rankings into dynamic day intervals to isolate and measure users' longest consecutive daily login streaks.

---

## 🛠️ Tech Stack & Tools
* **Data Warehouse & ELT:** Google BigQuery Sandbox
* **Analytics Engine:** PostgreSQL & DBeaver
* **Techniques:** JSON Unnesting, Window Functions, Time-Series Analysis, Gaps-and-Islands
* **AI Pair-Programming:** Google Gemini (for query optimization and pipeline architectural review)

## 🔗 Project Links
* 📖 **Extraction Guide:** [BigQuery Sandbox Download Process](./Download_Data.md)
* 💻 **SQL Codebase:** [Advanced Analytics Scripts](./SQL%20Scripts/)
* 💾 **Processed Datasets:** [Google Drive Repository](https://drive.google.com/drive/folders/1EiUCDL-IY5cYualbwJxt3zipWlMNqzpT?usp=sharing)