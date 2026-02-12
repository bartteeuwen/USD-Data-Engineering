CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.dim_fortune_500` AS
SELECT
  TRIM(company) AS company,
  LOWER(REGEXP_REPLACE(TRIM(company), r'[^a-z0-9]+', '')) AS company_key,
  TRIM(industry) AS industry,
  TRIM(city) AS city,
  TRIM(state) AS state,
  TRIM(website) AS website,
  SAFE_CAST(employees AS INT64) AS employees
FROM `usd-data-engineering.labor_market.fortune_500`
WHERE company IS NOT NULL;
