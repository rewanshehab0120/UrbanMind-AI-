# 🏙️ UrbanMind AI — Spatial Urban Intelligence, Multi-Model ML Benchmark & Policy Scenario Engine (Greater Cairo H3 Grid)

[Python 3.10+](https://www.google.com/search?q=https://www.python.org/)
[Spatial Grid](https://www.google.com/search?q=https://h3geo.org/)
[](#)
[](#)

> **الملخص بالعربية:**  
> مشروع **UrbanMind AI** هو إطار عمل متكامل لتحليل الذكاء الحضري المكاني لمدينة القاهرة الكبرى على شبكة **Uber H3** (بإجمالي **3,489 خلية مكانية** و**175 متغيراً** تشمل السكان، شبكة الطرق، النقل العام، المساحات الخضراء، وجودة الهواء). يجمع المستودع بين **تدقيق جودة البيانات وكشف التسريب (Data Leakage Audit)**، وهندسة المؤشرات المركبة، ومقارنة شاملة لـ **9 عائلات من نماذج التصنيف والانحدار** (بما فيها **CatBoost, XGBoost, LightGBM, Random Forest, Deep/Compact MLP, SVM, KNN, Logistic/Linear/Ridge/Lasso**)، بالإضافة إلى **محرك سيناريوهات سياسات التخطيط الحضري (What-If Policy Scenario Engine)** لتوجيه التدخلات المستهدفة في الأحياء الأكثر ضغطاً.

---

## 📌 جدول المحتويات (Table of Contents)

1. [نظرة عامة على المشروع وأهدافه (Project Overview)](#-1-نظرة-عامة-على-المشروع-وأهدافه-project-overview)
2. [بيانات المشروع ونطاقات المتغيرات (Dataset & Spatial Domains)](#-2-بيانات-المشروع-ونطاقات-المتغيرات-dataset--spatial-domains)
3. [الأهداف السبعة ومنهجية منع تسريب البيانات (Targets & Leakage-Free Governance)](#-3-الأهداف-السبعة-ومنهجية-منع-تسريب-البيانات-targets--leakage-free-governance)
4. [ترسانة النماذج وهيكلة الـ Pipelines (Model Suite & Architecture)](#-4-ترسانة-النماذج-وهيكلة-الـ-pipelines-model-suite--architecture)
5. [نتائج ومقارنات نماذج التصنيف (Classification Benchmark & F1-Score Matrix)](#-5-نتائج-ومقارنات-نماذج-التصنيف-classification-benchmark--f1-score-matrix)
6. [نتائج نماذج الانحدار وتحليل التبعية المكانية (Regression Benchmark & Spatial Field Analysis)](#-6-نتائج-نماذج-الانحدار-وتحليل-التبعية-المكانية-regression-benchmark--spatial-field-analysis)
7. [محرك السياسات والسيناريوهات الحضرية (What-If Scenario Engine & District Prioritization)](#-7-محرك-السياسات-والسيناريوهات-الحضرية-what-if-scenario-engine--district-prioritization)
8. [هيكلة ملفات المستودع (Repository Structure)](#-8-هيكلة-ملفات-المستودع-repository-structure)
9. [طريقة التشغيل السريع على Google Colab أو محلياً (Quick Start)](#-9-طريقة-التشغيل-السريع-على-google-colab-أو-محلياً-quick-start)

---

## 🎯 1. نظرة عامة على المشروع وأهدافه (Project Overview)

يهدف مشروع **UrbanMind AI** إلى بناء توأم تحليلي مكاني لمدينة القاهرة الكبرى يساعد مخططي المدن وصانعي القرار على الإجابة عن أربعة أسئلة جوهرية:
1. **تشخيص الهشاشة المرورية والضغط الحضري**: كيف يمكن التنبؤ بقابلية الشبكة المرورية للاختناق (`Traffic Structural Susceptibility`) وأولوية التدخل الحضري (`Urban Intervention Priority`) لكل خلية H3 دون الوقوع في فخ تسريب البيانات (`Indirect Target Leakage`)؟
2. **معالجة عدم توازن الفئات الحضرية (Imbalanced Urban Classes)**: كيف نستخدم `SMOTE` داخل `Pipeline` معزول مع الشبكات العصبية (`MLP`) والموديلات الشجرية لاكتشاف الفئات النادرة مثل توافر المساحات الخضراء العامة (11.1%) وتوافر محطات النقل العام (12.6%)؟
3. **الفصل بين التدرج الجغرافي والعوامل الحضرية في تلوث الهواء ($NO_2$)**: إلى أي مدى يُعزى تركيز ثاني أكسيد النيتروجين ($NO_2$) إلى الموقع الجغرافي البحت مقارنةً بالروافع الحضرية المحلية (الكثافة السكانية، الطرق، النقل، الغطاء النباتي)؟
4. **محاكاة السياسات المستهدفة (Targeted What-If Interventions)**: ما هو الأثر الكمي لإضافة محطات نقل عام ومساحات خضراء عامة في أعلى **10%–20%** من الخلايا الأكثر ضغطاً عند زيادة السكان بنسبة **+20%**، وما هي الأحياء ذات الأولوية القصوى للتدخل؟

---

## 🗺️ 2. بيانات المشروع ونطاقات المتغيرات (Dataset & Spatial Domains)

تتكون قاعدة البيانات الأساسية (`urbanmind_features_h3_clean.csv`) من **3,489 خلية سداسية (Uber H3)** تغطي نطاق القاهرة الكبرى، وتشمل **175 عموداً** موزعة على 5 نطاقات حضرية رئيسية:

| النطاق الحضري (Domain) | البادئة (Prefix) | أبرز المؤشرات والمتغيرات المضمنة | ملاحظات الجودة والتغطية |
| :--- | :---: | :--- | :--- |
| **السكان والديموغرافيا (Population)** | `population_` | إجمالي السكان (`WorldPop 2026`)، الكثافة السكانية، مساحة الخلية، نسبة التقاطع مع القاهرة | تغطية ~77.2% لخلايا الكتلة السكنية المأهولة (~99.97% للمساحات والإحداثيات) |
| **شبكة الطرق والمرور (Roads & Traffic)** | `roads_` / `traffic_` | أطوال الطرق حسب الدرجة (سريعة، رئيسية، فرعية، سكنية، خدمية)، كثافة الطرق، كثافة التقاطعات، نسبة النهايات المغلقة (`dead_end_ratio`)، الاتجاه الواحد (`oneway_ratio`)، الكباري والأنفاق | تغطية **99.97%** لخصائص هندسة الشبكة، بينما تغطية عدد الحارات (`lane_km`) تبلغ **34.62%** ومتوسط السرعات **0.54%** |
| **النقل العام والوصول (Public Transit)** | `transit_` | وجود النقل العام (`has_transit`)، عدد محطات المترو والـ BRT والقطار الخفيف والأتوبيس، المسافات الشبكية لأقرب محطة، السكان ضمن نطاق مشي 400م/800م/1200م، مؤشر سهولة الوصول (`accessibility_score`) | تغطية **99.97%**؛ 87.4% من الخلايا لا تضم محطة داخل حدودها المباشرة |
| **المساحات الخضراء (Green Space)** | `green_space_` | مؤشر الغطاء النباتي `NDVI` (السنوي والصيفي: متوسط، وسيط، مئين 90)، نسبة الغطاء النباتي، مساحة ونسبة الحدائق العامة، الأراضي الزراعية، ومحميات الطبيعة | تغطية **99.97%**؛ 88.9% من الخلايا لا تحتوي على حديقة عامة مسجلة |
| **جودة الهواء (Air Quality)** | `air_quality_` | تركيز عمود $NO_2$ التروبوسفيري من القمر الصناعي `Sentinel-5P` (المتوسط، الوسيط، المئين 90)، والمسافات لأقرب محطات رصد $PM_{2.5}$ و $PM_{10}$ | تغطية **99.97%** لبيانات $NO_2$ الفضائية (متوسط فترة 2026-06-20 إلى 2026-09-16) |

---

## 🛡️ 3. الأهداف السبعة ومنهجية منع تسريب البيانات (Targets & Leakage-Free Governance)

من أهم إسهامات المشروع تطبيق **فحص صارم لتسريب البيانات (Data Leakage Audit)** وتخصيص قائمة متغيرات نظيفة (`Target-Specific Dedicated Features`) لكل هدف:

### أ. مسار الأهداف الأساسية وهندسة الأولويات (`Targets 1, 2, 3`)

| الهدف (Target) | نوع المشكلة والفئات | الفحص الهندسي للتسريب (Leakage Audit) | المتغيرات المعتمدة للتدريب الصادق |
| :--- | :--- | :--- | :--- |
| **`Target 1`: `traffic_structural_susceptibility_class`** | تصنيف متعدد (3 فئات): `LOW` (1,263)، `MODERATE` (1,074)، `HIGH` (1,151) | التدريب المبدئي بـ 11 متغيراً (`Set A`) يحقق دقة **98.42%**، لكن الفحص أثبت أن الـ 11 متغيراً تعيد بناء مؤشر الاحتكاك `friction_index` بمعامل تحديد **$R^2 = 0.9955$** (حيث صُنفت الفئات بعتبتين حادتين: `0` و`0.212780` بنسبة تطابق **99.9713%**) | **`Set B` (7 متغيرات سياقية خالية من التسريب)** بعد حذف متغيرات بنية الطرق الأربعة المكونة للمعادلة (`road_density`, `intersection_density`, `dead_end_ratio`, `oneway_ratio`) |
| **`Target 2`: `traffic_demand_capacity_pressure_class`** | تصنيف متعدد (3 فئات) | متاح في **26 خلية فقط من أصل 3,489 (تغطية 0.75%)** ومفقود في 99.25% بسبب الارتباط التام بغياب متغير `traffic_population_per_lane_km` | **تأجيل النمذجة الإشرافية (Strictly Postponed)** لعدم كفاية العينات إحصائياً ومنع الملء الاصطناعي المضلّل |
| **`Target 3`: `urban_intervention_priority_class`** | مؤشر مركب (0–100) وتصنيف نسبي بالثلثيات (`LOW`, `MODERATE`, `HIGH` بحدود قطع `49.85` و`54.08`) | يُبنى المؤشر من 6 مؤشرات قياسية متساوية الأوزان بعد استبعاد المتغيرات المتداخلة ($\|\rho\| \ge 0.82$)، مع إثبات استقراره عبر **1,000 محاكاة أوزان Dirichlet عشوائية** ($\bar{\rho} = 0.83$) | **66 متغيراً آمناً (`Safe No-Proxy Features`)** بعد استبعاد مدخلات المعادلة الـ 6، وأي متغير يرتبط بها بمعامل سبيرمان $\|\rho\| \ge 0.90$ (15 متغيراً بديلاً)، وحذف الإحداثيات وأعمدة المساحة `area_km2` |

### ب. مسار الأهداف الخمسة مع موازنة الفئات (`SMOTE Benchmark Targets`)

يتم ربط كل هدف بقائمة متغيراته الهندسية المخصصة (`26 إلى 31 متغيراً`) مع استبعاد أي عمود يشتق منه الهدف مباشرة:
1. **`1_Traffic_Susceptibility_Class`** (31 متغيراً مخصصاً — 3 فئات: `0=Low`, `1=Moderate`, `2=High`).
2. **`2_Transit_Availability_Binary`** (31 متغيراً مخصصاً — ثنائي غير متوازن: `0=No Transit [3,051]`, `1=Has Transit [438]`).
3. **`3_High_Transit_Accessibility`** (26 متغيراً مخصصاً — ثنائي أعلى/أقل من وسيط التدريب: `0 [2,798]`, `1 [691]`).
4. **`4_Public_Green_Space_Binary`** (27 متغيراً مخصصاً — ثنائي شديد عدم التوازن: `0=No Public Green [3,101]`, `1=Has Public Green [388]`).
5. **`5_High_NO2_Air_Pollution`** (30 متغيراً مخصصاً — ثنائي متوازن أعلى/أقل من وسيط التدريب: `0 [1,745]`, `1 [1,744]`).

---

## 🧠 4. ترسانة النماذج وهيكلة الـ Pipelines (Model Suite & Architecture)

يختبر المشروع ويقارن **9 عائلات من نماذج التصنيف** و**9 نماذج للانحدار** داخل خطوط أنابيب (`Pipelines`) تمنع تسريب إحصائيات التقييس أو الموازنة إلى بيانات الاختبار:

```text
[Dedicated Target Features]
       │
       ▼
┌───────────────────────────────────────────────────────────┐
│ 1. SimpleImputer(strategy="median")                       │
│ 2. PolynomialFeatures(degree=2) + SelectKBest(k=120) (*)  │
│ 3. StandardScaler()                                       │
│ 4. SMOTE(k_neighbors=min(5, min_class-1)) [Train Only] (*)│
└───────────────────────────────────────────────────────────┘
       │
       ├──► 1. MLP Deep Classifier (256 -> 128 -> 64, ReLU, Adam, Adaptive LR, Early Stopping)
       ├──► 2. MLP Compact Classifier (128 -> 64, ReLU, Adam, alpha=0.05, Early Stopping)
       ├──► 3. CatBoost Classifier / Regressor (depth=6, lr=0.05)
       ├──► 4. XGBoost Classifier / Regressor (max_depth=6, lr=0.05, subsample=0.85)
       ├──► 5. LightGBM Classifier / Regressor (num_leaves=31, max_depth=6, lr=0.05)
       ├──► 6. Random Forest Classifier / Regressor (n_estimators=350, max_depth=15, balanced)
       ├──► 7. Logistic Regression / Linear, RidgeCV, LassoCV
       ├──► 8. Support Vector Machine — SVC (RBF, C=5.0) & SVR (RBF, C=10.0, epsilon=0.1)
       └──► 9. K-Nearest Neighbors — KNN Classifier & Regressor (k=15, distance-weighted)
```

---

## 🏆 5. نتائج ومقارنات نماذج التصنيف (Classification Benchmark & F1-Score Matrix)

### 5.1 مقارنة جميع الموديلات الـ 9 لكل تارجت بالفيتشرز المخصصة له (`Macro F1-Score`)

يوضح الجدول التالي ملخص قيم **`Macro F1-Score`** (المعيار الأدق لتقييم الفئات المتوازنة وغير المتوازنة على حدٍ سواء) عبر الأهداف السبعة باستخدام الفيتشرز المخصصة لكل هدف فقط:

| الهدف (Target) والفيتشرز المخصصة | `MLP Deep (256-128-64)` | `MLP Compact (128-64)` | `CatBoost` | `XGBoost` | `LightGBM` | `Random Forest` | `Logistic Regression` | `SVM (RBF)` | `KNN (k=15)` | الفائز (`Winner`) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **`1_Target1_Structural_Susceptibility` (`Set B` — 7 فيتشرز نظيفة)** | 0.721 | 0.718 | **0.7416** | 0.7380 | 0.7325 | 0.7285 | 0.6640 | 0.7195 | 0.6950 | 🏆 **CatBoost** |
| **`2_Target3_Intervention_Priority` (`Safe` — 66 فيتشر آمن)** | 0.788 | 0.784 | **0.8194** | 0.8145 | 0.8110 | 0.7960 | 0.7420 | 0.7810 | 0.7215 | 🏆 **CatBoost** |
| **`3_SMOTE_T1_Traffic_Susceptibility` (31 فيتشر مخصص)** | 0.909 | 0.9072 | **0.9745** | 0.9720 | 0.9705 | 0.9580 | 0.9090 | 0.9125 | 0.8740 | 🏆 **CatBoost / XGB** |
| **`4_SMOTE_T2_Transit_Availability_Binary` (31 فيتشر مخصص)** | 0.831 | 0.8264 | **0.8515** | 0.8475 | 0.8410 | 0.8375 | 0.8119 | 0.8240 | 0.7790 | 🏆 **CatBoost / XGB / MLP** |
| **`5_SMOTE_T3_High_Transit_Accessibility` (26 فيتشر مخصص)** | 0.968 | 0.9639 | **0.9780** | 0.9755 | 0.9745 | 0.9685 | 0.9712 | 0.9650 | 0.9295 | 🏆 **CatBoost / Logistic** |
| **`6_SMOTE_T4_Public_Green_Space_Binary` (27 فيتشر مخصص)** | 0.741 | 0.7370 | **0.7675** | 0.7610 | 0.7550 | 0.7515 | 0.7494 | 0.7385 | 0.6890 | 🏆 **CatBoost / XGB / Logistic** |
| **`7_SMOTE_T5_High_NO2_Air_Pollution` (30 فيتشر مخصص)** | **0.874** | 0.8686 | **0.9120** | 0.9085 | 0.9050 | 0.8920 | 0.8610 | 0.8815 | 0.8540 | 🏆 **CatBoost / XGB / MLP** |

### 5.2 مقارنة التقسيم العشوائي (`Random 80/20`) بالتقسيم المكاني (`Spatial 5-Fold GroupKFold`)

للتأكد من عدم تضخم النتائج بسبب التشابه الجغرافي بين الخلايا المتجاورة (`Spatial Autocorrelation`)، تم تقسيم خلايا H3 جغرافياً إلى 10 تجمعات مكانية (`KMeans Spatial Clusters`) وتقييم النماذج عبر `5-Fold GroupKFold`:
- **`Target 1 (Set B — 7 Features)`**: ينخفض `Macro-F1` بشكل معتدل من **0.7416** (في التقسيم العشوائي) إلى **0.6781 ± 0.071** (في التقسيم المكاني)، مما يدل على قدرة جيدة على التعميم في مناطق جديدة.
- **`Target 3 (Safe — 66 Features)`**: يسجل `Macro-F1` نحو **0.8194** (في التقسيم العشوائي) مقابل **0.6077 – 0.6483** (في التقسيم المكاني)، مما يوضح أن جزءاً من إشارة متغيرات المسافة لمحطات النقل يرتبط بالموقع الجغرافي داخل المدينة.

---

## 📈 6. نتائج نماذج الانحدار وتحليل التبعية المكانية (Regression Benchmark & Spatial Field Analysis)

في مسار التنبؤ المستمر بتركيز تلوث الهواء (`air_quality_s5p_no2_tropospheric_column_mean_umol_m2`) تحت تقسيم مكاني صارم (`Spatial GroupShuffleSplit 70/30` على مربعات ~5 كم و~11 كم):

| نموذج الانحدار / الإعداد (Regression Model / Regime) | $R^2$ (على 122 متغيراً) | RMSE (122 متغيراً) | $R^2$ (على 80 متغيراً نظيفاً بدون المكررات وبدائل الموقع) | RMSE (80 متغيراً نظيفاً) | التفسير الهندسي |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Linear Regression** | 0.7003 | 33.42 | 0.5707 | 40.00 | حذف 34 عموداً مكرراً ($\|corr\|>0.99$) وبدائل الموقع يكشف الأداء الحضري الصادق ($R^2 = 0.571$) |
| **RidgeCV ($\alpha = 127$)** | 0.6985 | 33.52 | 0.5660 | 40.22 | يعالج تضخم المعاملات الناتج عن الازدواجية الخطية (`Multicollinearity`) |
| **LassoCV** | 0.7062 | 33.09 | 0.5518 | 40.87 | يختار تلقائياً المتغيرات غير الصفرية الأكثر ارتباطاً |
| **SVR (`kernel='rbf', C=10.0`)** | 0.7450 | 30.82 | 0.6180 | 37.73 | يلتقط اللخطية المكانية والحضرية بكفاءة أعلى من النماذج الخطية |
| **KNN Regressor (`k=15, distance`)** | 0.7280 | 31.84 | 0.5940 | 38.90 | أداء غير معلمي جيد مع تمركز البواقي حول الصفر |
| **MLP Regressor (`256-128-64`)** | 0.7520 | 30.40 | 0.6210 | 37.58 | يتفوق على الانحدار الخطي بفضل تمثيل التفاعلات غير الخطية |
| **Random Forest / XGBoost / LightGBM / CatBoost** | **0.785 – 0.805** | **27.5 – 28.8** | **0.645 – 0.668** | **35.2 – 36.3** | أعلى دقة انحدار من المتغيرات الحضرية على التقسيم المكاني |
| 📍 **Location-Only Baseline (`Cubic Lat/Lon`)** | **0.8740** | **21.70** | — | — | يثبت أن $NO_2$ الفضائي (متوسط فترة واحدة) محكوم أساساً بالموقع الجغرافي الأملس |
| 🪟 **Two-Stage $NO_2$ Model (`Stage 1 Location + Stage 2 Urban Levers`)** | **0.8490** | **23.68** | $R^2_{\text{residual}} = 0.082$ | — | الروافع الحضرية تفسر 8.2% فقط من البواقي بعد طرح أثر الموقع الجغرافي |

---

## 🎛️ 7. محرك السياسات والسيناريوهات الحضرية (What-If Scenario Engine & District Prioritization)

بناءً على الاكتشاف العلمي في القسم السادس بأن نماذج الانحدار على $NO_2$ الثابت لا تصلح لمحاكاة سيناريوهات السياسات الحضرية (`What-If`) لأن تغير $NO_2$ الناتج عن تعديل المتغيرات لا يتجاوز `< 0.12%`، يعتمد المشروع على **محرك مؤشرات الضغط الحضري المركب الشفاف (`Composite Pressure Index`)** عبر الخلايا المأهولة الفعالة ($N = 2,090$ خلية):

1. **المكونات الثلاثة لمؤشر الضغط الحضري**:
   - **ضغط السكان على الطرق (`pop_per_road_km`)**: $\text{Population} / \text{Road Length (km)}$.
   - **حصة الفرد من المساحات الخضراء العامة (`green_m2_per_person`)**: $\text{Public Green Area (m}^2) / \text{Population}$.
   - **تغطية محطات النقل العام (`stops_per_1000_people`)**: $(\text{Transit Stops} / \text{Population}) \times 1000$.
2. **نتائج محاكاة حزم التدخل المستهدفة (Targeted Policy Packages)**:

| السيناريو السياساتي (Policy Scenario) | متوسط مؤشر الضغط (`Mean Pressure`) | نسبة الخلايا الحرجة ($\text{Pressure} \ge 0.75$) | عدد الخلايا المستهدفة بالتدخل | إجمالي محطات النقل المضافة | إجمالي المساحات الخضراء المضافة (هكتار) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **الوضع الحالي (`Baseline`)** | 0.715 | 47.8% | 0 | 0 | 0.0 ha |
| **نمو سكاني `+20%` بدون تدخل** | 0.721 | 49.6% | 0 | 0 | 0.0 ha |
| **نمو `+20%` + إضافة محطتين لأعلى 10% خلايا مضغوطة** | 0.691 | 39.6% | 209 | 418 | 0.0 ha |
| **نمو `+20%` + إضافة 5,000 م² خضرة لأعلى 10% خلايا** | 0.692 | 39.6% | 209 | 0 | 104.5 ha |
| 🚀 **الحزمة المتكاملة لأعلى 20% خلايا (محطتان + 5,000 م² خضرة)** | **0.599 (-16.2%)** | **29.6% (-18.2 pp)** | **418** | **836** | **209.0 ha** |

3. **أعلى 5 أحياء في القاهرة الكبرى احتياجاً للتدخل الحضري**:
   1. **التبين (`El Tebbin`)** — متوسط ضغط أساسي: **`0.87`** (عجز حاد في النقل العام والمساحات الخضراء).
   2. **المرج (`El Marg`)** — متوسط ضغط أساسي: **`0.84`** (كثافة سكانية مرتفعة جداً مع نقص البنية التحتية).
   3. **15 مايو (`15 May`)** — متوسط ضغط أساسي: **`0.81`** (عزلة مكانية ونقص في تغطية المحطات).
   4. **السلام أول (`El Salam 1`)** — متوسط ضغط أساسي: **`0.79`** (تمدد عمراني كثيف).
   5. **حلوان (`Helwan`)** — متوسط ضغط أساسي: **`0.78`** (ضغط صناعي وسكاني مزدوج).

---

## 📂 8. هيكلة ملفات المستودع (Repository Structure)

```text
UrbanMind-AI/
├── UrbanMind_Master_All_Models_Benchmark_Colab.ipynb   # الملف الرئيسي الشامل الجاهز للتشغيل على Google Colab
├── UrbanMind_Master_All_Models_Benchmark_Colab.py      # كود الخلية الأخيرة الموحدة لتشغيل MLP وجدول وتقرير F1-Score
├── notebooks/
│   ├── CatBoosting_Target_1,3.ipynb                    # تحليل وجودة البيانات + Target 1, 2, 3 + فحص التسريب
│   ├── UrbanMind_SMOTE_Model_Benchmark_Colab.ipynb     # مقارنة الأهداف الخمسة باستخدام SMOTE و ImbPipeline
│   ├── Linear_Models_and_Scenario_Engine.ipynb         # النماذج الخطية، فحص الازدواجية، ومحرك السيناريوهات التفاعلي
│   ├── SVM_Model.ipynb                                 # نموذج انحدار SVR وتشخيصات البواقي
│   └── KNN_Model.ipynb                                 # نموذج انحدار KNN وتشخيصات البواقي
├── outputs/
│   ├── macro_f1_comparison_table_target_specific.csv   # جدول مقارنة Macro-F1 لكل تارجت بالفيتشرز المخصصة له
│   ├── weighted_f1_comparison_table_target_specific.csv# جدول مقارنة Weighted-F1 لكل تارجت بالفيتشرز المخصصة له
│   ├── regression_models_comparison.csv                # جدول مقارنة نماذج الانحدار التسعة على NO2
│   ├── urbanmind_scenario_results.csv                  # مخرجات محرك السيناريوهات الجغرافية للربط مع Streamlit/PyDeck
│   ├── target_specific_f1_comparison_heatmap.png       # لوحة المقارنة الحرارية لنتائج الـ F1-Score
│   └── UrbanMind_Target_Specific_MLP_and_F1_Report.md  # التقرير التحليلي التفصيلي الشامل
└── README.md                                           # توثيق المشروع الشامل لـ GitHub
```

---

## ⚡ 9. طريقة التشغيل السريع على Google Colab أو محلياً (Quick Start)

### أ. التشغيل المباشر على Google Colab (بدون رفع ملفات يدوياً)
1. ارفع ملف **`UrbanMind_Master_All_Models_Benchmark_Colab.ipynb`** إلى حسابك في **Google Colab**.
2. يقوم الكود في أول خلية بتثبيت كافة المكتبات وتحميل قاعدة البيانات تلقائياً من Google Drive عبر `gdown`:
   ```python
   !pip install -q gdown catboost xgboost lightgbm imbalanced-learn h3 gradio ipywidgets
   import gdown

   file_id = "12rWfU1htOBuNzzmNaPtpW-bYvZdlMiAU"
   output = gdown.download(id=file_id, output=None, quiet=False, fuzzy=True)
   print("Downloaded file:", output)
   ```
3. اضغط **`Runtime -> Run all` (`Ctrl+F9`)** لتشغيل خط الأنابيب بالكامل وتوليد جميع الجداول، والرسوم البيانية، والتقرير النهائي تلقائياً.

### ب. التشغيل في بيئة محلية (Local Environment)
```bash
git clone https://github.com/<your-username>/UrbanMind-AI.git
cd UrbanMind-AI
pip install numpy pandas matplotlib seaborn scikit-learn imbalanced-learn catboost xgboost lightgbm h3 gdown gradio ipywidgets
jupyter notebook UrbanMind_Master_All_Models_Benchmark_Colab.ipynb
```

---

## ⚠️ قيود منهجية وتوصيات المرحلة القادمة (Limitations & Future Roadmap)
- **الطبيعة المشتقة للأهداف المركبة**: كلٌ من `Target 1` و`Target 3` يمثلان تصنيفات مبنية على مؤشرات رياضية مركبة، لذا تُستخدم النماذج لتقدير هذه المؤشرات من السياق الحضري عند غياب مدخلاتها المباشرة.
- **الحاجة لبيانات زمنية (Panel Data) لتلوث الهواء والمرور**: لتحويل نموذج $NO_2$ إلى محاكي سببي ديناميكي، يوصى في الإصدار القادم بدمج سلاسل زمنية أسبوعية من `Sentinel-5P` مع بيانات الطقس اليومية (`Wind Speed, Temperature, Boundary Layer Height`) وبيانات سرعات المرور الحية (`Dynamic Traffic Flows`).

