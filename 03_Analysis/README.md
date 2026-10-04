# 03_Analysis — SQL Analysis & Insights

This folder contains the SQL analysis and insights produced against the final database (`../02_Final_Database/urbanmind_ai.db`). **The analysis is separate from the database/schema implementation** — nothing here affects or redefines the schema in `02_Final_Database/`.

## Files

| File | Purpose |
|---|---|
| `UrbanMind_AI_SQL_Queries.sql` | 17 reproducible, read-only SQL statements covering 13 analysis questions (Q1–Q13). Verified to run successfully end-to-end against `urbanmind_ai.db`. |
| `UrbanMind_AI_SQL_Analysis_Report.md` | The full analysis: question plan, schema mapping, executed SQL, results, coverage/NULL checks, and evidence-based interpretation for each question. |
| `UrbanMind_AI_SQL_Quality_Review.md` | A follow-up review of five specific analytical points (assignment-method interpretation, transit zero-vs-NULL handling, district population coverage, density-vs-transit validity, green-space caveats), with the corrections it justified already applied to the Analysis Report above. |

## Running the queries

```bash
sqlite3 ../02_Final_Database/urbanmind_ai.db < UrbanMind_AI_SQL_Queries.sql
```

or in Python:

```python
import sqlite3
conn = sqlite3.connect("../02_Final_Database/urbanmind_ai.db")
conn.executescript(open("UrbanMind_AI_SQL_Queries.sql", encoding="utf-8").read())
```

## Key points carried over from the existing verified analysis (not re-derived here)

- 12 of 13 questions were successfully analyzed; 1 (`traffic_demand_capacity_pressure_index`) is explicitly blocked from city-wide interpretation due to only 0.75% coverage.
- District-level results always join via `district_id` (never `district_name`) and are reported alongside their population coverage percentage.
- `assignment_method` is treated as an H3-level attribute throughout, consistent with the final schema.

No new analysis was run and no new insights were created for this packaging step — see the two reports above for full detail and evidence.
