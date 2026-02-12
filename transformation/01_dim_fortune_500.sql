CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.dim_fortune_500` AS
SELECT
  TRIM(Company) AS company,
  LOWER(REGEXP_REPLACE(TRIM(Company), r'[^a-z0-9]+', '')) AS company_key,
  TRIM(Industry) AS industry,
  TRIM(City) AS city,
  TRIM(State) AS state,
  TRIM(Website) AS website,
  -- Note: BigQuery might import '2,100,000' as a STRING because of the commas
  SAFE_CAST(REPLACE(Employees, ',', '') AS INT64) AS employees
FROM `usd-data-engineering.labor_market.fortune_500_raw`
WHERE Company IS NOT NULL;