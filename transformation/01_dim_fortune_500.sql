-- 01_dim_fortune_500.sql
CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.dim_fortune_500` AS
SELECT DISTINCT
  TRIM(company) AS company,
  LOWER(REGEXP_REPLACE(TRIM(company), r'[^a-z0-9]+', '')) AS company_key,
  TRIM(industry) AS industry,
  TRIM(city) AS city,
  TRIM(state) AS state,
  website
FROM `usd-data-engineering.labor_market.dim_fortune_500`
WHERE company IS NOT NULL;