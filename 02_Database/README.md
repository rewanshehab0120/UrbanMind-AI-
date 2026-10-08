# UrbanMind-AI

Urban-analytics dataset and database for Greater Cairo, built on H3 spatial cells (Resolution 8) across six domains: Population, Roads, Traffic, Transit, Air Quality, and Green Space.

## Where to go

| If you need to...                                                | Go to                                                                                                                                          |
| ---------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Continue building the connected database / extend the schema** | [`02_Final_Database/`](./02_Final_Database/) — **start here.** Contains the authoritative `urbanmind_ai.db` and its full schema documentation. |
| **Review or reproduce the SQL analysis and insights**            | [`03_Analysis/`](./03_Analysis/)                                                                                                               |
| **Check what original source data existed (no database)**        | [`01_Original_Database/`](./01_Original_Database/)                                                                                             |

## Authoritative version

**The final schema and database in `02_Final_Database/` are the authoritative version of this project.**

They have passed full validation, including row counts, primary-key checks, referential integrity, value-preservation checks against the source data, and edge-case handling. See `02_Final_Database/UrbanMind_AI_Schema_Correction_Report.md` for complete results.

## Original CSV/Parquet Verification

The original source files `urbanmind_features_h3.csv` and `urbanmind_features_h3.parquet` were verified to contain the same 3,489 rows and 175 columns, with identical values and NULL distribution.

The only difference is storage precision (`float32` vs `float64`) in 7 NDVI-related columns.
