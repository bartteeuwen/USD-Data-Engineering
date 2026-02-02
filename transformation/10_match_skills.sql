CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.skills_in_demand` AS
WITH unique_skills AS (
    SELECT DISTINCT technology_skill
    FROM `usd-data-engineering.labor_market.O_Net_Technology_Skills`
    WHERE LENGTH(technology_skill) > 2
)
SELECT DISTINCT
    j.id AS job_id,
    j.title,
    j.company,
    -- FIX: Convert the String date back to a Timestamp so Script 20 can read it
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', j.ingested_at) as ingested_at,
    s.technology_skill AS skill_name
FROM `usd-data-engineering.labor_market.raw_job_postings` j
CROSS JOIN unique_skills s
WHERE STRPOS(LOWER(j.description), LOWER(s.technology_skill)) > 0;