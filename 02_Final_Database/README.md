# 02_Final_Database — Authoritative Schema & Database

**This is the most important folder in the handover.** `urbanmind_ai.db` here is the final, validated database that Diaa should continue building the connected database from.

## Final database

- **Database name:** `urbanmind_ai.db`
- **Database type:** SQLite (file-based, no server required — see Python section below)
- **Tables:** `H3_Features`, `Dim_District`

No weather table or any other table is currently part of the final database — only these two tables exist.

## `H3_Features`

- **Grain:** one row per H3 cell (Resolution 8)
- **Rows:** 3,489
- **Primary Key:** `h3_index`
- **Foreign Key:** `district_id` → `Dim_District.district_id`
- **`assignment_method`** remains a column in `H3_Features`, not in `Dim_District` — it is an H3-level attribute (verified to vary *within* 20 of the 41 districts), not a fixed district-level property.
- **Edge case:** H3 cell `883e604d65fffff` intentionally has `district_id = NULL` and `assignment_method = NULL`. This is a genuine source-data limitation (only 9.34% of this cell intersects the study boundary; the entire transit/roads/air-quality/green-space blocks are NULL for it in the source). **Do not invent a district assignment for this cell.**

## `Dim_District`

- The final, **pure** district dimension (41 rows — one row per district, no duplication).
- **Columns:** `district_id` (PK), `district_name`, `calibration_factor`.
- Each district has exactly one `calibration_factor` (verified 1:1).
- **A previous 76-row version of this table existed during development** (when `assignment_method` was incorrectly included as a dimension attribute). That version is **superseded** and must not be presented as the current schema — see `UrbanMind_AI_Schema_Correction_Report.md` in this folder for the full before/after explanation.

## Validation

This schema and database passed the following validation checks, documented in full (with exact queries and results) in `UrbanMind_AI_Schema_Correction_Report.md`:

- Row counts (`H3_Features` = 3,489, `Dim_District` = 41)
- Primary key validation (uniqueness, non-null)
- District uniqueness (41 unique district names = 41 rows)
- Calibration-factor consistency (exactly one value per district)
- Assignment-method validation (confirmed H3-level, not district-level)
- Referential integrity (no orphan `district_id` values)
- Value preservation (0 changed, 0 lost, 0 invented values vs. the validated staging source)
- Edge-cell validation (`883e604d65fffff` behaves exactly as expected)

No new validation was run for this packaging step — all results above are carried over unchanged from the existing verified reports.

## Files in this folder

| File | Purpose |
|---|---|
| `urbanmind_ai.db` | The final database. |
| `UrbanMind_AI_Schema_Correction_Report.md` | Full schema documentation: why `assignment_method` is H3-level, why `Dim_District` has 41 rows, edge-case handling, and complete validation results. |
| `UrbanMind_AI_Mapping_Validation_Report.csv` | Column-by-column mapping from the original 175 source columns to the final schema (DROP / KEEP / RENAME / MOVE_TO_DIMENSION). |
| `Dim_District_reference.csv` | A plain CSV export of `Dim_District`, for quick reference without opening the database. |

## Opening the database with Python

```python
import sqlite3

conn = sqlite3.connect("urbanmind_ai.db")

cursor = conn.cursor()

cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")

tables = cursor.fetchall()

print(tables)

conn.close()
```

SQLite is file-based and requires no separate database server — `urbanmind_ai.db` can be opened directly as shown above. If the team later migrates to a server-based database (PostgreSQL, MySQL, etc.), the connection code will change (host/port/credentials), but the schema and table structure documented here remain the reference design.
