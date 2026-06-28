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

## Tools Used
* **Google BigQuery Sandbox:** Zero-cost data extraction and schema engineering.
* **SQL:** JSON unnesting, time-series partitioning, and window functions.
* **Google Drive Export Pipeline:** Bypassed standard BigQuery local download limits (16k rows) to extract massive tables.
* **Google Gemini:** AI assistance for query optimization, architectural planning, and debugging.


- Guide to Download GMS Data using BigQuery Sandbox: [Read](https://github.com/csbishnoi670/Google_Merch_Store_Project/blob/main/Download_Data.md)

- Download data which I stored: 

[Download Data](https://drive.google.com/drive/folders/1EiUCDL-IY5cYualbwJxt3zipWlMNqzpT?usp=sharing) 
