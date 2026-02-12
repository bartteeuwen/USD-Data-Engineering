CREATE OR REPLACE TABLE `usd-data-engineering.labor_market.skill_counts` AS
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
  c.*,
  onet.hot_technology,
  onet.in_demand
FROM `usd-data-engineering.labor_market.skill_counts` c
LEFT JOIN onet
  ON LOWER(TRIM(c.skill_name)) = onet.skill_key;
