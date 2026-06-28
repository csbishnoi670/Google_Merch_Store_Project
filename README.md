# GA4 E-Commerce Data Mart: From Event Stream to Star Schema

## Project Overview
When working with real-world Google Analytics 4 (GA4) data in Google BigQuery, querying raw, nested event streams directly is an expensive and slow anti-pattern. 

The goal of this project was to design and engineer a production-grade data mart using the public Google Merchandise Store dataset. I extracted a 500,000-row sample and transformed the deeply nested JSON arrays into a clean, 4-table Star Schema optimized for advanced product analytics.

## The Challenge
* **Data Volume & Integrity:** Limiting row extraction on event streams mathematically breaks user conversion funnels.
* **Nested Data:** E-commerce product data is stored inside a nested `items` array, making standard user-level analysis insufficient for product merchandising questions.
* **Session Fan-Out:** Mid-session device or IP network changes cause BigQuery to generate duplicate session rows, skewing conversion rates.

## The Solution & Architecture
I built an ELT (Extract, Load, Transform) pipeline to create a structured Data Mart:

1. **`dim_users`:** Tracks customer lifetime value (LTV), session stickiness, and acquisition dates.
2. **`dim_sessions`:** Tracks individual visits. I applied an `ANY_VALUE()` window function to device and geographic fields to eliminate the mid-session fan-out bug.
3. **`fct_events`:** A chronological behavioral ledger tracking the core funnel (`page_view` ➔ `add_to_cart` ➔ `purchase`).
4. **`fct_product_interactions`:** Solved the product blind spot by utilizing `LEFT JOIN UNNEST()` to flatten the `items` array, creating a dedicated table for product-specific abandonment and merchandising analysis.

## Tools Used
* **Google BigQuery:** Data extraction and schema engineering.
* **SQL:** Cryptographic hash sampling (`FARM_FINGERPRINT`), JSON unnesting, and window functions.
* **Google Drive Export Pipeline:** Bypassed standard BigQuery local download limits (16k rows) to extract full tables at zero cost.


- Guide to Download GMS Data using BigQuery Sandbox: [Read](https://github.com/csbishnoi670/Google_Merch_Store_Project/blob/main/Download_Data.md)

- Download data which I stored: 

[Download Data](https://drive.google.com/drive/folders/1EiUCDL-IY5cYualbwJxt3zipWlMNqzpT?usp=sharing) 
