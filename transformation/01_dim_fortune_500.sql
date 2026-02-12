CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.dim_fortune_500` AS
SELECT
  TRIM(string_field_1) AS company, -- This corresponds to the 'Walmart' column
  LOWER(REGEXP_REPLACE(TRIM(string_field_1), r'[^a-z0-9]+', '')) AS company_key,
  TRIM(string_field_2) AS industry, -- General Merchandisers
  TRIM(string_field_3) AS city,     -- Bentonville
  TRIM(string_field_4) AS state,    -- Arkansas
  TRIM(string_field_6) AS website   -- walmart.com
FROM `usd-data-engineering.labor_market.fortune_500_raw`
WHERE string_field_1 IS NOT NULL;