# UrbanMind AI

Urban analytics and machine learning on H3 hexagonal cells in Cairo. The project builds models and an interpretable index from traffic, road-network, public-transit, population, green-space and air-quality indicators.

## 1. Project status at a glance

| Target | Column | Status | Input features | Main result |
|---|---|---|---|---|
| 1. Traffic structural susceptibility | `traffic_structural_susceptibility_class` | **Model trained** (CatBoost) | 7 | Spatial-CV macro-F1 ≈ 0.68 |
| 2. Traffic demand-capacity pressure | `traffic_demand_capacity_pressure_class` | **Deferred, no model trained** | n/a | Only 26 labeled cells |
| 3. Urban intervention priority | `urban_intervention_priority_class` (from `urban_intervention_priority_score`) | **Model trained** (CatBoost) | 66 | Spatial-CV macro-F1 ≈ 0.61–0.65 |

Two of the three targets have trained models. Target 2 is documented as deferred because of a data limitation.

## 2. Data

- **Unit of analysis:** H3 cell (`h3_index`), 3,489 cells.
- **Columns:** 175 original, 177 in the exported dataset.
- **Domains:** traffic and roads, public transit, population, green space, air quality.
- **Exported file:** `urban_intervention_priority_dataset.csv` (3,489 rows × 177 columns; reloaded and validated after export).

| Target column | Non-missing labels |
|---|---|
| `traffic_structural_susceptibility_class` | 3,488 |
| `traffic_demand_capacity_pressure_class` | 26 |
| `urban_intervention_priority_score` | 3,488 |
| `urban_intervention_priority_class` | 3,488 |

## 3. Target 1: Traffic structural susceptibility

**Goal:** classify cells as LOW / MODERATE / HIGH structural susceptibility (class counts: LOW 1,263, HIGH 1,151, MODERATE 1,074; 1 missing).

### 3.1 Leakage investigation

An initial CatBoost model on 11 features reached **98.42% test accuracy** (2,790 train / 698 test, best iteration 224). This number is **not** treated as predictive performance, for these reasons:

1. A threshold rule on `traffic_structural_network_friction_index` reproduced the class for 3,487 of 3,488 valid cells (≈ 99.97%): index = 0 → LOW; up to 0.212780 → MODERATE; above → HIGH.
2. The friction index was not itself an input, but the 11 inputs predicted it with **CV R² = 0.9955**, so the classifier was effectively reproducing the target-generation formula (indirect leakage).
3. A feature-group ablation (5-fold stratified CV, HistGradientBoosting) confirmed the dependence on road-structure features:

| Feature set | Features | Accuracy | Macro-F1 |
|---|---|---|---|
| A: all 11 (leaky baseline) | 11 | 0.9768 | 0.9757 |
| B: without road density, intersection density, dead-end ratio, one-way ratio | 7 | 0.7202 | 0.7099 |
| C: non-road context only | 5 | 0.6924 | 0.6802 |

The four removed features were chosen from correlation with the index, not from the original formula, so residual leakage cannot be fully excluded. The original 98.42% result is kept for transparency only.

### 3.2 Final model (feature set B)

**Features (7):** population density (WorldPop 2026), bridge ratio, tunnel ratio, transit stop count, transit mode count, transit accessibility score, annual NDVI 2026.

**Correlations:** transit stop count and mode count are perfectly rank-correlated (ρ = 1.00) and both correlate 0.82 with the accessibility score. Other pairs are weak to moderate (maximum 0.66: population density vs. accessibility score).

**Model:** CatBoost (MultiClass, depth 6, learning rate 0.05, early stopping; best iteration 367).

| Evaluation | Accuracy | Macro-F1 |
|---|---|---|
| Random stratified 80/20 split (698 test cells) | 0.7507 | 0.7416 |
| Spatial 5-fold GroupKFold (10 KMeans clusters on H3 centroids) | 0.7265 | 0.6781 ± 0.0710 |

- Per-class F1 (random split): HIGH 0.771, LOW 0.848, MODERATE 0.605.
- Errors occur almost entirely between adjacent classes; HIGH↔LOW confusions are rare (7 of 698).
- Spatial fold macro-F1 ranges from 0.612 to 0.795, so performance varies across regions of Cairo.
- Feature importance: population density 63.7%, NDVI 19.6%, bridge ratio 8.9%, transit accessibility 4.6%.

**Realistic estimate:** macro-F1 ≈ 0.68 (spatial CV).

## 4. Target 2: Traffic demand-capacity pressure (deferred)

- Only **26 of 3,489 cells (0.75%)** have a class label (HIGH 9, LOW 9, MODERATE 8). The related index and `traffic_population_per_lane_km` share the same sparse availability, and the availability flag is consistent with them.
- The feature-engineering code that generates the index is not part of this notebook, so the reason for the missing values could not be established and the labels cannot be recomputed.
- Training on 26 rows would not give a reliable evaluation, and labels were deliberately **not** imputed or fabricated.

**Status:** no model trained.

**Future work:** recover the original code, determine why only 26 cells receive valid values, recompute the index for all cells if its inputs are available, then train and evaluate with spatially blocked validation.

## 5. Target 3: Urban intervention priority

### 5.1 Priority score (analytical composite)

Six indicators were retained after a correlation screen (redundant `traffic_road_density_km_per_km2` and `transit_transit_mode_count` were dropped):

| Indicator | Direction |
|---|---|
| `traffic_intersection_density` | higher = higher priority |
| `roads_dead_end_ratio` | higher = higher priority |
| `transit_transit_accessibility_score` | lower = higher priority |
| `green_space_public_green_space_fraction` | lower = higher priority |
| `green_space_ndvi_mean_annual_2026` | lower = higher priority |
| `air_quality_s5p_no2_tropospheric_column_mean_umol_m2` | higher = higher priority |

**Construction:** Min-Max scaling per indicator, direction reversal where needed, equal-weight mean, at least 5 of 6 indicators required, multiplied by 100 (0–100 scale). Non-missing scores: 3,488 (mean 51.90, SD 5.33, min 37.33, max 76.64).

**Classes:** fixed thresholds produced a very unbalanced result (MODERATE 3,434, HIGH 54, LOW 0), so classes are tertiles of the score (cutoffs ≈ 48.87 and 53.14): LOW 1,163, MODERATE 1,162, HIGH 1,163.

This is a baseline analytical composite, **not** an externally validated or official index. Classes express relative ranking within this dataset.

### 5.2 Sensitivity analysis

The score was recomputed under alternative weights (the recomputation matched the stored score exactly) and classes re-derived as tertiles each time.

| Scenario group | Same-class share | Spearman vs. baseline | LOW↔HIGH jumps |
|---|---|---|---|
| Leave one indicator out (5 of 6) | 0.80–0.98 | 0.90–0.99 | 0.1–1.3% |
| Leave out NO2 | 0.605 | 0.662 | 3.8% |
| Double one indicator's weight | 0.85–0.98 | 0.92–0.996 | 0–1.3% |
| 1,000 random Dirichlet weightings (mean) | 0.763 | 0.830 | 2.3% |
| 1,000 random Dirichlet weightings (5th–95th pct.) | 0.52–0.90 | 0.51–0.97 | 0.1–8.7% |

The ranking is reasonably stable; class membership is more sensitive because classes are tertile cutoffs. NO2 is the most influential indicator (removing it changes about 40% of classes); public green-space fraction is the least influential.

### 5.3 Machine-learning model

A model trained on the six score inputs would only reproduce the formula. The model therefore predicts the priority class from **other** columns:

- Starting from 90 candidates (≥ 95% coverage), 15 near-duplicates of the score inputs (|ρ| ≥ 0.90) were removed, along with coordinates, target/index/availability columns, and the two redundant indicators.
- A robustness check removed the three cell-area columns, leaving **66 features**: transit 25, green space 15, roads 13, traffic 7, air quality 6.
- 19 feature pairs have |ρ| ≥ 0.90 and 40 have |ρ| ≥ 0.80 (of 2,145 pairs), mostly duplicated `roads_*` / `traffic_*` columns, so the effective number of independent features is lower than 66.

**Model:** CatBoost (MultiClass, depth 6, learning rate 0.05, early stopping; best iteration 708).

| Evaluation | Accuracy | Macro-F1 |
|---|---|---|
| Random stratified 80/20 split (with area columns, 69 features) | 0.8252 | 0.8263 |
| Spatial 5-fold (with area columns, 69 features) | 0.7397 | 0.6483 ± 0.0502 |
| **Random 80/20 split (final, 66 features)** | **0.8181** | **0.8194** |
| **Spatial 5-fold (final, 66 features)** | **0.7202** | **0.6077 ± 0.0925** |

- Per-class F1 (random split, final): HIGH 0.803, LOW 0.897, MODERATE 0.758.
- The gap between random and spatial results shows that much of the random-split score comes from similarity between neighboring cells. **The spatial macro-F1 (≈ 0.61–0.65) is the realistic estimate.**
- Top features (final): nearest BRT station distance 21.1%, nearest transit stop distance 9.2%, nearest metro station distance 7.0%, service-road length 6.5%. These likely encode a cell's position relative to the transit network.
- The difference between the 69- and 66-feature runs may partly reflect run-to-run noise (single seed, different early-stopping iteration counts); it was not tested for significance.

## 6. Methodology notes

- **Validation:** stratified random splits plus spatially blocked validation (H3 cell centroids clustered with KMeans into 10 groups, 5-fold GroupKFold), because neighboring H3 cells are similar.
- **Metrics:** accuracy, macro-F1, per-class precision/recall, confusion matrices.
- **Leakage screening:** name-based screening, single-feature screening, reconstruction of the defining index from model inputs, feature-group ablation, and correlation screening against score inputs.
- **Tools:** Python, pandas, NumPy, scikit-learn, CatBoost, h3, matplotlib.

## 7. Limitations

- Targets 1 and 3 are derived labels (threshold or quantile rules on computed indices), not independently observed outcomes. The models approximate these rules from other context.
- Features were screened by correlation, not by the original formulas, so residual indirect leakage cannot be excluded.
- Spatial CV uses KMeans blocks of unequal size and a single seed; fold results vary notably across Cairo.
- Target 3 classes are relative tiers, not validated intervention categories. Equal weights and Min-Max scaling (sensitive to outliers) are methodological choices.
- Feature importance is associative, not causal.
- Target 2 has no model, so no claim is made about demand-capacity pressure prediction.

## 8. Files

| File | Description |
|---|---|
| `urban_intervention_priority_dataset.csv` | Final dataset with engineered targets (3,489 × 177) |
| Project notebook (`.ipynb`) | Full analysis, leakage checks, models, sensitivity analysis |
| `README.md` | This document |
