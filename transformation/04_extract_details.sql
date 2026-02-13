CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.jobs_structured` AS
WITH base AS (
  SELECT
    id, title, company, location, salary_min, salary_max,
    COALESCE(contract_type, 'Not Specified') AS contract_type,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(description), r'remote|work from home') THEN 'Remote'
      WHEN REGEXP_CONTAINS(LOWER(description), r'hybrid') THEN 'Hybrid'
      ELSE 'Onsite/Unspecified'
    END AS work_model,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ingested_at) AS ingested_at,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', created_at) AS posted_at,
    description,
    -- Normalize the key for matching (lowercase, no symbols)
    LOWER(REGEXP_REPLACE(TRIM(company), r'[^a-z0-9]+', '')) AS company_key
  FROM `usd-data-engineering.labor_market.raw_job_postings`
),
-- Ensure the Fortune list is unique to prevent row multiplication
unique_fortune AS (
  SELECT DISTINCT company, industry, company_key
  FROM `usd-data-engineering.labor_market.dim_fortune_500`
)

SELECT
  b.*,
  f.company AS fortune_company,
  f.industry AS fortune_industry,
  -- Check for existence: if the key is found, it's a Fortune 500 company
  (f.company_key IS NOT NULL) AS is_fortune_500
FROM base b
LEFT JOIN unique_fortune f
  ON b.company_key = f.company_key;