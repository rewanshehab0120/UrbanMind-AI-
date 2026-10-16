# UrbanMind — Technical Work Log & Documentation

> **Project:** UrbanMind — Urban Intelligence for Cairo
> **Dataset:** `urbanmind_features_h3.csv`
> **Notebook:** `urbanmind_eda_preprocessing.ipynb`
> **Documented:** October 2026
> 
> 📖 **للاطلاع على الشرح المتسلسل لجميع خلايا النوت بوك بالتفصيل (125 خلية):** راجع ملف [cells_walkthrough.md](./cells_walkthrough.md)

---

## Table of Contents

1. [ما كان موجود في البداية — الداتا الخام](#1-ما-كان-موجود-في-البداية--الداتا-الخام)
2. [خطوة 1 — تحميل الداتا](#2-خطوة-1--تحميل-الداتا)
3. [خطوة 2 — فحص جودة الداتا](#3-خطوة-2--فحص-جودة-الداتا)
4. [خطوة 3 — تنظيف الداتا وحل القيم الناقصة](#4-خطوة-3--تنظيف-الداتا-وحل-القيم-الناقصة)
5. [خطوة 4 — الاستكشاف والتحليل EDA](#5-خطوة-4--الاستكشاف-والتحليل-eda)
6. [خطوة 5 — المعالجة وهندسة الفيتشرز](#6-خطوة-5--المعالجة-وهندسة-الفيتشرز)
7. [خطوة 6 — البيانات الجاهزة للموديل](#7-خطوة-6--البيانات-الجاهزة-للموديل)
8. [ملخص كل القرارات المتخذة](#8-ملخص-كل-القرارات-المتخذة)
9. [الأوبجكتس الجاهزة بعد تشغيل النوتبوك](#9-الأوبجكتس-الجاهزة-بعد-تشغيل-النوتبوك)
10. [اختيار التارجت](#10-اختيار-التارجت)

---

## 1. ما كان موجود في البداية — الداتا الخام

### الملف الأصلي

الملف `urbanmind_features_h3.csv` كان موجوداً بالحالة دي:

| الخاصية | القيمة |
|---------|--------|
| **الصفوف** | 3,489 خلية H3 سداسية |
| **الأعمدة** | 175 فيتشر موزعة على 6 domains |
| **الوحدة المكانية** | خلية H3 بدقة Resolution-8 (~0.74 كم² لكل خلية) |
| **المدينة** | القاهرة، مصر |
| **سنة المرجع** | 2026 |
| **نظام الإحداثيات** | WGS-84 / EPSG:4326 |

### الـ Domains الموجودة في الداتا

الداتا كانت مقسمة في 6 domains، كل domain ليه prefix مختلف في أسماء الأعمدة:

| Domain | الـ Prefix | عدد الأعمدة | مصدر البيانات |
|--------|-----------|------------|--------------|
| **Population** | `population_*` | ~20 عمود | WorldPop model 2026 |
| **Roads** | `roads_*` | ~25 عمود | OpenStreetMap (OSM) |
| **Traffic** | `traffic_*` | ~25 عمود | مشتق من OSM + population |
| **Transit** | `transit_*` | ~40 عمود | بيانات GTFS + OSM |
| **Air Quality** | `air_quality_*` | ~20 عمود | Sentinel-5P satellite |
| **Green Space** | `green_space_*` | ~25 عمود | Satellite NDVI + OSM parks |

### أهم الفيتشرز في كل Domain

**Population:**
- `population_population_worldpop_2026` — عدد السكان الكلي في الخلية
- `population_population_density_worldpop_2026` — الكثافة السكانية (ساكن/كم²)
- `population_cairo_intersection_ratio` — نسبة تقاطع الخلية مع حدود القاهرة

**Roads:**
- `roads_road_length_km` — إجمالي طول الطرق داخل الخلية
- `roads_road_density_km_per_km2` — كثافة الطرق
- `roads_intersection_count` / `roads_dead_end_ratio` — خصائص شبكة الطرق
- `roads_avg_lanes` / `roads_avg_maxspeed` — بيانات مفصلة عن الحارات والسرعة

**Traffic:**
- `traffic_structural_network_friction_index` — مؤشر مركب للاحتكاك الهيكلي في الشبكة (0–1)
- `traffic_population_per_road_km` — الضغط السكاني على الطرق
- `traffic_demand_capacity_pressure_index` — نسبة الطلب للطاقة الاستيعابية

**Transit:**
- `transit_has_transit` — Boolean: هل في وسيلة نقل جماعي في الخلية؟
- `transit_transit_accessibility_score` — درجة إمكانية الوصول للمواصلات (0–100)
- `transit_nearest_transit_stop_network_distance_m` — أقرب محطة مواصلات (متر شبكة)
- `transit_metro_station_count` / `transit_bus_stop_count` / `transit_brt_station_count`

**Air Quality:**
- `air_quality_s5p_no2_tropospheric_column_mean_umol_m2` — متوسط تركيز NO2 (Sentinel-5P)
- `air_quality_nearest_pm25_station_distance_km` — المسافة لأقرب محطة رصد PM2.5

**Green Space:**
- `green_space_ndvi_mean_annual_2026` — متوسط مؤشر النباتات NDVI سنوياً
- `green_space_public_green_space_area_m2` — مساحة المساحات الخضراء العامة
- `green_space_vegetation_persistence_ratio` — نسبة استمرارية الغطاء النباتي

---

## 2. خطوة 1 — تحميل الداتا

### اللي اتعمل

فتحنا الملف بـ pandas وعملنا نسخة working copy اسمها `df` عشان الـ raw data تفضل محفوظة مش بنعدل فيها مباشرة.

```python
df_raw = pd.read_csv('urbanmind_features_h3.csv')
df = df_raw.copy()
print(f'Shape: {df.shape}')   # (3489, 175)
display(df.head())
```

**النتيجة:** `df.shape = (3489, 175)` — الداتا اتحملت صح بـ 3,489 صف و 175 عمود.

---

## 3. خطوة 2 — فحص جودة الداتا

### ليه بدأنا بده؟

قبل ما نعمل أي حاجة، لازم نعرف **إيه المشاكل الموجودة فعلاً** في الداتا. من غير الخطوة دي هنبني على أساس غلط.

### 2.1 — أنواع الفيتشرز

**اللي لقيناه:**

| النوع | العدد |
|-------|-------|
| Numeric (float64 / int64) | ~130 عمود |
| Categorical (object) | ~35 عمود |
| Boolean (bool) | ~10 أعمدة |

الغالبية numeric — ده طبيعي لداتا جغرافية كمية.

### 2.2 — الصفوف المكررة

**اللي لقيناه:** صف واحد مكرر بالكامل.
**القرار:** هيتحذف في خطوة التنظيف.

### 2.3 — H3 IDs المكررة

**اللي لقيناه:** خلية H3 واحدة `883e604d65fffff` موجودة مرتين في الداتا.
**القرار:** نحتفظ بأول ظهور ونحذف الثاني.

### 2.4 — القيم الناقصة — العدد الكلي

**اللي لقيناه:** 161 عمود من أصل 175 فيه قيم ناقصة.

الأعمدة المتأثرة مقسمة على مجموعتين:
- **796 قيمة ناقصة** في كل أعمدة domain الـ Population — السبب: خلايا H3 على حافة القاهرة خارج الحدود الإدارية
- **قيمة واحدة ناقصة فقط** في معظم أعمدة الـ domains التانية — على الأرجح صف واحد غير مكتمل

### 2.5 — نسبة القيم الناقصة بالرسم البياني

**المشكلة التي وجدناها في الرسمة الأصلية:**
الرسمة كانت barh تعرض كل الـ 161 عمود فوق بعض، فأسماء الأعمدة اتداخلت وبقت غير مقروءة خالص.

**الحل اللي طبقناه:**
استبدلنا الرسمة بـ **رسمتين جنب بعض**:
- **يسار:** متوسط الـ missing % لكل domain — 6 بارات بس، مقروءة تماماً
- **يمين:** الأعمدة اللي فيها > 1% missing فقط (37 عمود مش 161)، بأسماء مختصرة وملونة بالـ domain

### 2.6 — المشاكل الخطيرة: أعمدة > 50% missing

**اللي لقيناه:** 11 عمود فيها أكتر من 50% من القيم ناقصة:

| العمود | نسبة النقص | السبب |
|--------|-----------|-------|
| `roads_avg_lanes` | 99% | Cairo OSM مش بيسجل عدد الحارات تقريباً |
| `roads_avg_maxspeed` | 99% | حدود السرعة نادراً متسجلة في OSM القاهرة |
| `roads_lane_km` | 65% | مشتق من avg_lanes — نفس المشكلة |
| `traffic_avg_lanes` | 99% | نسخة مكررة من roads domain |
| `traffic_avg_maxspeed` | 99% | نسخة مكررة من roads domain |
| `traffic_lane_km` | 65% | نفس roads_lane_km |
| `traffic_population_per_lane_km` | 99% | مستحيل يتحسب من غير lane_km |
| `traffic_population_per_lane_km_norm` | 99% | نفس العمود السابق، normalized |
| `traffic_demand_capacity_pressure_index` | 99% | يعتمد على بيانات الحارات الناقصة |
| `traffic_demand_capacity_pressure_class` | 99% | مشتق من الـ index السابق |
| `transit_transit_modes_available` | 87% | نص حر، sparse جداً |

**القرار:** هتتحذف كلها في خطوة التنظيف — تعبئة 99% من عمود بـ imputation ده bias مش بيانات.

---

## 4. خطوة 3 — تنظيف الداتا وحل القيم الناقصة

### ليه خطوة التنظيف جت قبل الـ EDA؟

الـ EDA المفروض يكون على داتا نظيفة. لو عملنا الرسومات على الداتا الخام:
- الـ histograms هتحتاج `dropna()` في كل plot
- الـ scatter plots هتتجاهل ربع الداتا تلقائياً
- نتائج الـ correlations هتبقى مشوهة

**القرار:** نكمّل التنظيف الأول، ثم نستكشف الداتا النظيفة.

---

### 3.1 — حذف الصف المكرر

**قبل:** 3,489 صف
**بعد:** 3,488 صف

```python
clean = df.drop_duplicates('h3_index').copy()
```

الـ frame الجديد اسمه `clean` وده اللي هنشتغل عليه من هنا لآخر النوتبوك.

---

### 3.2 — حذف الأعمدة > 50% missing

**قبل:** 175 عمود
**بعد:** 164 عمود (حذف 11 عمود)

```python
high_miss_cols = null_pct[null_pct > 50].index.tolist()
clean = clean.drop(columns=high_miss_cols)
```

**الأعمدة المحذوفة بالتفصيل:** انظر الجدول في القسم 2.6 أعلاه.

---

### 3.3 — تعبئة القيم الناقصة — استراتيجية الـ Imputation

**استراتيجيتان فقط بدون تعقيد:**

| نوع العمود | طريقة التعبئة | السبب |
|-----------|--------------|-------|
| **Numeric** (float / int) | **Median** | توزيعات البيانات الحضرية غير متماثلة skewed — الـ Median أقل تأثراً بالـ outliers من الـ Mean |
| **Categorical / Boolean** (object / bool) | **Mode** (الأكثر تكراراً) | أفضل تخمين لقيمة مجهولة في عمود فئوي |

**ليه Median وليس Mean؟**
خد مثال: عمود `roads_road_length_km` — غالبية الخلايا فيها طرق قصيرة، لكن خلايا التقاطعات الكبيرة فيها طرق طويلة جداً. الـ Mean هيتأثر بالقيم الكبيرة دي ويدي تعبئة مشوهة. الـ Median بيدي القيمة الوسطية الفعلية.

---

### 3.4 — تعبئة كل Domain في خلية منفصلة

**ليه خلية لكل domain؟**
عشان لو في مشكلة في domain معين تعرف تصلح بالظبط من غير ما تأثر على حاجة تانية. كل خلية مستقلة وبتطبع confirmation إن المشكلة اتحلت.

**Domain بعد Domain:**

#### Population Domain (796 قيمة ناقصة)

اتعبت فيها أكتر لأن 796 صف = 23% من الداتا كلها ناقصين. السبب المؤكد: الخلايا دي على حافة القاهرة وبتقع جزئياً خارج الحدود الإدارية، ففيتشرات الـ population اتحسبت كـ null.

**القرار:** Median للـ numeric (population, density, area) و Mode للـ categorical (source names, flags).

#### Roads Domain (قيمة واحدة ناقصة في كل عمود تقريباً)

الصف `883e604d65fffff` كان الوحيد فيه null في أعمدة الـ roads. تعبئة بسيطة بالـ Median.

#### Traffic Domain (مشاكل متعددة)

بعد حذف الأعمدة > 50%، فضل كمان:
- `traffic_population_per_road_km`: 1,273 قيمة ناقصة (36%) ← Median
- `traffic_intersection_per_road_km`: 1,162 قيمة ناقصة (33%) ← Median
- باقي الأعمدة: قيمة واحدة ناقصة ← Median

#### Transit Domain (3,051 في transit_modes ← اتحذف)

بعد حذف `transit_transit_modes_available` (87% missing)، باقي أعمدة التransit كانت بس قيمة واحدة ناقصة في كل عمود.

#### Air Quality Domain

كل أعمدة الـ Air Quality كان فيها قيمة واحدة ناقصة بالظبط في نفس الصف. تعبئة مباشرة بـ Median/Mode.

#### Green Space Domain

- `green_space_vegetation_persistence_ratio`: 290 قيمة ناقصة (8.3%) ← Median
- باقي الأعمدة: 1–2 قيمة ناقصة ← Median

---

### 3.5 — التحقق النهائي

بعد تعبئة كل domain، عملنا verification:

```python
total_remaining = clean.isna().sum().sum()
# النتيجة: 0
```

**النتيجة: ✓ لا يوجد أي قيمة ناقصة في الداتا.**

**الـ clean frame بعد التنظيف:**

| | قبل | بعد |
|--|-----|-----|
| الصفوف | 3,489 | 3,488 |
| الأعمدة | 175 | 164 |
| القيم الناقصة | ~15,000+ | **0** |

---

## 5. خطوة 4 — الاستكشاف والتحليل EDA

### ليه الـ EDA جاء بعد التنظيف؟

عشان كل رسمة من هنا لآخر الـ EDA تكون على داتا حقيقية كاملة بدون `dropna()` — النتائج أدق وأصدق.

### اللي استكشفناه

#### 4.1 — التوزيع الجغرافي

رسمنا scatter plot لإحداثيات كل خلية H3 على محور longitude/latitude. النتيجة أكدت إن الـ coverage بتغطي القاهرة الكبرى كاملة.

#### 4.2 — Population

- التوزيع **highly skewed** يميناً: أغلبية الخلايا أقل من 2,000 ساكن، لكن في خلايا بتتجاوز 15,000
- الكثافة السكانية highest في مناطق القلب التاريخي (وسط البلد، بولاق، شبرا)

#### 4.3 — Roads

- كثير من الخلايا البيرفيرية (أطراف القاهرة) فيها road length ≈ 0
- الكثافة العالية في الشبكة الداخلية للمدينة

#### 4.4 — Transit

- فقط **~40% من الخلايا** فيها وسيلة مواصلات عامة واحدة على الأقل
- الفجوات الكبيرة في الشرق والجنوب
- المسافة لأقرب محطة بتتراوح من صفر لأكتر من 5 كم (شبكة، مش خط مستقيم)

#### 4.5 — Air Quality (NO2)

- التوزيع skewed: معظم الخلايا فيها NO2 منخفض، لكن محاور الطرق الرئيسية فيها قيم عالية جداً
- Correlation سلبية بين NDVI والـ NO2: الخلايا الأكتر خضراً فيها تلوث أقل

#### 4.6 — Green Space

- أقل من 1% من مساحة أغلبية الخلايا مساحات خضراء
- المساحات الخضراء العامة مركزة في: الزمالك، مصر الجديدة، التجمع الخامس

#### 4.7 — Traffic Friction

- الـ `traffic_structural_network_friction_index` highest في الخلايا اللي فيها كثافة عالية + سعة طريق ضعيفة (حارات قليلة)

#### 4.8 — Correlation Heatmap

رسمنا heatmap لأعلى 25 فيتشر بالـ variance. أهم patterns:
- Population ↔ transit stops: موجبة (مناطق كثافة أعلى فيها مواصلات أكتر)
- NDVI ↔ NO2: سالبة (أخضر أكتر = تلوث أقل)
- Road density ↔ NO2: موجبة متوسطة (طرق أكتر = انبعاثات أعلى)

---

## 6. خطوة 5 — المعالجة وهندسة الفيتشرز

### الهدف

تحويل الـ `clean` frame إلى matrix رقمية بالكامل يقدر أي موديل يشتغل عليها.

---

### 5.1 — حذف أعمدة الـ Metadata والـ IDs

**اللي كان موجود:**
في الداتا كميات كبيرة من الأعمدة اللي هي metadata فقط — مصدر البيانات، سنة المرجع، رابط الـ DOI، اسم الملف، إلخ. دي مش فيتشرز حقيقية وهتضر الموديل.

**الـ tokens اللي حددناها للحذف:**
```
'source', 'url', 'doi', 'date', 'version', 'crs', 'grid',
'analytical_grid', 'reference_year', 'observation_start/end',
'source_type/version', 'quality_flag', 'production_date',
'snapshot_date', 'source_dataset', 'spatial_resolution',
'native_spatial_resolution', 'source_url', 'population_type',
'is_observed', 'is_estimated', 'is_derived', 'data_status',
'index_available', 'coverage_flag'
```

بالإضافة لـ `h3_index` (ده ID مش فيتشر).

---

### 5.2 — حذف الأعمدة الثابتة (Constant)

**اللي لقيناه:** بعد حذف الـ metadata، فضل كمان أعمدة فيها قيمة واحدة بس (zero variance). دي مش بتضيف معلومة للموديل.

**القرار:** حذف أي عمود فيه `nunique() <= 1`.

---

### 5.3 — بناء الـ Feature Frame X

بعد حذف كل الأعمدة اللي مش محتاجينها، بنينا `X`:

```python
X = clean[[c for c in clean.columns if c not in all_drop]].copy()
```

---

### 5.4 — تحويل Boolean لـ 0/1

**المشكلة:** الأعمدة زي `transit_has_transit` كانت قيمها `True/False` — Python objects، مش أرقام. الموديلات بتحتاج أرقام.

**الحل:**
```python
bool_cols = X.select_dtypes(include='bool').columns.tolist()
X[bool_cols] = X[bool_cols].astype(int)
```

**النتيجة:** `True` → `1` و `False` → `0`

---

### 5.5 — One-Hot Encoding للـ Categoricals

**المشكلة:** في أعمدة نصية فئوية زي `traffic_structural_susceptibility_class` بقيم (LOW / MEDIUM / HIGH). الموديل مش بيفهم النص.

**القاعدة المتبعة:**
- أعمدة بـ **≤ 10 unique values**: One-Hot Encoding ← بنحولها لأعمدة binary
- أعمدة بـ **> 10 unique values**: حذف ← أسماء محطات، IDs، نصوص وصفية

**مثال:**
`traffic_structural_susceptibility_class` (LOW / MEDIUM / HIGH) →
`traffic_structural_susceptibility_class_MEDIUM` + `traffic_structural_susceptibility_class_HIGH` (بنحذف واحد لتجنب multicollinearity)

---

### 5.6 — Log-Transform للتوزيعات Skewed

**المشكلة:** فيتشرات زي `roads_road_length_km` و `population_population_worldpop_2026` و `green_space_public_green_space_area_m2` فيها توزيع heavily right-skewed — معظم القيم صغيرة، لكن في outliers كبيرة جداً.

**ليه ده مشكلة للموديل؟**
- موديلات زي Linear Regression و SVMs بتتأثر بالـ scale والتوزيع
- حتى Random Forest بتشتغل أحسن مع توزيع أقل skewness

**المعيار:** كل عمود فيه `|skewness| > 1` → نطبق `log1p()`

```python
# log1p آمن للأعمدة اللي فيها صفر
X[col] = np.log1p(X[col])
```

**لماذا `log1p` وليس `log`؟**
لأن `log(0) = -inf` — وفيه خلايا بيانات كتير قيمتها صفر (مثلاً، خلية بدون طرق أصلاً). `log1p(x) = log(x+1)` بيحل المشكلة دي.

---

### 5.7 — التحقق النهائي من الـ Feature Frame

```python
bad = X.replace([np.inf, -np.inf], np.nan).isna().sum()
# النتيجة: لا يوجد NaN ولا Inf
```

**✓ الـ feature frame نظيف وجاهز.**

---

## 7. خطوة 6 — البيانات الجاهزة للموديل

### 6.1 — تحديد الـ Target

المستخدم يحدد الـ TARGET قبل تشغيل الـ section ده:

```python
TARGET = 'transit_transit_accessibility_score'  # مثال
```

الـ default المضبوط هو `transit_transit_accessibility_score` — درجة إمكانية الوصول للمواصلات من 0 لـ 100.

---

### 6.2 — Spatial Train/Test Split (70/30)

**المشكلة مع الـ Random Split:**
الداتا الحضرية فيها **spatial autocorrelation** قوية — الخلايا المتجاورة متشابهة جداً لأنها في نفس الحي. لو عملنا random split، الموديل ممكن "يحفظ" الخلايا المجاورة للـ test set لأنها موجودة في الـ training set، وده بيعطي accuracy مبالغ فيها.

**الحل — Spatial Block Split:**
قسمنا الخلايا بناءً على موقعها الجغرافي — كل مجموعة خلايا في نفس "المنطقة" (rounded lat/lon) تروح كلها إما training أو test.

```python
blocks = clean.roads_latitude.round(2).astype(str) + '|' + clean.roads_longitude.round(2).astype(str)
# 70% من المناطق في training، 30% في test
```

**النتيجة:** الـ test set فيه مناطق جغرافية مختلفة خالص عن الـ training — اختبار حقيقي للموديل.

---

### 6.3 — StandardScaler

بعد الـ split، عملنا StandardScaler:
- `fit_transform` على الـ training data فقط
- `transform` على الـ test data (من غير re-fit عشان منسربش معلومات الـ test للـ training)

```python
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train_raw)
X_test  = scaler.transform(X_test_raw)
```

---

### 6.4 — Random Forest Baseline

بعد ما الداتا اتجهزت، شغّلنا Random Forest كـ baseline سريع:

```python
rf = RandomForestRegressor(n_estimators=200, random_state=42, n_jobs=-1)
rf.fit(X_train, y_train)
```

والنتائج بتظهر:
- **R²** — كمية التفسير في التباين
- **MAE** — متوسط الخطأ المطلق بوحدة الـ target

كمان بنرسم أهم 20 فيتشر (Feature Importance) عشان نعرف أي المتغيرات أكتر تأثيراً.

---

## 8. ملخص كل القرارات المتخذة

| القرار | السبب |
|--------|-------|
| `drop_duplicates('h3_index')` | 1 خلية H3 كانت مكررة في الداتا |
| Drop أعمدة > 50% missing | 11 عمود، بيانات OSM غير متاحة في القاهرة |
| Median للـ numeric | توزيعات skewed — الـ mean يتأثر بالـ outliers |
| Mode للـ categorical/boolean | أفضل تخمين بدون معلومة إضافية |
| خلية منفصلة لكل domain | سهولة الـ debugging والـ audit |
| EDA بعد التنظيف | عشان الرسومات تكون على داتا حقيقية كاملة |
| حذف metadata tokens | مش فيتشرز، بتضر الموديل |
| OHE للـ categoricals ≤ 10 | تحويل فئوي لرقمي |
| حذف high-cardinality text | أسماء وIDs ومش معلومة قابلة للتعميم |
| `log1p` للـ skewed features | تحسين التوزيع وتقليل تأثير الـ outliers |
| Spatial Split (70/30) | منع الـ spatial leakage في الاختبار |
| StandardScaler بعد الـ split | منع تسريب إحصائيات الـ test للـ training |

---

## 9. الأوبجكتس الجاهزة بعد تشغيل النوتبوك

بعد تشغيل كل الـ 6 sections، ده اللي بيكون جاهز في الـ kernel:

| الـ Object | النوع | الوصف |
|-----------|-------|-------|
| `df` | `DataFrame` | الداتا الخام الأصلية (3,489 × 175) — محدش بيعدل فيها |
| `clean` | `DataFrame` | الداتا بعد dedup + imputation (3,488 × 164) |
| `X` | `DataFrame` | الـ feature frame بعد log-transform (قبل scaling) |
| `X_feat` | `DataFrame` | Features بدون الـ target |
| `y` | `Series` | قيم الـ target column |
| `X_train` | `DataFrame` | Training features — scaled |
| `X_test` | `DataFrame` | Test features — scaled |
| `y_train` | `Series` | Training target values |
| `y_test` | `Series` | Test target values |
| `scaler` | `StandardScaler` | الـ scaler المعمول له fit — استخدمه لتحويل داتا جديدة |
| `split` | `Series` | 'train'/'test' label لكل H3 cell |
| `rf` | `RandomForestRegressor` | Baseline model — بيانات baseline |

---

## 10. اختيار الـ Target

الداتا بتدعم Regression وClassification.

### Regression

| الـ Target | الوصف | الصعوبة المتوقعة |
|-----------|-------|-----------------|
| `transit_transit_accessibility_score` | درجة إمكانية الوصول للمواصلات (0–100) | ⭐⭐ متوسط |
| `air_quality_s5p_no2_tropospheric_column_mean_umol_m2` | تركيز NO2 (µmol/m²) | ⭐⭐ متوسط |
| `traffic_structural_network_friction_index` | مؤشر الاحتكاك الهيكلي (0–1) | ⭐⭐⭐ صعب |
| `green_space_total_green_space_fraction` | نسبة المساحة الخضراء (0–1) | ⭐⭐ متوسط |
| `population_population_density_worldpop_2026` | الكثافة السكانية | ⭐ سهل |

### Classification

| الـ Target | الوصف |
|-----------|-------|
| `transit_has_transit` | هل في مواصلات عامة في الخلية؟ (True/False) |
| `transit_multimodal_hub_present` | هل في محطة تبادل multimodal؟ |
| `green_space_has_public_green_space` | هل في مساحات خضراء عامة؟ |

---

*توثيق تفصيلي لمشروع UrbanMind — Cairo Urban Intelligence — أكتوبر 2026*
