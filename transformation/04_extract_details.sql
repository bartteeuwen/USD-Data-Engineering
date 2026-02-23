CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.jobs_structured` AS
WITH base AS (
  SELECT
    id, title, company, location, salary_min, salary_max,
    COALESCE(contract_type, 'Not Specified') AS contract_type,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(description), r'remote|work from home') THEN 'Remote'
      WHEN REGEXP_CONTAINS(LOWER(description), r'hybrid') THEN 'Hybrid'
      ELSE 'Onsite'
    END AS work_model,
    DATETIME(PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ingested_at), 'America/Los_Angeles') AS ingested_at,
    DATETIME(PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', created_at), 'America/Los_Angeles') AS posted_at,
    description,
    REGEXP_REPLACE(LOWER(TRIM(company)), r'[^a-z0-9]+', '') AS company_key
  FROM `usd-data-engineering.labor_market.raw_job_postings`
),
unique_fortune AS (
  SELECT DISTINCT company, industry, company_key
  FROM `usd-data-engineering.labor_market.dim_fortune_500`
)
SELECT
  b.*,
  f.company AS fortune_company,
  f.industry AS fortune_industry,
  (f.company_key IS NOT NULL AND b.company_key != '') AS is_fortune_500
FROM base b
LEFT JOIN unique_fortune f
  ON b.company_key = f.company_key

-- Validation
ASSERT (SELECT COUNT(*) FROM `usd-data-engineering.labor_market.jobs_structured`) > 0
  AS 'Error: jobs_structured table is empty.';

ASSERT (SELECT COUNT(*) FROM `usd-data-engineering.labor_market.jobs_structured` WHERE id IS NULL) = 0
  AS 'Data Quality Error: NULL job IDs found in structured layer.';