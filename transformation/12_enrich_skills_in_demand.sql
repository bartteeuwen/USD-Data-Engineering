CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.skills_in_demand` AS
WITH onet AS (
  SELECT
    LOWER(TRIM(technology_skill)) AS skill_key,
    ANY_VALUE(hot_technology) AS hot_technology,
    ANY_VALUE(in_demand) AS in_demand
  FROM `usd-data-engineering.labor_market.O_Net_Technology_Skills`
  WHERE technology_skill IS NOT NULL AND TRIM(technology_skill) != ''
  GROUP BY skill_key
)
SELECT
  s.*,
  onet.hot_technology,
  onet.in_demand
FROM `usd-data-engineering.labor_market.skills_in_demand` s
LEFT JOIN onet
  ON LOWER(TRIM(s.skill_name)) = onet.skill_key;