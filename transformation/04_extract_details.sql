CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.jobs_structured` AS
WITH base AS (
  SELECT
    id,
    title,
    company,
    location,
    salary_min,
    salary_max,
    COALESCE(contract_type, 'Not Specified') AS contract_type,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(description), r'remote|work from home') THEN 'Remote'
      WHEN REGEXP_CONTAINS(LOWER(description), r'hybrid') THEN 'Hybrid'
      ELSE 'Onsite/Unspecified'
    END AS work_model,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ingested_at) AS ingested_at,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', created_at) AS posted_at,
    description,
    LOWER(REGEXP_REPLACE(TRIM(company), r'[^a-z0-9]+', '')) AS company_key
  FROM `usd-data-engineering.labor_market.raw_job_postings`
)

SELECT
  b.*,
  f.company AS fortune_company,
  f.industry AS fortune_industry,
  f.company IS NOT NULL AS is_fortune_500
FROM base b
LEFT JOIN `usd-data-engineering.labor_market.dim_fortune_500` f
  ON b.company_key = f.company_key;