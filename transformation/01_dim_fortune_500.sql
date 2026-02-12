CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.dim_fortune_500` AS
SELECT
  TRIM(Company) AS company,
  LOWER(REGEXP_REPLACE(TRIM(Company), r'[^a-z0-9]+', '')) AS company_key,
  TRIM(Industry) AS industry,
  TRIM(City) AS city,
  TRIM(State) AS state,
  TRIM(Website) AS website
FROM `usd-data-engineering.labor_market.fortune_500_raw`
WHERE Company IS NOT NULL; -- Check this line specifically!