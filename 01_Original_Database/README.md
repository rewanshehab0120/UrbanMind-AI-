# 01_Original_Database

## Status: No original database file exists

There is **no pre-existing database file** (SQLite, PostgreSQL dump, or otherwise) anywhere in the UrbanMind-AI project. This has been verified directly against the project files — no `.db`, `.sqlite`, or similar file was ever provided or created prior to the final database built in `02_Final_Database/`.

## What the original source data actually is

The project's starting point was a flat feature table, not a database:

| File                            | Description                                                                              |
| ------------------------------- | ---------------------------------------------------------------------------------------- |
| `urbanmind_features_h3.csv`     | Original raw source data — 3,489 rows × 175 columns, one row per H3 cell (Resolution 8). |
| `urbanmind_features_h3.parquet` | Original source data in Parquet format — verified equivalent to the source CSV.          |
| `README_data_dictionary-1.md`   | Official data dictionary describing all 175 original columns.                            |

This folder is kept as a placeholder to make the absence of an original database explicit, rather than silently omitting it from the handover structure.
