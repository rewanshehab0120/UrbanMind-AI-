# UrbanMind-AI — SQL Analysis Phase: Plan & Executed Results
**المرحلة:** SQL Analysis — لم يتم تعديل الـSchema أو ملفات الـstaging.
**قاعدة البيانات المُستخدَمة:** `urbanmind_ai.db` (النسخة النهائية المعتمدة، Option 3).

> **ملاحظة:** هذا التقرير مُحدَّث بعد عملية Analytical Quality Review مركزة. راجع `UrbanMind_AI_SQL_Quality_Review.md` للتفاصيل الكاملة لكل تصحيح. المواضع المُحدَّثة معلَّمة أدناه بـ"[Updated after Quality Review]".

---

## Step 1 — فحص التوثيق المتاح (مُعاد تأكيده)

تم إعادة فحص `/mnt/project/` بالكامل: **لا يوجد** أي ملف "Analysis Requirements"، "Business Brief"، أو أي وثيقة تحدد أسئلة تحليلية رسمية للمشروع. الملفات المتاحة فعليًا هي فقط: `README_data_dictionary-1.md` والبيانات نفسها.

**لذلك، الأسئلة التحليلية أدناه ليست "مخترَعة" — بل مُشتقَّة مباشرة من:**
1. الأقسام الستة الموثقة رسميًا في `README_data_dictionary-1.md` (Population, Roads, Traffic, Transit, Air Quality, Green Space).
2. قسم "SQL Analysis Readiness" (Step 10) من `UrbanMind_AI_Schema_Design.md` المعتمد سابقًا، والذي حدد مسبقًا الأسئلة التحليلية الطبيعية التي يدعمها الـSchema.
3. القيود والتحذيرات الموثقة فعليًا في `UrbanMind_AI_Data_Quality_Audit.md` و`UrbanMind_AI_Investigation_Report.md` (خصوصًا تغطية `traffic_demand_capacity_pressure_index` وطبيعة `assignment_method`).

**لم يتم اختراع أي سؤال عمل (business question) غير مدعوم بالتوثيق أو بالمخطط الفعلي.**

---

## Step 2 — Analysis Plan

| ID | السؤال | لماذا يهم | الجدول/الأعمدة المطلوبة | الحساب المطلوب | نوع المخرج |
|---|---|---|---|---|---|
| Q1 | ما توزيع السكان عبر خلايا H3؟ وما مدى تغطية البيانات؟ | أساس لأي تحليل حضري | `H3_Features.population_population_worldpop_2026` | COUNT, MIN, MAX, AVG + تغطية | Distribution + Coverage |
| Q2 | ما خصائص كثافة شبكة الطرق؟ | تقييم البنية التحتية | `roads_road_length_km`, `roads_road_density_km_per_km2`, `roads_intersection_density` | AVG, MAX + تغطية | Descriptive |
| Q3 | ما توزيع مؤشر احتكاك الشبكة المروري البنيوي؟ | مؤشر جاهز وموثوق التغطية | `traffic_structural_network_friction_index` | AVG, MAX + تغطية | Distribution |
| Q4 | ما مدى إمكانية استخدام مؤشر ضغط الطلب/القدرة؟ | يجب فحص التغطية أولًا — معروف أنه شحيح | `traffic_demand_capacity_pressure_index` | COUNT تغطية أولاً، ثم إحصاءات على المتاح فقط | Coverage-gated descriptive |
| Q5 | ما نسبة تغطية النقل العام؟ | فهم الفجوة المكانية | `transit_has_transit`, `transit_transit_accessibility_score` | COUNT, نسبة، AVG | Coverage + Distribution |
| Q6 | ما توزيع جودة الهواء (NO2)؟ | مؤشر بيئي صحي مباشر | `air_quality_s5p_no2_tropospheric_column_mean_umol_m2` | MIN, MAX, AVG + تغطية | Distribution |
| Q7 | ما نسبة تغطية المساحات الخضراء؟ | مؤشر جودة الحياة الحضرية | `green_space_total_green_space_fraction`, `green_space_has_public_green_space` | COUNT, AVG + تنبيه التناقض الموثق | Coverage + Distribution |
| Q8 | ما هي الخلايا الأعلى كثافة سكانية، وما وضعها عبر الدومينات الأخرى؟ | قدرة الجدول الواحد على الإجابة بدون JOIN | كل أعمدة `H3_Features` | ORDER BY + LIMIT | Cross-domain snapshot |
| Q9 | إجمالي السكان ومتوسط كثافة الطرق والنقل لكل حي | تحليل على مستوى الحي | `H3_Features` JOIN `Dim_District` عبر `district_id` | SUM, AVG, GROUP BY | District-level aggregation |
| Q9b | ما نسبة تغطية بيانات السكان داخل كل حي؟ | إلزامي قبل تفسير Q9 | نفس الجدولين | نسبة تغطية لكل حي | Coverage per group |
| Q10 | كيف تتوزع طرق إسناد خلايا H3 (`assignment_method`)؟ | التأكد من معاملتها H3-level وليس district-level | `H3_Features.assignment_method` فقط | COUNT, GROUP BY | Distribution (H3-level) |
| Q11 | هل هناك علاقة وصفية بين الكثافة السكانية وإتاحة النقل؟ | فهم توزيع الخدمة مقابل الطلب | `population_population_density_worldpop_2026`, `transit_transit_accessibility_score` | تصنيف لفئات + AVG لكل فئة | Correlation-like descriptive |
| Q12 | أعلى 10 خلايا H3 من حيث كثافة الطرق | Ranking آمن (تغطية 99.97%) | `roads_road_density_km_per_km2` | ORDER BY DESC LIMIT 10 | Ranking |
| Q13 | ملخص التغطية الكامل عبر كل الدومينات | شرط إلزامي: "report coverage before interpreting" | كل أعمدة التغطية الرئيسية | COUNT/COUNT | Coverage summary |

---

## Step 3 — Explicit Schema Mapping

| ID | الجدول (الجداول) | ملاحظة ربط |
|---|---|---|
| Q1-Q8, Q10-Q13 | `H3_Features` فقط | لا حاجة لأي JOIN |
| Q9, Q9b | `H3_Features` JOIN `Dim_District` عبر `district_id` (وليس اسم الحي) | كما طُلب صراحة |

---

## Step 4 — Executed SQL & Results

### Q1 — Population Distribution & Coverage
```sql
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN population_population_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_population,
       MIN(population_population_worldpop_2026) AS min_pop,
       MAX(population_population_worldpop_2026) AS max_pop,
       AVG(population_population_worldpop_2026) AS avg_pop
FROM H3_Features;
```
**Result:** total_cells=3,489 | cells_with_population=**2,693** | min=0.0 | max=108,627.86 | avg=4,313.68

**Coverage:** 77.19%. الـ796 خلية المتبقية NULL (ليست صفرًا) — لم تُحسب ضمن AVG/MIN/MAX.

**Insight:** According to the available data, population figures are available for 77.19% of H3 cells; the remaining 22.81% have no observed value and were excluded, not treated as zero. Among cells with data, population ranges from 0 to 108,627.86 (mean 4,313.68).

---

### Q2 — Road Network Density
```sql
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN roads_road_length_km IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_roads,
       ROUND(AVG(roads_road_density_km_per_km2),3) AS avg_road_density,
       ROUND(MAX(roads_road_density_km_per_km2),3) AS max_road_density,
       ROUND(AVG(roads_intersection_density),3) AS avg_intersection_density
FROM H3_Features;
```
**Result:** cells_with_roads=3,488/3,489 (99.97%) | avg_density=8.423 km/km² | max=69.77 | avg_intersection_density=69.025

**Insight:** Near-complete coverage (99.97%). Average road density 8.42 km/km², maximum observed 69.77 km/km².

---

### Q3 — Traffic Structural Friction Index
```sql
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN traffic_structural_network_friction_index IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_index,
       ROUND(AVG(traffic_structural_network_friction_index),4) AS avg_index,
       ROUND(MAX(traffic_structural_network_friction_index),4) AS max_index
FROM H3_Features;
```
**Result:** cells_with_index=3,488/3,489 (99.97%) | avg=0.1597 | max=0.7299

**Insight:** 99.97% coverage; average value 0.16 on an apparently 0-1 normalized scale.

---

### Q4 — ⚠️ Traffic Demand/Capacity Pressure Index (Coverage-Gated)
```sql
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN traffic_demand_capacity_pressure_index IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_index,
       ROUND(100.0*SUM(CASE WHEN traffic_demand_capacity_pressure_index IS NOT NULL THEN 1 ELSE 0 END)/COUNT(*),2) AS coverage_pct
FROM H3_Features;

SELECT ROUND(MIN(traffic_demand_capacity_pressure_index),4) AS min_val,
       ROUND(MAX(traffic_demand_capacity_pressure_index),4) AS max_val,
       ROUND(AVG(traffic_demand_capacity_pressure_index),4) AS avg_val
FROM H3_Features WHERE traffic_demand_capacity_pressure_index IS NOT NULL;
```
**Result:** cells_with_index=26/3,489 → **coverage = 0.75%**. Among these 26 cells: min=0.0, max=1.0, avg=0.2131.

**Coverage/NULL check:** Available for only 26 cells (0.75%).

**Insight:** No city-wide ranking or distribution claim can be responsibly made from this feature — it would misrepresent 99.25% of the city as having no signal when the index was simply never computed there. Among the 26 available cells only, observed average is 0.21 (range 0.0-1.0). **Classified as "Blocked by data limitation" for any city-wide interpretation.**

---

### Q5 — Transit Availability
```sql
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN transit_has_transit=1 THEN 1 ELSE 0 END) AS cells_with_transit,
       ROUND(100.0*SUM(CASE WHEN transit_has_transit=1 THEN 1 ELSE 0 END)/COUNT(*),2) AS pct_with_transit,
       ROUND(AVG(transit_transit_accessibility_score),3) AS avg_accessibility_score
FROM H3_Features;
```
**Result:** cells_with_transit=438/3,489 (**12.55%**) | avg_accessibility_score=4.704

**Insight:** Only 12.55% of H3 cells have any transit presence. The average accessibility score (4.70) reflects a distribution dominated by zero-transit cells.

**[Updated after Quality Review]** The accessibility score column has only 1 NULL in the entire dataset (the known edge cell) — 99.97% coverage, verified separately from zero counts. Among the 3,050 cells with `transit_has_transit=0`, 2,797 (91.7%) have a measured zero score, but 253 cells (8.3%) have a positive score despite no transit stop located inside the cell itself — the score evidently accounts for nearby stops within walking distance, not only in-cell stops. Zero is a genuine computed value in the large majority of cases, not a missing-data placeholder; 0 cells with `transit_has_transit=1` have a zero or NULL score, confirming full internal consistency.

---

### Q6 — Air Quality (NO2)
```sql
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN air_quality_s5p_no2_tropospheric_column_mean_umol_m2 IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_aq,
       ROUND(MIN(air_quality_s5p_no2_tropospheric_column_mean_umol_m2),2) AS min_no2,
       ROUND(MAX(air_quality_s5p_no2_tropospheric_column_mean_umol_m2),2) AS max_no2,
       ROUND(AVG(air_quality_s5p_no2_tropospheric_column_mean_umol_m2),2) AS avg_no2
FROM H3_Features;
```
**Result:** cells_with_aq=3,488/3,489 (99.97%) | min=36.47 | max=310.81 | avg=135.97 µmol/m²

**Insight:** Near-complete coverage. NO2 values range 36.47-310.81 µmol/m², citywide average 135.97.

---

### Q7 — Green Space Coverage
```sql
SELECT COUNT(*) AS total_cells,
       SUM(CASE WHEN green_space_total_green_space_fraction IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_fraction,
       SUM(CASE WHEN green_space_has_public_green_space=1 THEN 1 ELSE 0 END) AS cells_with_public_green_space,
       ROUND(AVG(green_space_total_green_space_fraction),4) AS avg_fraction
FROM H3_Features;
```
**Result:** cells_with_fraction=3,488/3,489 (99.97%) | cells_with_public_green_space=388 (11.12%) | avg_fraction=0.0201

**⚠️ Known caveat (unchanged after Quality Review):** `green_space_total_green_space_fraction` does not reconcile numerically with `green_space_total_green_space_area_m2` in 26 cells (fully agricultural/natural-reserve land), as documented in `UrbanMind_AI_Data_Quality_Audit.md` (Issue H-5). Used here only as a general descriptive indicator, not for precise per-cell calculations.

**Insight:** Only 11.12% of cells have public green space; average green-space fraction citywide is very low (2.01%), consistent with a dense, largely built-up area.

---

### Q8 — Cross-Domain Snapshot (No JOIN)
```sql
SELECT h3_index, population_population_worldpop_2026 AS population,
       roads_road_density_km_per_km2 AS road_density,
       transit_transit_accessibility_score AS transit_score,
       air_quality_s5p_no2_tropospheric_column_mean_umol_m2 AS no2,
       green_space_total_green_space_fraction AS green_fraction
FROM H3_Features
ORDER BY population_population_worldpop_2026 DESC LIMIT 5;
```
**Result (top 5 most populated cells):**
| h3_index | population | road_density | transit_score | no2 | green_fraction |
|---|---|---|---|---|---|
| 883e628c29fffff | 108,627.86 | 46.41 | 33.4 | 240.35 | 0.000 |
| 883e628c61fffff | 104,511.36 | 43.69 | 39.5 | 237.67 | 0.000 |
| 883e628c67fffff | 102,288.22 | 34.47 | 27.5 | 228.60 | 0.000 |
| 883e628723fffff | 101,313.67 | 39.30 | 55.5 | 191.36 | 0.000 |
| 883e628727fffff | 98,446.53 | 47.49 | 45.7 | 198.43 | 0.001 |

**Insight:** The five most populated cells show near-zero green-space fraction and elevated NO2 (191-240 vs. citywide average 135.97). This is a descriptive co-occurrence in this specific slice, not a statistically established relationship — no causal claim is made.

---

### Q9 — District-Level Rollup (joined via `district_id`)
```sql
SELECT d.district_name, COUNT(f.h3_index) AS n_cells,
       SUM(CASE WHEN f.population_population_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END) AS cells_with_population,
       ROUND(100.0*SUM(CASE WHEN f.population_population_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END)/COUNT(f.h3_index),1) AS pop_coverage_pct,
       ROUND(SUM(f.population_population_worldpop_2026),0) AS total_population_OBSERVED_CELLS_ONLY,
       ROUND(AVG(f.roads_road_density_km_per_km2),2) AS avg_road_density,
       ROUND(AVG(f.transit_transit_accessibility_score),2) AS avg_transit_score
FROM H3_Features f JOIN Dim_District d ON f.district_id = d.district_id
GROUP BY d.district_name ORDER BY total_population_OBSERVED_CELLS_ONLY DESC LIMIT 10;
```
**[Updated after Quality Review — coverage now included in the same result set, not a separate check]**

**Result (top 10 districts by observed population, WITH coverage):**
| district_name | n_cells | cells_with_population | pop_coverage_pct | total_population (observed) |
|---|---|---|---|---|
| El Marg | 30 | 29 | 96.7% | 945,603 |
| El Basatin | 28 | 27 | 96.4% | 849,361 |
| Helwan | 80 | 78 | 97.5% | 838,034 |
| East Nasr City | 83 | 83 | 100.0% | 744,116 |
| El Salam 1 | 42 | 41 | 97.6% | 657,821 |
| El Matareya | 12 | 11 | 91.7% | 656,151 |
| Ain Shams | 9 | 9 | 100.0% | 645,487 |
| El Zeitoun | 10 | 10 | 100.0% | 414,745 |
| Old Cairo (Misr El Qadima) | 15 | 15 | 100.0% | 402,106 |
| El Sahel | 8 | 8 | 100.0% | 386,740 |

**Rows used:** 3,488 H3 cells joined (1 excluded — `district_id IS NULL`, documented edge case).

### Q9b — Per-District Population Coverage (lowest 10)
| district_name | n_cells | cells_with_population | pop_coverage_pct |
|---|---|---|---|
| El Tebbin | 63 | 40 | 63.5% |
| 15 May | 302 | 194 | 64.2% |
| New Cairo City | 1,638 | 1,107 | 67.6% |
| El Maasara | 7 | 5 | 71.4% |
| Tora | 212 | 159 | 75.0% |
| El Zawya El Hamra | 5 | 4 | 80.0% |
| Badr City | 461 | 390 | 84.6% |
| El Matareya | 12 | 11 | 91.7% |
| El Basatin | 28 | 27 | 96.4% |
| El Marg | 30 | 29 | 96.7% |

**Insight:** The displayed top-10 districts (Q9) all have 91.7%-100% coverage, so that specific ranking is reasonably reliable as shown.

**[Updated after Quality Review]** However, New Cairo City ranks **#11** citywide with an observed total of 356,823 at only **67.6% coverage** — within range of displacing the current #10 (El Sahel, 386,740) if its coverage were complete. This is a plausible boundary case, not a confirmed result, and must be stated whenever a "top 10 districts by population" list is presented. District population totals should always be reported together with coverage in the same result set going forward (see `UrbanMind_AI_SQL_Queries.sql`), rather than checked separately.

---

### Q10 — Assignment Method Distribution (H3-level)
```sql
SELECT assignment_method, COUNT(*) AS n_cells,
       ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM H3_Features),2) AS pct_of_all_cells
FROM H3_Features GROUP BY assignment_method ORDER BY n_cells DESC;
```
**Result:**
| assignment_method | n_cells | pct_of_all_cells |
|---|---|---|
| `FLAGGED_nearest_district_fallback_in_cairo_boundary_artifact` | 1,772 | 50.79% |
| `centroid_sjoin` | 1,577 | 45.20% |
| `polygon_intersection_single` | 124 | 3.55% |
| `polygon_intersection_dominant_overlap` | 15 | 0.43% |
| NULL | 1 | 0.03% (known edge cell) |

**[Updated after Quality Review] Validation query added:**
```sql
SELECT assignment_method, COUNT(*) AS n_cells,
       ROUND(AVG(transit_district_overlap_ratio),4) AS avg_overlap_ratio,
       ROUND(MIN(transit_district_overlap_ratio),4) AS min_overlap_ratio,
       ROUND(MAX(transit_district_overlap_ratio),4) AS max_overlap_ratio
FROM H3_Features GROUP BY assignment_method ORDER BY n_cells DESC;
```
**Result:** `FLAGGED_...` → overlap_ratio min=max=avg=**0.0000** (all 1,772 cells); `centroid_sjoin` → **1.0000** exactly (all 1,577 cells); `polygon_intersection_single` → avg 0.1905 (range 0.00-0.70); `polygon_intersection_dominant_overlap` → avg 0.2936 (range 0.05-0.52).

**Insight (revised after Quality Review):** The project's data dictionary does **not** document what `FLAGGED_nearest_district_fallback_in_cairo_boundary_artifact` implies about assignment reliability — describing it as "low-confidence" based on its name alone would be an unverified inference. Instead, a direct data check shows `transit_district_overlap_ratio = 0.0000` for **100% of these 1,772 cells**, versus `1.0000` for all `centroid_sjoin` cells and partial ratios (0.05-0.70) for the polygon-intersection methods. This is verified data evidence — not a naming inference — that these cells have no direct geometric overlap with any district polygon, which is why a fallback method was needed. This remains a material caveat for any district-level aggregation (Q9/Q9b), now grounded in `overlap_ratio` rather than in the method's name.

---

### Q11 — Density vs. Transit Accessibility (descriptive, not causal)
```sql
SELECT CASE WHEN population_population_density_worldpop_2026 IS NULL THEN 'no_data'
            WHEN population_population_density_worldpop_2026 = 0 THEN 'zero_density'
            WHEN population_population_density_worldpop_2026 < 5000 THEN 'low (<5000/km2)'
            WHEN population_population_density_worldpop_2026 < 20000 THEN 'medium (5000-20000/km2)'
            ELSE 'high (>=20000/km2)' END AS density_band,
       COUNT(*) AS n_cells,
       SUM(CASE WHEN population_population_density_worldpop_2026 IS NOT NULL THEN 1 ELSE 0 END) AS n_valid_density,
       SUM(CASE WHEN transit_transit_accessibility_score IS NOT NULL THEN 1 ELSE 0 END) AS n_valid_transit_score,
       SUM(CASE WHEN population_population_density_worldpop_2026 IS NOT NULL AND transit_transit_accessibility_score IS NOT NULL THEN 1 ELSE 0 END) AS n_valid_both,
       ROUND(AVG(transit_transit_accessibility_score),2) AS avg_transit_score,
       SUM(CASE WHEN transit_transit_accessibility_score = 0 THEN 1 ELSE 0 END) AS n_transit_score_zero
FROM H3_Features GROUP BY density_band ORDER BY n_cells DESC;
```
**[Updated after Quality Review — now includes per-band valid-value counts, as requested]**

**Result:**
| density_band | n_cells | n_valid_density | n_valid_transit_score | n_valid_both | avg_transit_score | n_score_zero |
|---|---|---|---|---|---|---|
| low (<5,000/km²) | 1,707 | 1,707 | 1,706 | 1,706 | 2.58 | 1,403 |
| no_data | 796 | 0 | 796 | 0 | 0.08 | 790 |
| zero_density | 553 | 553 | 553 | 553 | 0.02 | 551 |
| high (≥20,000/km²) | 238 | 238 | 238 | 238 | 33.57 | 18 |
| medium (5,000-20,000/km²) | 195 | 195 | 195 | 195 | 20.21 | 35 |

**Coverage/NULL check:** `no_data` (796 cells, density itself NULL) is kept as a fully separate category from `zero_density` (553 cells, a genuine measured zero), never merged. Within every band, valid-transit-score counts are at or near 100% of `n_cells` (the single NULL across the whole dataset falls in the "low" band) — averages are not diluted by missing values in any band.

**Insight (retained and strengthened after Quality Review):** The data shows a clear monotonic pattern: transit accessibility rises from near-zero in the lowest density band (0.02-2.58) up to 33.57 in the highest. This is now confirmed to rest on near-complete valid-value coverage within every band, not on an artifact of missing data. This is a descriptive association, not a causal claim.

---

### Q12 — Ranking: Top 10 H3 Cells by Road Density
```sql
SELECT h3_index, roads_road_density_km_per_km2, roads_intersection_density
FROM H3_Features WHERE roads_road_density_km_per_km2 IS NOT NULL
ORDER BY roads_road_density_km_per_km2 DESC LIMIT 10;
```
**Result (top 3 of 10):** `883e628729fffff` (69.77 km/km², 703.06 intersections/km²), `883e62872dfffff` (54.65, 521.40), `883e6280d3fffff` (53.95, 430.52).

**Coverage check:** 99.97% confirmed before ranking.

**Insight:** Highest observed road density was 69.77 km/km², roughly 8x the citywide average (8.42).

---

### Q13 — Full Coverage Summary (Meta-Check)
| domain | available | total | coverage |
|---|---|---|---|
| population | 2,693 | 3,489 | 77.19% |
| roads | 3,488 | 3,489 | 99.97% |
| traffic_structural_index | 3,488 | 3,489 | 99.97% |
| **traffic_demand_capacity_index** | **26** | 3,489 | **0.75%** ⚠️ |
| transit | 3,488 | 3,489 | 99.97% |
| air_quality | 3,488 | 3,489 | 99.97% |
| green_space | 3,488 | 3,489 | 99.97% |
| district_assignment | 3,488 | 3,489 | 99.97% |

---

## Step 5 — Summary

| المقياس | العدد |
|---|---|
| Total number of required questions | 13 (Q1-Q13، شاملة Q9b) |
| Number successfully analyzed | 12 |
| Number blocked by data limitations | 1 (Q4 — `traffic_demand_capacity_pressure_index`) |
| Number requiring clarification | 0 |

### أقوى الرؤى المبنية على أدلة (بعد المراجعة)
1. **تغطية السكان 77.19% فقط**، وتتفاوت بشدة بين الأحياء (63.5%-96.7%) — يجب ذكر هذا صراحة في أي تحليل سكاني على مستوى الحي (Q9b).
2. **(مُعزَّز بدليل overlap_ratio بعد المراجعة):** 50.79% من خلايا H3 أُسندت عبر طريقة fallback، ومؤشر `overlap_ratio = 0.0` بالضبط لكل هذه الخلايا (مقابل 1.0 لـ`centroid_sjoin`) — دليل بيانات مباشر وليس استنتاجًا من الاسم. أي تحليل على مستوى الحي يحمل هامش عدم يقين حقيقي لنصف المدينة تقريبًا (Q10).
3. `traffic_demand_capacity_pressure_index` غير صالح لأي استنتاج على مستوى المدينة (تغطية 0.75% فقط) — يُستبعَد من أي KPI عام (Q4).
4. **(مُؤكَّد على مستوى التغطية لكل فئة بعد المراجعة):** علاقة وصفية واضحة وغير سببية بين الكثافة السكانية وإتاحة النقل: من 0.02-2.58 في الكثافة المنخفضة إلى 33.57 في العالية (Q11).
5. النقل العام يغطي 12.55% فقط من خلايا المدينة — فجوة مكانية واسعة (Q5).
6. **(جديد بعد المراجعة):** New Cairo City (المركز #11 بالسكان، تغطية 67.6% فقط) قد تنتمي فعليًا لأول 10 أحياء سكانًا لو اكتملت بياناتها — حالة حدّية يجب ذكرها عند عرض أي ranking سكاني (Q9b).

### قيود يجب ذكرها في README/التقرير النهائي
1. `traffic_demand_capacity_pressure_index` — تغطية 0.75%، غير قابل للاستخدام كمؤشر عام.
2. `population_*` — تغطية 77.19%، متفاوتة جغرافيًا (أسوأ في El Tebbin 63.5%، 15 May 64.2%، New Cairo City 67.6%).
3. 50.79% من إسناد الأحياء يعتمد على طريقة fallback بلا تداخل هندسي فعلي (`overlap_ratio=0.0`، مؤكَّد بالبيانات) — حد لأي تحليل district-level.
4. `green_space_total_green_space_fraction` — تناقض حسابي موثق في 26 خلية.
5. الخلية `883e604d65fffff` تبقى بدون حي في كل تحليل district-level — تُستبعَد صراحة، وليس بشكل صامت.
6. `transit_transit_accessibility_score` — صفر غالبًا قيمة محسوبة حقيقية، لكن 8.3% من خلايا "بلا محطة محلية" لها إتاحة جزئية من الجوار؛ يجب عدم افتراض تطابق تام بين "لا محطة" و"صفر إتاحة".
7. أي "top N districts by population" يجب أن يُرفَق دائمًا بعمود التغطية، وأن يُذكَر أي حي قريب من حد القائمة بتغطية منخفضة (مثل New Cairo City).

**لم يتم تعديل أي ملف مشروع في هذه المرحلة — هذا تحليل SQL للقراءة فقط.**
