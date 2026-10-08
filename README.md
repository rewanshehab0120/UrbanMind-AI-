# UrbanMind AI

### AI-Powered Smart City & Urban Digital Twin

## Project Overview

UrbanMind AI is an AI-powered Smart City and Urban Digital Twin project designed to transform fragmented urban data into a unified spatial intelligence system.

The project integrates multiple urban dimensions, including population, road infrastructure, traffic, public transportation, air quality, and green spaces. Using H3 spatial indexing, these datasets are connected through a common geographic unit, allowing different urban conditions to be analyzed together rather than as isolated datasets.

The integrated data is then processed through a complete data-to-decision pipeline combining data engineering, spatial analytics, Business Intelligence, Machine Learning, and Explainable AI.

## The Problem

Urban data is often distributed across different sources, formats, and spatial resolutions. When each dataset is analyzed separately, important relationships between urban factors can remain hidden.

For example, an area with high population density may also experience high traffic pressure, limited public transportation, poor air quality, or insufficient green space. Without integrating these dimensions spatially, it becomes difficult to identify areas that require attention and understand the factors contributing to their condition.

## The Solution

UrbanMind AI addresses this challenge by creating a unified spatial intelligence layer for urban data.

The system:

- Collects and integrates data from multiple urban sources.
- Uses H3 to establish a common spatial unit.
- Stores the integrated data in a centralized SQLite database.
- Cleans and validates the data while preserving the original source of truth.
- Uses EDA and Power BI to understand current urban conditions.
- Applies Machine Learning to identify urban pressure and vulnerability patterns.
- Uses Explainable AI (SHAP) to understand the factors behind model outputs.
- Converts analytical and ML results into actionable urban recommendations.

The overall approach follows:

**Analyze → Predict → Explain → Recommend**

## Target Users

UrbanMind AI is designed to support different users involved in urban planning and decision-making:

- **Government & City Authorities** — Support urban planning, infrastructure development, transportation planning, and environmental decisions.
- **Smart City Planners** — Identify high-pressure areas, underserved communities, transportation gaps, and environmental concerns.
- **Emergency & Public Service Planning** — Help prioritize areas where population and infrastructure pressure may require intervention.
- **Researchers & Analysts** — Explore relationships between urban, environmental, and socioeconomic factors.

## Project Workflow

```text
Data Collection
      ↓
Spatial Integration & H3
      ↓
SQLite Database
      ↓
Preprocessing & Cleaning
      ↓
EDA & Spatial Analysis
      ↓
Power BI Analytics
      ↓
Feature Engineering & Machine Learning
      ↓
Explainable AI (SHAP)
      ↓
Urban Recommendations
      ↓
Final Interface
```

## Repository Structure

```text
UrbanMind-AI/
│
├── 01_Data/
│   └── Raw and collected urban datasets
│
├── 02_Database/
│   ├── database/
│   └── sql_analysis/
│
├── 03_Data_Preprocessing_and_Cleaning/
│   └── Data cleaning, validation, and preparation
│
├── 04_PowerBI/
│   └── Power BI dashboards and related files
│
├── 05_Machine_Learning/
│   └── ML models, experiments, results, and explainability
│
├── 06_Reports/
│   └── Project reports, documentation, and figures
│
└── README.md
```

## Folder Overview

| Folder | Description |
|---|---|
| `01_Data` | Raw and collected urban datasets |
| `02_Database` | SQLite database and SQL analysis |
| `03_Data_Preprocessing_and_Cleaning` | Data cleaning, validation, and preparation |
| `04_PowerBI` | Power BI dashboards and analytics |
| `05_Machine_Learning` | Feature engineering, ML models, evaluation, and explainability |
| `06_Reports` | Project documentation, figures, and final reports |

## Technology Stack

- Python
- Pandas & NumPy
- GeoPandas, OSMnx & H3
- SQLite & SQL
- Power BI & DAX
- Scikit-learn
- XGBoost
- SHAP

## Project Goal

UrbanMind AI aims to move beyond simply visualizing urban data by creating a complete pipeline that connects **data integration, spatial intelligence, analytics, machine learning, explainability, and actionable recommendations**.

> **UrbanMind AI doesn't just visualize the city — it understands it, predicts its challenges, and helps decision-makers act on them.**
