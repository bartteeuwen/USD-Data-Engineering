CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.skill_counts` AS
SELECT
    skill_name,
    COUNT(DISTINCT job_id) AS mention_count,
    COUNT(DISTINCT CASE
        WHEN ingested_at >= DATETIME(TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY), 'America/Los_Angeles')
        THEN job_id
    END) as mentions_last_7_days
FROM `usd-data-engineering.labor_market.skills_in_demand`
GROUP BY skill_name
ORDER BY mention_count DESC;