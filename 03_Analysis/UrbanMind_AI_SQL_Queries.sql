-- ============================================================================
-- UrbanMind-AI — Approved SQL Analysis Queries
-- Target database: urbanmind_ai.db (SQLite, final Option-3 schema)
-- Tables: H3_Features (3,489 rows, 164 columns, PK h3_index)
--         Dim_District (41 rows, 3 columns, PK district_id)
-- Reviewed and corrected per UrbanMind_AI_SQL_Quality_Review.md
-- Read-only analysis queries — none of these modify any table.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q1. Population distribution & coverage
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN population_population_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_population,
       MIN(population_population_worldpop_2026) AS min_pop,
       MAX(population_population_worldpop_2026) AS max_pop,
       AVG(population_population_worldpop_2026) AS avg_pop
FROM H3_Features;

-- ----------------------------------------------------------------------------
-- Q2. Road network density distribution
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN roads_road_length_km IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_roads,
       ROUND(AVG(roads_road_density_km_per_km2), 3) AS avg_road_density,
       ROUND(MAX(roads_road_density_km_per_km2), 3) AS max_road_density,
       ROUND(AVG(roads_intersection_density), 3) AS avg_intersection_density
FROM H3_Features;

-- ----------------------------------------------------------------------------
-- Q3. Traffic structural network friction index
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN traffic_structural_network_friction_index IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_index,
       ROUND(AVG(traffic_structural_network_friction_index), 4) AS avg_index,
       ROUND(MAX(traffic_structural_network_friction_index), 4) AS max_index
FROM H3_Features;

-- ----------------------------------------------------------------------------
-- Q4. Traffic demand/capacity pressure index — ALWAYS check coverage first.
--     Coverage is 0.75% (26/3489). Do not rank or generalize city-wide.
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN traffic_demand_capacity_pressure_index IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_index,
       ROUND(100.0 * SUM(CASE WHEN traffic_demand_capacity_pressure_index IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS coverage_pct
FROM H3_Features;

SELECT ROUND(MIN(traffic_demand_capacity_pressure_index), 4) AS min_val,
       ROUND(MAX(traffic_demand_capacity_pressure_index), 4) AS max_val,
       ROUND(AVG(traffic_demand_capacity_pressure_index), 4) AS avg_val
FROM H3_Features
WHERE traffic_demand_capacity_pressure_index IS NOT NULL;

-- ----------------------------------------------------------------------------
-- Q5. Transit availability, with has_transit vs accessibility_score detail
--     (zero score is mostly a measured value, not a NULL-as-zero convention;
--      see Quality Review Issue 2)
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN transit_has_transit = 1 THEN 1 ELSE 0 END) AS cells_with_transit,
       ROUND(100.0 * SUM(CASE WHEN transit_has_transit = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_with_transit,
       ROUND(AVG(transit_transit_accessibility_score), 3) AS avg_accessibility_score
FROM H3_Features;

SELECT transit_has_transit,
       COUNT(*) AS n_cells,
       SUM(CASE WHEN transit_transit_accessibility_score IS NULL THEN 1 ELSE 0 END) AS score_null,
       SUM(CASE WHEN transit_transit_accessibility_score = 0 THEN 1 ELSE 0 END) AS score_zero,
       SUM(CASE WHEN transit_transit_accessibility_score > 0 THEN 1 ELSE 0 END) AS score_positive,
       ROUND(AVG(transit_transit_accessibility_score), 3) AS avg_score
FROM H3_Features
GROUP BY transit_has_transit;

-- ----------------------------------------------------------------------------
-- Q6. Air quality (NO2) distribution
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN air_quality_s5p_no2_tropospheric_column_mean_umol_m2 IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_aq,
       ROUND(MIN(air_quality_s5p_no2_tropospheric_column_mean_umol_m2), 2) AS min_no2,
       ROUND(MAX(air_quality_s5p_no2_tropospheric_column_mean_umol_m2), 2) AS max_no2,
       ROUND(AVG(air_quality_s5p_no2_tropospheric_column_mean_umol_m2), 2) AS avg_no2
FROM H3_Features;

-- ----------------------------------------------------------------------------
-- Q7. Green space coverage
--     CAVEAT: green_space_total_green_space_fraction does not numerically
--     reconcile with green_space_total_green_space_area_m2 for 26 cells
--     (fully agricultural/natural-reserve land). Use only as a general
--     descriptive indicator, not for precise per-cell calculations.
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN green_space_total_green_space_fraction IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_fraction,
       SUM(CASE WHEN green_space_has_public_green_space = 1 THEN 1 ELSE 0 END) AS cells_with_public_green_space,
       ROUND(AVG(green_space_total_green_space_fraction), 4) AS avg_fraction
FROM H3_Features;

-- ----------------------------------------------------------------------------
-- Q8. Cross-domain snapshot for the 5 most populated cells (no JOIN needed)
-- ----------------------------------------------------------------------------
SELECT h3_index,
       population_population_worldpop_2026 AS population,
       roads_road_density_km_per_km2 AS road_density,
       transit_transit_accessibility_score AS transit_score,
       air_quality_s5p_no2_tropospheric_column_mean_umol_m2 AS no2,
       green_space_total_green_space_fraction AS green_fraction
FROM H3_Features
ORDER BY population_population_worldpop_2026 DESC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- Q9 + Q9b (MERGED per Quality Review). District-level rollup via district_id,
--     with population coverage reported in the SAME result set — never
--     present a district population total without its coverage percentage.
-- ----------------------------------------------------------------------------
SELECT d.district_name,
       COUNT(f.h3_index) AS n_cells,
       SUM(CASE WHEN f.population_population_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_population,
       ROUND(100.0 * SUM(CASE WHEN f.population_population_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END) / COUNT(f.h3_index), 1) AS pop_coverage_pct,
       ROUND(SUM(f.population_population_worldpop_2026), 0) AS total_population_observed_cells_only,
       ROUND(AVG(f.roads_road_density_km_per_km2), 2) AS avg_road_density,
       ROUND(AVG(f.transit_transit_accessibility_score), 2) AS avg_transit_score
FROM H3_Features f
JOIN Dim_District d ON f.district_id = d.district_id
GROUP BY d.district_name
ORDER BY total_population_observed_cells_only DESC;
-- NOTE: Remove ORDER BY/LIMIT or re-sort by pop_coverage_pct ASC to inspect
-- low-coverage districts (e.g. El Tebbin, 15 May, New Cairo City).

-- Number of H3 cells excluded from any district-level rollup:
SELECT COUNT(*) AS cells_without_district FROM H3_Features WHERE district_id IS NULL;

-- ----------------------------------------------------------------------------
-- Q10. Assignment method distribution (H3-LEVEL attribute — do not group by
--      district; verified: assignment_method varies within 20 of 41 districts)
-- ----------------------------------------------------------------------------
SELECT assignment_method,
       COUNT(*) AS n_cells,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM H3_Features), 2) AS pct_of_all_cells
FROM H3_Features
GROUP BY assignment_method
ORDER BY n_cells DESC;

-- Validation: overlap_ratio by assignment_method (evidence, not naming inference)
SELECT assignment_method,
       COUNT(*) AS n_cells,
       ROUND(AVG(transit_district_overlap_ratio), 4) AS avg_overlap_ratio,
       ROUND(MIN(transit_district_overlap_ratio), 4) AS min_overlap_ratio,
       ROUND(MAX(transit_district_overlap_ratio), 4) AS max_overlap_ratio
FROM H3_Features
GROUP BY assignment_method
ORDER BY n_cells DESC;

-- ----------------------------------------------------------------------------
-- Q11. Population density vs. transit accessibility (descriptive, not causal)
--      Includes per-band valid-value counts per Quality Review requirement.
-- ----------------------------------------------------------------------------
SELECT
  CASE
    WHEN population_population_density_worldpop_2026 IS NULL THEN 'no_data'
    WHEN population_population_density_worldpop_2026 = 0 THEN 'zero_density'
    WHEN population_population_density_worldpop_2026 < 5000 THEN 'low (<5000/km2)'
    WHEN population_population_density_worldpop_2026 < 20000 THEN 'medium (5000-20000/km2)'
    ELSE 'high (>=20000/km2)'
  END AS density_band,
  COUNT(*) AS n_cells,
  SUM(CASE WHEN population_population_density_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END) AS n_valid_density,
  SUM(CASE WHEN transit_transit_accessibility_score IS NOT NULL THEN 1 ELSE 0 END) AS n_valid_transit_score,
  SUM(CASE WHEN population_population_density_worldpop_2026 IS NOT NULL
            AND transit_transit_accessibility_score IS NOT NULL THEN 1 ELSE 0 END) AS n_valid_both,
  ROUND(AVG(transit_transit_accessibility_score), 2) AS avg_transit_score,
  SUM(CASE WHEN transit_transit_accessibility_score = 0 THEN 1 ELSE 0 END) AS n_transit_score_zero
FROM H3_Features
GROUP BY density_band
ORDER BY n_cells DESC;

-- ----------------------------------------------------------------------------
-- Q12. Ranking: top 10 H3 cells by road density (coverage 99.97%, safe to rank)
-- ----------------------------------------------------------------------------
SELECT h3_index, roads_road_density_km_per_km2, roads_intersection_density
FROM H3_Features
WHERE roads_road_density_km_per_km2 IS NOT NULL
ORDER BY roads_road_density_km_per_km2 DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- Q13. Full coverage summary across all major domains (run BEFORE interpreting
--      any of the above — mandatory per project NULL-handling rules)
-- ----------------------------------------------------------------------------
SELECT 'population' AS domain,
       SUM(CASE WHEN population_population_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END) AS available,
       COUNT(*) AS total
FROM H3_Features
UNION ALL
SELECT 'roads', SUM(CASE WHEN roads_road_length_km IS NOT NULL THEN 1 ELSE 0 END), COUNT(*) FROM H3_Features
UNION ALL
SELECT 'traffic_structural_index', SUM(CASE WHEN traffic_structural_network_friction_index IS NOT NULL THEN 1 ELSE 0 END), COUNT(*) FROM H3_Features
UNION ALL
SELECT 'traffic_demand_capacity_index', SUM(CASE WHEN traffic_demand_capacity_pressure_index IS NOT NULL THEN 1 ELSE 0 END), COUNT(*) FROM H3_Features
UNION ALL
SELECT 'transit', SUM(CASE WHEN transit_transit_accessibility_score IS NOT NULL THEN 1 ELSE 0 END), COUNT(*) FROM H3_Features
UNION ALL
SELECT 'air_quality', SUM(CASE WHEN air_quality_s5p_no2_tropospheric_column_mean_umol_m2 IS NOT NULL THEN 1 ELSE 0 END), COUNT(*) FROM H3_Features
UNION ALL
SELECT 'green_space', SUM(CASE WHEN green_space_total_green_space_fraction IS NOT NULL THEN 1 ELSE 0 END), COUNT(*) FROM H3_Features
UNION ALL
SELECT 'district_assignment', SUM(CASE WHEN district_id IS NOT NULL THEN 1 ELSE 0 END), COUNT(*) FROM H3_Features;
