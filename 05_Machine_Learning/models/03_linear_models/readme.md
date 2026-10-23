# UrbanMind AI --- Linear Models & Scenario Engine

## Overview

This notebook evaluates regression targets for Cairo's urban dataset and
builds a **formula-based What-if Scenario Engine**. It separates
exploratory machine learning from scenario calculations.

-   **ML experiment:** test whether urban features can predict a target
    such as satellite-derived NO₂.
-   **Scenario engine:** compare urban-pressure scores before and after
    hypothetical changes to population, transit stops, and green space.
-   **Important:** the GUI does **not** predict pollution or real
    congestion. Scenario outputs are formula-based comparisons, not
    causal estimates.

## 1. Data Preparation

Initial dataset: **3,489 rows × 175 columns**.

1.  **Inspect columns and missingness** to understand data types,
    constant fields, and data quality.
2.  **Remove unsuitable columns:** 30 constant text columns, 8 columns
    with \>95% missing values, and selected
    redundant/location-identifier fields.
3.  **Encode booleans:** convert text `True`/`False` to `1`/`0` so
    numerical models can use them.
4.  **One-hot encode categories:** six small categorical columns became
    19 binary columns, avoiding an artificial numeric order between
    categories.
5.  Result: **3,489 × 146**; all columns numeric except the spatial
    identifier `h3_index`.
6.  **Build features and target:** remove rows with missing target
    values, exclude IDs/coordinates from the standard urban-feature
    model, and remove target-related columns to reduce leakage.
7.  **Handle missing feature values:** median imputation is performed
    inside the model pipeline.
8.  **Scale features:** `StandardScaler` puts features on comparable
    scales, especially important for Ridge and Lasso regularization.

## 2. Target Selection

A target (`y`) is the value the model learns to predict; features (`X`)
are its inputs.

  -----------------------------------------------------------------------
  Candidate target        Notebook finding        Recommendation
  ----------------------- ----------------------- -----------------------
  **NO₂ mean**            A real environmental    Best candidate for a
                          measurement; initial    genuine outcome, but
                          feature-model test was  current data is
                          useful, but performance insufficient for a
                          depended strongly on    credible
                          geography.              urban-intervention
                                                  What-if.

  **Traffic friction      Very high fit (about R² Calculate its formula
  index**                 = 1.00); the index is   directly rather than
                          derived from other      train ML to reproduce
                          road-network features.  it. It is not measured
                                                  congestion.

  **NDVI / vegetation     High fit (about R² =    Check how the target
  index**                 0.933); strongly        was constructed; not a
                          overlaps with           strong independent
                          vegetation-related      outcome for scenario
                          inputs.                 ML.

  **Transit               High fit (about R² =    If derived from inputs,
  accessibility**         0.919); overlaps with   calculate directly
                          access-related          instead of treating it
                          features.               as an independent
                                                  outcome.

  **Population**          High fit (about R² =    Predictable, but check
                          0.848) in the target    source overlap and
                          comparison.             whether it answers the
                                                  project question.
  -----------------------------------------------------------------------

**Target choice depends on the task:** use NO₂ when studying an actual
environmental outcome; use direct formulas for indicators that are
themselves derived from input columns. For the current GUI, the
**Composite Urban Pressure Index** is used for transparent scenario
comparison.

### Preventing target leakage

For NO₂, other NO₂ statistics (such as median and p90) and related
coverage/quality fields were removed from the features. Otherwise, the
model could use information from the same underlying measurement and
report misleadingly strong performance.

## 3. NO₂ Model Experiments

### Initial spatial holdout: 70% train / 30% test

The split groups geographic blocks so nearby cells are less likely to
appear in both training and testing. The first model used **122
features**.

  Model                                        R²        RMSE         MAE
  ---------------------------------- ------------ ----------- -----------
  Linear Regression                        0.7003       33.42       23.41
  Ridge Regression (`alpha ≈ 127`)         0.6985       33.52       23.16
  Lasso Regression                     **0.7062**   **33.09**   **22.93**

**Best initial score:** Lasso, by a small margin. It retained 64 of 122
features. RMSE and MAE are in the target's units; lower is better.
Higher R² is better.

### After removing duplicates and location proxies

The notebook removed highly correlated features and selected proxy
variables, leaving **80 features**.

  Model                         R²        RMSE         MAE
  ------------------- ------------ ----------- -----------
  Linear Regression     **0.5707**   **40.00**   **26.72**
  Ridge Regression          0.5660       40.22       27.62
  Lasso Regression          0.5518       40.87       27.77

After this feature-removal experiment, Linear Regression scored best
among these three. The drop in performance indicates that some removed
columns carried strong location-related signal. It also warns that the
earlier score did not necessarily reflect relationships useful for urban
interventions.

### Location and scenario tests

-   Location-only features (latitude/longitude with polynomial terms):
    approximately **R² = 0.85--0.87**.
-   Urban features alone after cleanup: approximately **R² = 0.57**.
-   Location + urban features: approximately **R² = 0.865**.
-   A machine-learning NO₂ What-if test changed the output by **less
    than 0.12%**, judged too small/unreliable to interpret as an
    intervention effect.
-   Friction, NDVI, and transit-access targets scored highly (about **R²
    = 0.92--1.00**) but are derived from overlapping input variables.

**Interpretation:** NO₂ in this dataset is strongly associated with
location. A high score does not prove that changing parks or transit
stops will change NO₂. The current NO₂ data is one satellite-period
average (2026-06-20 to 2026-09-16), not a repeated time series for each
cell.

## 4. Why These Models?

-   **Linear Regression:** learns a linear relationship by minimizing
    squared prediction errors.
-   **Ridge:** adds an L2 penalty to shrink coefficients and reduce
    instability from correlated features. `alpha` is a **model
    hyperparameter**.
-   **Lasso:** adds an L1 penalty and can shrink some coefficients to
    zero, performing feature selection.
-   **Evaluation:** R² measures explained variation; RMSE penalizes
    large errors more; MAE is the average absolute error.
-   **Spatial validation:** tests performance on geographic groups
    rather than relying only on a random row split.

## 5. Composite Urban Pressure Index

The GUI scores **2,090 cells** with both population and road data. Each
cell receives a relative score from 0 (lower pressure) to 1 (higher
pressure), based on three indicators:

1.  **People per road-kilometre:** higher is worse.
2.  **Green space per person:** lower is worse.
3.  **Transit stops per 1,000 people:** lower is worse.

Each indicator is ranked relative to the current cells, then the three
ranks are averaged with equal weights. Equal weighting is a design
assumption, not a validated official standard. A score of 0.8 means
roughly a high relative rank within this dataset---not an official
planning threshold.

## 6. GUI and What-if Engine

The Gradio GUI offers four modes:

  -----------------------------------------------------------------------
  Mode                    User sets               Engine calculates
  ----------------------- ----------------------- -----------------------
  **Pressure --- what     Population change,      Scenario pressure and
  happens?**              stops, green space, and change from baseline
                          share of cells to treat 

  **Green space --- how   Other inputs and target Approximate green space
  much is needed?**       mean pressure           needed per treated cell

  **Transit stops --- how Other inputs and target Approximate stops
  many are needed?**      mean pressure           needed per treated cell

  **Population --- how    Stops, green space, and Approximate population
  much growth can we      target mean pressure    growth that reaches the
  absorb?**                                       target
  -----------------------------------------------------------------------

### Hyperparameters vs. GUI inputs

-   `Ridge alpha` and similar settings affect **model training**.
-   GUI sliders are **scenario inputs** (e.g., +20% population, +2
    stops, +5,000 m² green space per treated cell) or a **target
    value**.
-   The GUI does not retrain the ML model. It calls the `scenario()`
    formula engine to recalculate pressure.
-   The "needed" modes use **bisection search** to find a value within
    defined bounds that brings the formula-based city-wide mean pressure
    toward the requested target. Results are rounded to practical
    values; a target outside the achievable range is reported as
    unreachable.

### Example default scenario

With population +20%, two additional stops and 5,000 m² green space per
treated cell, applied to the top 20% most pressured cells:

-   Mean pressure: **0.715 → 0.599**
-   Cells with pressure ≥ 0.75: **47.8% → 29.6%**
-   Cells treated: **418**
-   Stops added: **836**
-   Green space added: **209 hectares**

These figures describe the engine's formulas and assumptions, not
guaranteed real-world outcomes.

## 7. Limitations and Next Steps

-   The NO₂ target is a single satellite-period average, and its spatial
    resolution differs from the analysis cells.
-   Weather averages add little explanatory signal for a single period.
-   Traffic data is static network structure, not measured traffic speed
    or congestion.
-   PM2.5/PM10 fields are distances to monitoring stations, not
    pollutant concentrations.
-   Equal pressure-index weights and the treatment of empty cells are
    assumptions.
-   Model relationships are associations, not causal effects.

**To support a more credible ML What-if:** collect repeated NO₂
observations per cell and week, matching weather by date and adding real
traffic speeds; then validate with both spatial and temporal splits.

## Quick Summary

-   **Best initial NO₂ model:** Lasso (R² = 0.7062); after removing
    duplicates/location proxies, Linear Regression scored best (R² =
    0.5707).
-   **Best current GUI approach:** formula-based Composite Urban
    Pressure Index, because it is transparent and can recalculate
    explicit hypothetical changes.
-   **Do not claim:** the GUI predicts NO₂, real congestion, or causal
    effects of urban policies.
