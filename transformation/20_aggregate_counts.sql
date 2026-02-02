CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.skill_counts` AS
SELECT
    skill_name,
    COUNT(DISTINCT job_id) AS mention_count,
    -- We can also check trends (e.g., mentions in the last 7 days)
    COUNT(DISTINCT CASE WHEN ingested_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) THEN job_id END) as mentions_last_7_days
FROM `usd-data-engineering.labor_market.skills_in_demand`
GROUP BY skill_name
ORDER BY mention_count DESC;