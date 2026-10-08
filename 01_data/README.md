# UrbanMind AI — H3 Urban Features Dataset

## Overview
This dataset is a spatial feature table for **UrbanMind AI**, a city-scale Digital Twin project focused on understanding urban conditions, analyzing spatial patterns, and supporting future prediction and decision-making.

Each row represents one **H3 spatial cell**. The H3 cell is the common geographic unit used to combine multiple urban-data sources into one machine-learning/analytics-ready table.

**Dataset size:** 3,489 H3 cells × 175 columns

## What the Dataset Contains
Urban conditions are represented through several feature families:

- **Population:** `population_*` — WorldPop-based population and metadata.
- **Road Network:** `roads_*` — road geometry, density, topology, lanes and speed information.
- **Traffic:** `traffic_*` — derived structural and demand/capacity traffic indicators.
- **Public Transit:** `transit_*` — transit infrastructure, accessibility and population exposure.
- **Air Quality:** `air_quality_*` — Sentinel-5P/TROPOMI NO₂ plus monitoring-station proximity/coverage.
- **Green Space:** `green_space_*` — NDVI, vegetation, mapped green-space categories and quality metadata.

## Spatial Structure
- **`h3_index`** is the primary spatial key. It identifies the H3 cell to which all features belong.
- Latitude/longitude columns are representative coordinates for the corresponding H3 cell.
- Most measurements are aggregated, calculated, or spatially joined to the same H3 analytical grid.
- The dataset is therefore designed for **spatial comparison, EDA, feature engineering, visualization, and machine-learning workflows**.

## Data Sources & Meaning
- **Population:** WorldPop 2026 population estimates.
- **Roads / Transit:** OpenStreetMap / Geofabrik-based network information and derived accessibility features.
- **Air Quality:** Copernicus Sentinel-5P/TROPOMI NO₂ observations combined with an EEAA monitoring-network directory for station proximity/coverage.
- **Green Space:** NDVI/vegetation observations and mapped green-space categories.

## Important Data-Quality Notes
`NaN` values are retained intentionally. A missing value can mean that a source does not cover a cell, a particular feature is not applicable, or the metric could not be calculated reliably. It should **not automatically be replaced with zero**.

Boolean/flag columns such as `*_is_observed`, `*_is_estimated`, `*_fallback_flag`, and `*_available` should be used to interpret feature availability before modelling.

Categorical quality columns such as `*_quality_flag`, `*_coverage_flag`, and `*_data_status` provide additional context about reliability and processing status.

## Feature Dictionary

### 1. Core Spatial Identifier

| Column | Description |
|---|---|
| `h3_index` | Unique H3 spatial cell identifier used as the common geographic key. |

### 2. Population Features

| Column | Description |
|---|---|
| `population_population_worldpop_2026` | Estimated population within the H3 cell for 2026 from WorldPop. |
| `population_population_density_worldpop_2026` | Estimated population per km² within the H3 cell. |
| `population_area_km2` | Area of the H3 cell intersecting the study area, in km². |
| `population_cell_full_area_km2` | Full geometric area of the H3 cell, in km². |
| `population_cairo_intersection_ratio` | Fraction of the H3 cell that intersects the Cairo study boundary. |
| `population_latitude` | Representative latitude of the H3 cell. |
| `population_longitude` | Representative longitude of the H3 cell. |
| `population_reference_year` | Reference year of the population dataset. |
| `population_source` | Population data provider. |
| `population_source_version` | Version of the population source. |
| `population_source_dataset` | Specific WorldPop dataset identifier. |
| `population_spatial_resolution_m` | Native population raster resolution, in meters. |
| `population_analytical_grid` | Grid used to align population data with the UrbanMind analytical cells. |
| `population_crs` | Coordinate Reference System used for the population layer. |
| `population_population_type` | Population product/type, e.g. constrained population. |
| `population_is_observed` | Whether the value is directly observed rather than estimated. |
| `population_is_estimated` | Whether the population value is estimated/modelled. |
| `population_quality_flag` | Quality/status flag for the population feature. |
| `population_production_date` | Date associated with production or release of the population dataset. |
| `population_doi` | Digital Object Identifier of the population source, when available. |
| `population_source_url` | Source URL for the population dataset. |

### 3. Road Network Features

| Column | Description |
|---|---|
| `roads_latitude` | Representative latitude of the H3 cell for road features. |
| `roads_longitude` | Representative longitude of the H3 cell for road features. |
| `roads_area_km2` | Study-area/H3 intersection area used for road calculations, in km². |
| `roads_road_length_km` | Total mapped road length in the cell, in km. |
| `roads_road_density_km_per_km2` | Road length per km². |
| `roads_motorway_length_km` | Length of motorway-class roads, in km. |
| `roads_trunk_length_km` | Length of trunk roads, in km. |
| `roads_primary_road_length_km` | Length of primary roads, in km. |
| `roads_secondary_road_length_km` | Length of secondary roads, in km. |
| `roads_tertiary_road_length_km` | Length of tertiary roads, in km. |
| `roads_residential_road_length_km` | Length of residential roads, in km. |
| `roads_service_road_length_km` | Length of service roads, in km. |
| `roads_other_road_length_km` | Length of other mapped road classes, in km. |
| `roads_oneway_ratio` | Share of mapped road length tagged as one-way. |
| `roads_intersection_count` | Number of road intersections in the cell. |
| `roads_intersection_density` | Number of intersections per km². |
| `roads_dead_end_count` | Number of dead-end road features. |
| `roads_dead_end_ratio` | Share of road network represented by dead-end segments. |
| `roads_bridge_ratio` | Share of road length on bridges. |
| `roads_tunnel_ratio` | Share of road length in tunnels. |
| `roads_lit_road_ratio` | Share of road length tagged as lit. |
| `roads_lane_km` | Total lane length, in lane-km. |
| `roads_avg_lanes` | Average number of lanes where lane information is available. |
| `roads_maxspeed_coverage` | Share of road features with a mapped maximum-speed value. |
| `roads_avg_maxspeed` | Average mapped maximum speed, in km/h, where available. |
| `roads_reference_year` | Reference year for the road data. |
| `roads_source` | Road network data source. |
| `roads_snapshot_date` | Date of the road-network snapshot. |
| `roads_analytical_grid` | Grid used to aggregate road features. |

### 4. Traffic Features

| Column | Description |
|---|---|
| `traffic_population_2026` | 2026 population used as the demand-side input for traffic indicators. |
| `traffic_road_length_km` | Total road length used by the traffic feature set, in km. |
| `traffic_road_density_km_per_km2` | Road density used in traffic calculations. |
| `traffic_lane_km` | Total lane length used in traffic calculations, in lane-km. |
| `traffic_avg_lanes` | Average lanes used in traffic calculations. |
| `traffic_motorway_trunk_length_km` | Motorway and trunk road length used as higher-capacity network input, in km. |
| `traffic_primary_secondary_length_km` | Primary and secondary road length, in km. |
| `traffic_intersection_count` | Intersection count used in traffic structural calculations. |
| `traffic_intersection_density` | Intersection density used in traffic calculations. |
| `traffic_dead_end_ratio` | Dead-end ratio used in the structural network assessment. |
| `traffic_bridge_ratio` | Bridge ratio used in the structural network assessment. |
| `traffic_tunnel_ratio` | Tunnel ratio used in the structural network assessment. |
| `traffic_oneway_ratio` | One-way ratio used in the structural network assessment. |
| `traffic_avg_maxspeed` | Average mapped speed used in traffic calculations, in km/h. |
| `traffic_population_per_road_km` | Population divided by road length; a demand intensity proxy. |
| `traffic_population_per_lane_km` | Population divided by lane-km; a demand-to-capacity pressure proxy. |
| `traffic_lane_km_per_km2` | Lane-km per km². |
| `traffic_intersection_per_road_km` | Intersections per km of road. |
| `traffic_intersection_density_norm` | Normalized intersection-density component used in the structural index. |
| `traffic_dead_end_ratio_norm` | Normalized dead-end component used in the structural index. |
| `traffic_bridge_ratio_norm` | Normalized bridge component used in the structural index. |
| `traffic_tunnel_ratio_norm` | Normalized tunnel component used in the structural index. |
| `traffic_oneway_ratio_norm` | Normalized one-way component used in the structural index. |
| `traffic_population_per_lane_km_norm` | Normalized population-per-lane-km component used in the demand-pressure index. |
| `traffic_structural_network_friction_index` | Composite index representing structural friction/susceptibility of the road network. |
| `traffic_demand_capacity_pressure_index` | Composite index representing population pressure relative to road/lane capacity proxies. |
| `traffic_structural_susceptibility_class` | Categorical class derived from the structural network friction index. |
| `traffic_demand_capacity_pressure_class` | Categorical class derived from demand-capacity pressure. |
| `traffic_structural_index_available` | Flag indicating whether the structural traffic index is available for the cell. |
| `traffic_demand_capacity_index_available` | Flag indicating whether the demand-capacity traffic index is available. |
| `traffic_combined_index_available` | Flag indicating whether the combined traffic indicator is available. |
| `traffic_index_coverage_flag` | Traffic-index coverage/status flag. |
| `traffic_reference_year` | Reference year of the traffic feature inputs. |
| `traffic_source_type` | Type of source used to build traffic features. |
| `traffic_quality_flag` | Quality/status flag for traffic indicators. |

### 5. Public Transit Features

| Column | Description |
|---|---|
| `transit_latitude` | Representative latitude of the H3 cell for transit features. |
| `transit_longitude` | Representative longitude of the H3 cell for transit features. |
| `transit_area_km2` | Area used for transit aggregation, in km². |
| `transit_has_transit` | Boolean indicating whether mapped public-transit infrastructure exists in the cell. |
| `transit_transit_stop_count` | Total number of mapped transit stops. |
| `transit_metro_station_count` | Number of metro stations. |
| `transit_light_rail_station_count` | Number of light-rail stations. |
| `transit_rail_station_count` | Number of rail stations. |
| `transit_brt_station_count` | Number of Bus Rapid Transit stations. |
| `transit_bus_stop_count` | Number of bus stops. |
| `transit_paratransit_stop_count` | Number of paratransit stops. |
| `transit_interchange_station_count` | Number of interchange/multimodal transfer stations. |
| `transit_transit_mode_count` | Number of distinct transit modes represented in the cell. |
| `transit_transit_modes_available` | List/string of transit modes available in or associated with the cell. |
| `transit_stop_density_per_km2` | Transit stops per km². |
| `transit_nearest_transit_stop_network_distance_m` | Network distance to the nearest transit stop, in meters. |
| `transit_nearest_metro_station_network_distance_m` | Network distance to the nearest metro station, in meters. |
| `transit_nearest_brt_station_network_distance_m` | Network distance to the nearest BRT station, in meters. |
| `transit_transit_stops_within_400m_walk` | Number of transit stops within a 400 m walking/network threshold. |
| `transit_transit_stops_within_800m_walk` | Number of transit stops within an 800 m walking/network threshold. |
| `transit_transit_stops_within_1200m_walk` | Number of transit stops within a 1,200 m walking/network threshold. |
| `transit_metro_stations_within_800m_walk` | Number of metro stations within an 800 m walking/network threshold. |
| `transit_metro_stations_within_1500m_walk` | Number of metro stations within a 1,500 m walking/network threshold. |
| `transit_brt_stations_within_1000m_walk` | Number of BRT stations within a 1,000 m walking/network threshold. |
| `transit_multimodal_hub_present` | Boolean indicating presence of a multimodal transit hub. |
| `transit_population_within_400m_transit` | Estimated population within 400 m of transit access. |
| `transit_population_within_800m_transit` | Estimated population within 800 m of transit access. |
| `transit_population_within_1200m_transit` | Estimated population within 1,200 m of transit access. |
| `transit_transit_accessibility_score` | Composite score summarizing transit accessibility. |
| `transit_reference_year` | Reference year of the transit/network inputs. |
| `transit_analytical_grid` | Grid used for transit aggregation. |
| `transit_raw_worldpop_2026` | Raw WorldPop 2026 population used before district-level calibration. |
| `transit_district` | Administrative district assigned to the cell. |
| `transit_district_calibration_factor` | Factor used to calibrate cell population to district-level totals. |
| `transit_calibrated_pop_2026` | Population after district-level calibration. |
| `transit_district_assignment_method` | Method used to assign the cell to a district. |
| `transit_district_overlap_ratio` | Share/ratio of the H3 cell overlapping the assigned district. |
| `transit_fallback_flag` | Flag indicating that a fallback assignment/calibration method was used. |

### 6. Air Quality Features

| Column | Description |
|---|---|
| `air_quality_latitude` | Representative latitude of the H3 cell for air-quality features. |
| `air_quality_longitude` | Representative longitude of the H3 cell for air-quality features. |
| `air_quality_area_km2` | Area used for air-quality aggregation, in km². |
| `air_quality_s5p_no2_tropospheric_column_mean_umol_m2` | Mean Sentinel-5P/TROPOMI tropospheric NO₂ column, in µmol/m². |
| `air_quality_s5p_no2_tropospheric_column_median_umol_m2` | Median Sentinel-5P/TROPOMI tropospheric NO₂ column, in µmol/m². |
| `air_quality_s5p_no2_tropospheric_column_p90_umol_m2` | 90th percentile of the Sentinel-5P/TROPOMI tropospheric NO₂ column, in µmol/m². |
| `air_quality_s5p_no2_observation_count` | Number of valid NO₂ observations contributing to the cell. |
| `air_quality_s5p_no2_valid_fraction` | Fraction of observations/pixels considered valid for NO₂. |
| `air_quality_s5p_no2_quality_flag` | Quality/status flag for satellite NO₂ coverage. |
| `air_quality_nearest_pm25_station_distance_km` | Distance to the nearest PM2.5 monitoring station, in km. |
| `air_quality_nearest_pm10_station_distance_km` | Distance to the nearest PM10 monitoring station, in km. |
| `air_quality_nearest_station_id` | Identifier of the nearest air-quality monitoring station. |
| `air_quality_nearest_station_name` | Name of the nearest air-quality monitoring station. |
| `air_quality_pm25_station_count_within_5km` | Number of PM2.5 monitoring stations within 5 km. |
| `air_quality_pm10_station_count_within_5km` | Number of PM10 monitoring stations within 5 km. |
| `air_quality_pm25_station_coverage_flag` | PM2.5 monitoring-station coverage/proximity status. |
| `air_quality_pm10_station_coverage_flag` | PM10 monitoring-station coverage/proximity status. |
| `air_quality_reference_year` | Reference year of the air-quality data. |
| `air_quality_observation_start` | Start date of the air-quality observation period. |
| `air_quality_observation_end` | End date of the air-quality observation period. |
| `air_quality_source` | Air-quality data sources/providers. |
| `air_quality_source_type` | Method/type of air-quality source combination. |
| `air_quality_source_version` | Version identifier for the air-quality source. |
| `air_quality_native_spatial_resolution_m` | Native spatial resolution of the satellite NO₂ product, in meters. |
| `air_quality_analytical_grid` | Grid used to aggregate air-quality observations. |

### 7. Green Space Features

| Column | Description |
|---|---|
| `green_space_ndvi_mean_summer_2026` | Mean summer 2026 NDVI. |
| `green_space_ndvi_median_summer_2026` | Median summer 2026 NDVI. |
| `green_space_ndvi_p90_summer_2026` | 90th percentile summer 2026 NDVI. |
| `green_space_ndvi_min_summer_2026` | Minimum summer 2026 NDVI. |
| `green_space_vegetated_fraction_summer_2026` | Fraction of the cell classified as vegetated during summer 2026. |
| `green_space_ndvi_mean_annual_2026` | Mean annual 2026 NDVI. |
| `green_space_ndvi_median_annual_2026` | Median annual 2026 NDVI. |
| `green_space_ndvi_p90_annual_2026` | 90th percentile annual 2026 NDVI. |
| `green_space_ndvi_min_annual_2026` | Minimum annual 2026 NDVI. |
| `green_space_vegetated_fraction_annual_2026` | Fraction of the cell classified as vegetated across the annual period. |
| `green_space_observation_count_2026` | Number of valid observations contributing to vegetation metrics. |
| `green_space_valid_pixel_fraction` | Fraction of pixels considered valid for vegetation analysis. |
| `green_space_vegetation_persistence_ratio` | Ratio indicating how consistently vegetation was observed across the analyzed period. |
| `green_space_total_green_space_area_m2` | Total mapped green-space area, in m². |
| `green_space_public_green_space_area_m2` | Mapped public green-space area, in m². |
| `green_space_private_restricted_green_space_area_m2` | Mapped private/restricted green-space area, in m². |
| `green_space_agricultural_area_m2` | Mapped agricultural green-space area, in m². |
| `green_space_natural_reserve_area_m2` | Mapped natural-reserve area, in m². |
| `green_space_number_of_public_parks` | Number of mapped public parks. |
| `green_space_total_green_space_fraction` | Fraction of the cell covered by total mapped green space. |
| `green_space_public_green_space_fraction` | Fraction of the cell covered by public green space. |
| `green_space_has_public_green_space` | Boolean indicating whether public green space is present. |
| `green_space_is_observed` | Indicates whether the green-space feature is directly observed. |
| `green_space_is_derived` | Indicates whether the green-space feature is derived/calculated from other data. |
| `green_space_data_status` | Processing/finalization status of the green-space data. |
| `green_space_quality_flag` | Quality/status flag for green-space features. |

## Units & Common Conventions
| Convention | Meaning |
|---|---|
| `*_km` | Distance/length in kilometers. |
| `*_m` | Distance/length in meters. |
| `*_km2` | Area in square kilometers. |
| `*_m2` | Area in square meters. |
| `*_ratio` | Ratio/proportion, normally between 0 and 1 unless otherwise stated. |
| `*_fraction` | Fraction/proportion, normally between 0 and 1. |
| `*_density` | Quantity normalized by area or another spatial unit. |
| `*_count` | Count of objects/observations/features. |
| `*_index` | Derived/composite indicator rather than a raw measurement. |
| `*_flag` | Status, quality, coverage, or availability indicator. |
| `*_class` | Categorical interpretation of a derived index. |

## Suggested Use
This table can be used as the feature layer for:
- Exploratory spatial analysis and urban profiling
- Power BI / dashboard development
- Traffic and mobility analysis
- Environmental and air-quality analysis
- Green-space and urban sustainability analysis
- Feature engineering for UrbanMind AI prediction models
- Spatial clustering and hotspot analysis
- Cross-domain relationships between population, mobility, pollution, and urban greenery.

## Recommended Modelling Practice
Before training a machine-learning model:
1. Identify the target variable and avoid using features that leak future information.
2. Inspect missingness by feature family.
3. Use quality/availability flags to distinguish unavailable data from true zero values.
4. Treat categorical fields separately from continuous numerical features.
5. Check highly correlated derived features before modelling.
6. Preserve `h3_index` for spatial joins and mapping, but normally exclude it as a raw numerical predictor.
7. Use spatially aware train/validation splits when evaluating spatial prediction models to reduce geographic leakage.

## Project Context
UrbanMind AI aims to build a Digital Twin of Cairo using heterogeneous real-world data. This feature table provides a common spatial layer where different urban dimensions can be analyzed together.

**Key idea:** instead of analyzing traffic, population, air quality, transit, and green space as isolated datasets, UrbanMind converts them into aligned spatial features for the same H3 cells.

---
*Generated from the current `urbanmind_features_h3.csv` schema. Feature descriptions explain the role and intended interpretation of each column based on its name and observed structure.*
