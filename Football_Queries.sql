-- PHASE 1: Identifying High-Potential Players
SELECT
  p.player_name,
  MAX(pa.potential) AS peak_potential,
  MAX(pa.overall_rating) AS peak_rating,
  (MAX(pa.potential) - MAX(pa.overall_rating)) AS growth_potential
FROM Player p
JOIN Player_Attributes pa ON p.player_api_id = pa.player_api_id
GROUP BY p.player_name
HAVING peak_rating < 75
AND peak_potential > 85
ORDER BY growth_potential DESC;

-- PHASE 2: Calculating the Engine Score
WITH High_Potential_Players AS (
  SELECT 
     p.player_name, 
     p.player_api_id,
     MAX(pa.potential) AS peak_potential, 
     MAX(pa.overall_rating) AS peak_rating,
	 (MAX(pa.potential) - MAX(pa.overall_rating)) AS growth_potential
  FROM Player p
  JOIN Player_Attributes pa ON p.player_api_id = pa.player_api_id
  GROUP BY p.player_name
  HAVING peak_potential > 85 AND peak_rating < 75 AND growth_potential >= 15
)
SELECT 
  hp.player_name,
  hp.peak_potential,
  (MAX(pa.stamina) + MAX(pa.interceptions) + MAX(pa.marking) + MAX(pa.reactions)) / 4 AS engine_score
FROM High_Potential_Players hp
JOIN Player_Attributes pa ON hp.player_api_id = pa.player_api_id
GROUP BY hp.player_name
ORDER BY engine_score DESC
LIMIT 10;

-- PHASE 3: Market Arbitrage Analysis
SELECT
  l.name AS league,
  COUNT(DISTINCT p.player_api_id) AS pool_size,
  ROUND(AVG(pa.overall_rating)) AS player_rating,
  ROUND((AVG(pa.stamina) + AVG(pa.interceptions) + AVG(pa.marking) + AVG(pa.reactions)) / 4, 2) AS value_score
FROM League l
JOIN Match m ON l.id = m.league_id
JOIN Player_Attributes pa ON m.home_player_1 = pa.player_api_id
JOIN Player p ON pa.player_api_id = p.player_api_id
GROUP BY l.name
ORDER BY value_score DESC;
