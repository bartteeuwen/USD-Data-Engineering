CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.jobs_structured` AS
SELECT
    id,
    title,
    company,
    location,

    -- 1. CLEAN SALARY (Handle Nulls)
    -- If API is null, we leave it null (or you could set to 0 if preferred)
    salary_min,
    salary_max,

    -- 2. STANDARDIZE CONTRACT TYPE
    -- Adzuna sends "permanent", "contract", or null. Let's clean it.
    COALESCE(contract_type, 'Not Specified') AS contract_type,

    -- 3. DERIVE WORK MODE (The Logic API doesn't give us)
    CASE
        WHEN REGEXP_CONTAINS(LOWER(description), r'remote|work from home') THEN 'Remote'
        WHEN REGEXP_CONTAINS(LOWER(description), r'hybrid') THEN 'Hybrid'
        ELSE 'Onsite/Unspecified'
    END AS work_model,

    -- 4. FIX DATES (String -> Timestamp)
    -- This is crucial for your "Last 7 Days" calculations
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ingested_at) as ingested_at,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', created_at) as posted_at,

    -- 5. KEEP DESCRIPTION (For keyword matching)
    description

FROM `usd-data-engineering.labor_market.raw_job_postings`;