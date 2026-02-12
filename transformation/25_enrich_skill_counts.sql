CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.skill_counts_enriched` AS
WITH onet AS (
  SELECT
    LOWER(TRIM(technology_skill)) AS skill_key,
    MAX(CASE WHEN UPPER(TRIM(hot_technology)) = 'Y' THEN 1 ELSE 0 END) AS is_hot_technology,
    MAX(CASE WHEN UPPER(TRIM(in_demand)) = 'Y' THEN 1 ELSE 0 END) AS is_in_demand,
    COUNT(*) AS onet_rows
  FROM `usd-data-engineering.labor_market.O_Net_Technology_Skills`
  WHERE technology_skill IS NOT NULL
  GROUP BY 1
)
SELECT
  sc.skill_name,
  sc.mention_count,
  sc.mentions_last_7_days,
  (o.skill_key IS NOT NULL) AS is_onet_skill,
  IFNULL(o.is_hot_technology, 0) AS is_hot_technology,
  IFNULL(o.is_in_demand, 0) AS is_in_demand,
  IFNULL(o.onet_rows, 0) AS onet_rows
FROM `usd-data-engineering.labor_market.skill_counts` sc
LEFT JOIN onet o
  ON LOWER(TRIM(sc.skill_name)) = o.skill_key
ORDER BY sc.mention_count DESC;
