/*
=============================================================================
Query: Star Schema Data Mart Creation
Purpose: Transforms raw, nested GA4 event streams into 4 structured tables
         (2 Dimension tables, 2 Fact tables) to optimize analytical queries.
=============================================================================
*/

-- 1. Create Users Dimension Table
CREATE OR REPLACE TABLE `portfolio_db.dim_users` AS
SELECT
    user_pseudo_id AS user_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_seen_date,
    MAX(PARSE_DATE('%Y%m%d', event_date)) AS last_seen_date,
    COUNT(DISTINCT (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')) AS total_sessions,
    COALESCE(SUM(ecommerce.purchase_revenue), 0) AS lifetime_value_usd
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY 1;

-- 2. Create Sessions Dimension Table (with Fan-out Patch)
CREATE OR REPLACE TABLE `portfolio_db.dim_sessions` AS
SELECT
    CONCAT(user_pseudo_id, '-', CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS session_id,
    user_pseudo_id AS user_id,
    MIN(TIMESTAMP_MICROS(event_timestamp)) AS session_start_time,
    MAX(TIMESTAMP_MICROS(event_timestamp)) AS session_end_time,
    -- ANY_VALUE prevents session duplication if IP/Device changes mid-session
    ANY_VALUE(device.category) AS device_type,
    ANY_VALUE(device.operating_system) AS operating_system,
    ANY_VALUE(geo.country) AS country,
    ANY_VALUE(geo.city) AS city
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') IS NOT NULL
GROUP BY 1, 2;

-- 3. Create Core Events Fact Table
CREATE OR REPLACE TABLE `portfolio_db.fct_events` AS
SELECT
    CAST(FARM_FINGERPRINT(CONCAT(user_pseudo_id, CAST(event_timestamp AS STRING), event_name)) AS STRING) AS event_id,
    CONCAT(user_pseudo_id, '-', CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS session_id,
    user_pseudo_id AS user_id,
    TIMESTAMP_MICROS(event_timestamp) AS event_time,
    event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_url,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_title') AS page_title,
    ecommerce.transaction_id,
    ecommerce.purchase_revenue AS revenue_usd
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name IN ('session_start', 'page_view', 'view_item', 'add_to_cart', 'begin_checkout', 'purchase');

-- 4. Create Product Interactions Fact Table
CREATE OR REPLACE TABLE `portfolio_db.fct_product_interactions` AS
SELECT
    CAST(FARM_FINGERPRINT(CONCAT(user_pseudo_id, CAST(event_timestamp AS STRING), event_name, COALESCE(items.item_id, 'unknown'))) AS STRING) AS interaction_id,
    CONCAT(user_pseudo_id, '-', CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS session_id,
    TIMESTAMP_MICROS(event_timestamp) AS event_time,
    event_name,
    items.item_id,
    items.item_name,
    items.item_category,
    items.price AS item_price,
    items.quantity AS item_quantity
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
UNNEST(items) AS items
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name IN ('view_item', 'add_to_cart', 'purchase');
