# دليل وشرح تفصيلي متسلسل لجميع خلايا النوت بوك (Cell-by-Cell Guide)

> **المشروع:** UrbanMind AI — Urban Digital Twin & Spatial Analytics for Cairo
> **النوت بوك:** `urbanmind_eda_preprocessing.ipynb`
> **إجمالي الخلايا:** 125 خلية مرتبة ترتيباً منطقياً وعلمياً متسلسلاً.

---

## فهرس الأقسام الرئيسية في النوت بوك

1. **Section 1: Load Data** (الخلايا 0 إلى 4): تحميل المكتبات والبيانات الاستكشافية المبدئية.
2. **Section 2: Data Quality Checks** (الخلايا 5 إلى 22): الفحص الشامل لجودة البيانات، الأنواع، التكرار، والنسب المئوية للقيم المفقودة وتحديد الأعمدة الميؤوس منها (>50%).
3. **Section 3: Data Cleaning & Imputation** (الخلايا 23 إلى 43): التنظيف الفعلي وحذف التكرار، إسقاط الأعمدة التالفة، ومعالجة القيم الناقصة بالـ Median والـ Mode لكل domain في خلية مستقلة، والتحقق النهائي.
4. **Section 4: Exploratory Data Analysis (EDA)** (الخلايا 44 إلى 89): استكشاف وتحليل بصري عميق للداتا النظيفة عبر 20 محور وسؤال تحليلي وخريطة حرارية للارتباطات.
5. **Section 5: Preprocessing & Feature Engineering** (الخلايا 90 إلى 108): هندسة الميزات، إزالة الميتا-داتا والأعمدة الثابتة، تشفير المتغيرات المنطقية والفئوية، تحويل التوزيعات الملتوية log1p، وفحص السلامة.
6. **Section 6: Final Model-Ready Data** (الخلايا 109 إلى 124): إعداد التارجت، التقسيم المكاني 70/30 (Spatial Train/Test Split)، التقييس StandardScaler، وتدريب نموذج Random Forest كخط أساس ورسم أهم الميزات.

---

### [Cell 000] — نوع الخلية: `Markdown` | عنوان النوت بوك ومقدمة عامة
**الوصف والدور التقني:**
يوضح اسم المشروع، وصف الـ Dataset (3,489 خلية H3 في القاهرة)، النطاقات الحضرية الستة (السكان، الطرق، المرور، المواصلات، جودة الهواء، المساحات الخضراء)، وجدول سير العمل المتسلسل من الخطوة 1 إلى 6.

> **محتوى النص:**
> # UrbanMind — EDA, Cleaning & Data Preparation
> 
> **Dataset:** `urbanmind_features_h3.csv` — 3,489 H3 hexagonal cells across Cairo, Egypt.
> 
> **Domains:** Population · Roads · Traffic · Transit · Air Quality · Green Space
> 
> | Step | Section |
> |------|---------|
> | 1 | Load Data |
> | 2 | Data Quality Checks |
> | 3 | Data Cleaning & Imputation |
> | 4 | Exploratory Data Analysis (EDA) |
> | 5 | Preprocessing & Feature Engineering |
> | 6 | Final Model-Ready Data |

---

### [Cell 001] — نوع الخلية: `Markdown` | عنوان القسم 1: تحميل البيانات (Load Data)
**الوصف والدور التقني:**
إعلان بداية المرحلة الأولى الخاصة بتهيئة بيئة العمل واستدعاء البيانات.

> **محتوى النص:**
> ## 1. Load Data

---

### [Cell 002] — نوع الخلية: `Code` | استيراد المكتبات الأساسية وضبط الإعدادات
**الوصف والدور التقني:**
يقوم باستدعاء المكتبات الضرورية (NumPy للحسابات، Pandas لمعالجة البيانات، Matplotlib و Seaborn للرسم والتحليل البصري، Pathlib للتعامل مع المسارات). كما يضبط الثيم الجمالي ومعدل عرض الأعمدة وتنسيق الأرقام العشرية.

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

sns.set_theme(style='whitegrid', palette='muted')
pd.set_option('display.max_columns', 60)
# ... (باقي الكود في الخلية)
```

---

### [Cell 003] — نوع الخلية: `Code` | قراءة ملف البيانات CSV وتوليد نسخة العمل
**الوصف والدور التقني:**
يحدد مسار ملف `urbanmind_features_h3.csv`، يقرأه عبر `pd.read_csv`، ويأخذ نسخة احتياطية مستقلة `df = df_raw.copy()` للحفاظ على البيانات الأصلية، ثم يطبع أبعاد المصفوفة (3,489 صف و 175 عمود).

```python
DATA_PATH = Path('urbanmind_features_h3.csv')
df_raw = pd.read_csv(DATA_PATH)
df = df_raw.copy()
print(f'Shape: {df.shape}  ({df.shape[0]} rows x {df.shape[1]} columns)')
```

---

### [Cell 004] — نوع الخلية: `Code` | معاينة الصفوف الخمسة الأولى (head)
**الوصف والدور التقني:**
يعرض أول 5 صفوف لاستكشاف شكل الأعمدة، أنواع البيانات الأولية، وتسميات الميزات.

```python
display(df.head())
```

---

### [Cell 005] — نوع الخلية: `Markdown` | عنوان القسم 2: فحص جودة البيانات (Data Quality Checks)
**الوصف والدور التقني:**
يوضح الغرض من المرحلة: فحص الأنواع، التكرار، وحصر القيم المفقودة بالكامل لتوجيه قرارات مرحلة التنظيف التالية.

> **محتوى النص:**
> ## 2. Data Quality Checks
> 
> Before touching the data, we audit every possible data-quality issue:
> - Feature types
> - Duplicate rows / H3 IDs
> - Missing values (count, percentage, visualisation, by domain)
> 
> > Findings here drive ALL decisions in Section 3 (Cleaning).

---

### [Cell 006] — نوع الخلية: `Markdown` | عنوان فرعي 2.1: أنواع الميزات (Feature types)
**الوصف والدور التقني:**
مقدمة لفحص تصنيف المتغيرات (رقمية، فئوية، ومنطقية).

> **محتوى النص:**
> ### 2.1 Feature types

---

### [Cell 007] — نوع الخلية: `Code` | حصر وتصنيف الأعمدة حسب Data Types
**الوصف والدور التقني:**
يقوم بفرز الأعمدة إلى ثلاث قوائم: `numeric` للأرقام، `categorical` للنصوص والفئات، و `boolean` للقيم الثنائية True/False، وطباعة عدد كل نوع.

```python
numeric     = df.select_dtypes(include=np.number).columns.tolist()
categorical = df.select_dtypes(include=['object', 'category']).columns.tolist()
boolean     = df.select_dtypes(include='bool').columns.tolist()
print(f'Numeric: {len(numeric)} | Categorical: {len(categorical)} | Boolean: {len(boolean)}')
```

---

### [Cell 008] — نوع الخلية: `Code` | رسم بياني لتوزيع أنواع الميزات
**الوصف والدور التقني:**
يرسم Bar Chart ملون يوضح عدد الأعمدة لكل فئة (Numeric, Categorical, Boolean) لإعطاء نظرة سريعة على طبيعة المصفوفة.

```python
pd.Series({'Numeric': len(numeric), 'Categorical': len(categorical), 'Boolean': len(boolean)}
         ).plot.bar(color=['steelblue', 'coral', 'seagreen'])
plt.title('Feature count by type')
plt.ylabel('Count')
plt.xticks(rotation=0)
plt.tight_layout()
plt.show()
```

---

### [Cell 009] — نوع الخلية: `Markdown` | عنوان فرعي 2.2: فحص الصفوف المكررة (Duplicate rows)
**الوصف والدور التقني:**
مقدمة للتحقق من وجود صفوف مكررة بالكامل.

> **محتوى النص:**
> ### 2.2 Duplicate rows

---

### [Cell 010] — نوع الخلية: `Code` | حساب عدد الصفوف المتطابقة تماماً
**الوصف والدور التقني:**
ينفذ `df.duplicated().sum()` لمعرفة ما إذا كان هناك أي صف تكررت جميع قيمه حرفياً.

```python
dup_rows = df.duplicated().sum()
print(f'Fully duplicate rows: {dup_rows}')
```

---

### [Cell 011] — نوع الخلية: `Markdown` | عنوان فرعي 2.3: فحص تكرار معرفات H3 (Duplicate H3 identifiers)
**الوصف والدور التقني:**
مقدمة للتأكد من فرادة المعرف الجغرافي المكاني `h3_index` لكل منطقة.

> **محتوى النص:**
> ### 2.3 Duplicate H3 identifiers

---

### [Cell 012] — نوع الخلية: `Code` | كشف التكرار في معرفات الخلايا المكانية H3
**الوصف والدور التقني:**
يحسب `df['h3_index'].duplicated().sum()` ويعرض المعرف المكرر إن وجد، لضمان أن كل خلية تمثل منطقة جغرافية فريدة في القاهرة.

```python
dup_h3 = df['h3_index'].duplicated().sum()
print(f'Duplicate H3 IDs: {dup_h3}')
if dup_h3 > 0:
    display(df[df['h3_index'].duplicated(keep=False)][['h3_index']].head(10))
```

---

### [Cell 013] — نوع الخلية: `Markdown` | عنوان فرعي 2.4: عدد القيم المفقودة لكل ميزة
**الوصف والدور التقني:**
مقدمة لحصر الميزات التي تحتوي على قيم فارغة.

> **محتوى النص:**
> ### 2.4 Missing values — count per feature

---

### [Cell 014] — نوع الخلية: `Code` | حساب وعرض عدد الـ Nulls في كل عمود
**الوصف والدور التقني:**
يحسب `df.isna().sum()` ويرتبها تنازلياً ويصفي فقط الأعمدة التي تحوي قيماً مفقودة ويطبع عددها.

```python
null_count = df.isna().sum().sort_values(ascending=False)
null_nonzero = null_count[null_count > 0]
print(f'Features with at least one missing value: {len(null_nonzero)}')
display(null_nonzero.to_frame('null_count'))
```

---

### [Cell 015] — نوع الخلية: `Markdown` | عنوان فرعي 2.5: النسبة المئوية للقيم المفقودة
**الوصف والدور التقني:**
مقدمة لقياس النسبة المئوية للمفقودات لتحديد خطورتها.

> **محتوى النص:**
> ### 2.5 Missing values — percentage per feature

---

### [Cell 016] — نوع الخلية: `Code` | حساب النسبة المئوية للغياب في كل عمود
**الوصف والدور التقني:**
يقوم بحساب النسبة المئوية للقيم الفارغة `df.isna().mean() * 100` وترتيبها تنازلياً لعرضها ومقارنتها.

```python
null_pct = df.isna().mean().mul(100).sort_values(ascending=False)
null_pct_nonzero = null_pct[null_pct > 0]
display(null_pct_nonzero.to_frame('missing_%'))
```

---

### [Cell 017] — نوع الخلية: `Markdown` | تفسير الرسم البياني المزدوج للقيم المفقودة
**الوصف والدور التقني:**
يشرح أن الرسم التالي مقسم لقسمين: رسم يسار يوضح متوسط الفقد لكل Domain، ورسم يمين يوضح الأعمدة المتأثرة فعلياً (>1%) بأسماء مختصرة وواضحة منعاً للتداخل.

> **محتوى النص:**
> **Chart 1 (left):** Average missing % grouped by domain — easy to read at a glance.
> 
> **Chart 2 (right):** Per-feature missing % — only features with > 1 % missing shown,
> coloured by domain with short readable labels.

---

### [Cell 018] — نوع الخلية: `Code` | رسم بياني احترافي متقدم للقيم المفقودة (Domain & Feature levels)
**الوصف والدور التقني:**
ينشئ رسمتين جنب إلى جنب: على اليسار Horizontal Bar Chart لمتوسط الفقد لكل مجال حضري مع خط فاصل عند 50%، وعلى اليمين Bar Chart ملون لكل عمود تجاوز 1% فقد بأسماء مختصرة ونسب دقيقة.

```python
# ── Build domain-level missing % summary ────────────────────────────────
_tmp = null_pct_nonzero.reset_index()
_tmp.columns = ['feature', 'pct']
_tmp['domain'] = _tmp['feature'].str.split('_').str[0]
domain_miss = _tmp.groupby('domain')['pct'].mean().sort_values(ascending=True)

# ── Keep only features with > 1% missing for chart 2 ────────────────────
feat_sig = null_pct_nonzero[null_pct_nonzero > 1].sort_values(ascending=True)
# ... (باقي الكود في الخلية)
```

---

### [Cell 019] — نوع الخلية: `Markdown` | عنوان فرعي 2.6: ملخص القيم المفقودة مجمعة حسب المجالات (Domains)
**الوصف والدور التقني:**
مقدمة لتجميع الفقد الكلي حسب النطاق الجغرافي/الموضوعي.

> **محتوى النص:**
> ### 2.6 Missing values — summary by domain

---

### [Cell 020] — نوع الخلية: `Code` | تجميع ورسم إجمالي القيم المفقودة لكل Domain
**الوصف والدور التقني:**
يستخرج الـ Domain من بادئة كل اسم عمود ويجمع عدد المفقودات الكلي ويرسم Bar Chart يوضح المجالات الأكثر تضرراً (كالمرور والسكان).

```python
import matplotlib.pyplot as plt

null_nonzero = (
    df.isna()
      .sum()
      .loc[lambda s: s > 0]
      .rename("null_count")
)
# ... (باقي الكود في الخلية)
```

---

### [Cell 021] — نوع الخلية: `Markdown` | عنوان فرعي 2.7: تحديد الأعمدة الميؤوس منها (> 50% missing)
**الوصف والدور التقني:**
توضيح أن الأعمدة التي تفتقد لأكثر من نصف بياناتها تمثل عبئاً وتشويهاً ويجب إسقاطها.

> **محتوى النص:**
> ### 2.7 Columns with > 50 % missing — candidates for dropping

---

### [Cell 022] — نوع الخلية: `Code` | تصفية وعرض الأعمدة التي تجاوزت نسبة الفقد فيها 50%
**الوصف والدور التقني:**
يستخرج القائمة الحرجة `high_miss` التي تفقد أكثر من 50% (مثل عدد الحارات ومتوسط السرعة) تمهيداً لحذفها في مرحلة التنظيف.

```python
high_miss = null_pct[null_pct > 50]
print(f'Columns with >50% missing ({len(high_miss)}):')
display(high_miss.to_frame('missing_%'))
```

---

### [Cell 023] — نوع الخلية: `Markdown` | عنوان القسم 3: تنظيف البيانات والتعويض (Data Cleaning & Imputation)
**الوصف والدور التقني:**
يشرح خطة العمل الإجرائية: حذف التكرار، إسقاط الأعمدة التالفة، ثم تعويض النواقص بالـ Median للمتغيرات الرقمية وبالـ Mode للمتغيرات الفئوية لكل نطاق على حدة.

> **محتوى النص:**
> ## 3. Data Cleaning & Imputation
> 
> Now that we know exactly what is wrong with the data, we fix it in order:
> 
> | Step | Action |
> |------|--------|
> | 3.1 | Remove duplicate H3 rows |
> | 3.2 | Drop columns with > 50 % missing |
> | 3.3 | Impute Population domain |
> | 3.4 | Impute Roads domain |
> | 3.5 | Impute Traffic domain |
> | 3.6 | Impute Transit domain |
> | 3.7 | Impute Air Quality domain |
> | 3.8 | Impute Green Space domain |
> | 3.9 | Verify — zero missing values remain |
> 
> **Imputation strategy:**
> - **Numeric** columns → **Median** (robust to skewed / outlier-heavy distributions)
> - **Categorical / Boolean** columns → **Mode** (most frequent observed value)

---

### [Cell 024] — نوع الخلية: `Markdown` | عنوان فرعي 3.1: حذف الصف المكرر لـ H3
**الوصف والدور التقني:**
إرشاد لحذف الخلية المكررة والبدء بإنشاء إطار `clean`.

> **محتوى النص:**
> ### 3.1 Remove duplicate H3 rows

---

### [Cell 025] — نوع الخلية: `Code` | حذف التكرار وإنشاء DataFrame النظيف `clean`
**الوصف والدور التقني:**
ينفذ `clean = df.drop_duplicates('h3_index').copy()` مما يخفض الصفوف من 3,489 إلى 3,488 صفاً فريداً.

```python
clean = df.drop_duplicates('h3_index').copy()
print(f'Rows before dedup: {len(df)}  |  After dedup: {len(clean)}')
```

---

### [Cell 026] — نوع الخلية: `Markdown` | عنوان فرعي 3.2: إسقاط الأعمدة التي تحتوي على أكثر من 50% غياب
**الوصف والدور التقني:**
توضيح لحذف الـ 11 عموداً غير الصالحة للاستخدام الإحصائي.

> **محتوى النص:**
> ### 3.2 Drop columns with > 50 % missing

---

### [Cell 027] — نوع الخلية: `Code` | حذف الأعمدة ذات الفقد العالي (>50%)
**الوصف والدور التقني:**
يقوم بحذف قائمة الأعمدة `high_miss_cols` عبر `clean.drop(columns=...)` وطباعة الأبعاد الجديدة وتأكيد حذفها.

```python
high_miss_cols = null_pct[null_pct > 50].index.tolist()
clean = clean.drop(columns=high_miss_cols)
print(f'Dropped {len(high_miss_cols)} columns. New shape: {clean.shape}')
print('Dropped columns:', high_miss_cols)
```

---

### [Cell 028] — نوع الخلية: `Markdown` | عنوان فرعي 3.3: تعويض قيم نطاق السكان (Population Domain)
**الوصف والدور التقني:**
توضيح تعويض ميزات السكان (796 صفاً خارج الحدود الإدارية للقاهرة).

> **محتوى النص:**
> ### 3.3 Impute — Population domain

---

### [Cell 029] — نوع الخلية: `Markdown` | ملاحظة تفسيرية لغياب السكان
**الوصف والدور التقني:**
يوضح أن 23% من قيم السكان مفقودة لوقوع أطراف الخلايا خارج زمام القاهرة، وأن الـ Median يحفظ التوزيع دون انحياز للـ Outliers.

> **محتوى النص:**
> > **Why?** 796 rows (23 %) in the population domain are missing because those
> > H3 cells fall partially outside the Cairo administrative boundary.
> > Median imputation preserves the distribution without introducing mean-bias from outliers.

---

### [Cell 030] — نوع الخلية: `Code` | تنفيذ Imputation لنطاق السكان (Median + Mode)
**الوصف والدور التقني:**
يعزل أعمدة `population_` الرقمية ويعوض النواقص فيها بالوسيط الحسابي `median`، والأعمدة النصية بالمنوال `mode`، ثم يتأكد من وصول الفقد فيها إلى 0.

```python
pop_num = [c for c in clean.columns
           if c.startswith('population_')
           and clean[c].dtype != object
           and clean[c].dtype.name != 'bool']

pop_cat = [c for c in clean.columns
           if c.startswith('population_')
           and (clean[c].dtype == object or clean[c].dtype.name == 'bool')]
# ... (باقي الكود في الخلية)
```

---

### [Cell 031] — نوع الخلية: `Markdown` | عنوان فرعي 3.4: تعويض قيم نطاق الطرق (Roads Domain)
**الوصف والدور التقني:**
مقدمة لمعالجة ميزات شبكة الطرق.

> **محتوى النص:**
> ### 3.4 Impute — Roads domain

---

### [Cell 032] — نوع الخلية: `Code` | تنفيذ Imputation لنطاق الطرق (Median + Mode)
**الوصف والدور التقني:**
يعوض القيم النادرة المفقودة في أعمدة `roads_` الرقمية بالـ Median والنصية بالـ Mode ويتأكد من خلوها من أي Null.

```python
roads_num = [c for c in clean.columns
             if c.startswith('roads_')
             and clean[c].dtype != object
             and clean[c].dtype.name != 'bool']

roads_cat = [c for c in clean.columns
             if c.startswith('roads_')
             and (clean[c].dtype == object or clean[c].dtype.name == 'bool')]
# ... (باقي الكود في الخلية)
```

---

### [Cell 033] — نوع الخلية: `Markdown` | عنوان فرعي 3.5: تعويض قيم نطاق المرور (Traffic Domain)
**الوصف والدور التقني:**
مقدمة لمعالجة مؤشرات وضغوط الحركة المرورية.

> **محتوى النص:**
> ### 3.5 Impute — Traffic domain

---

### [Cell 034] — نوع الخلية: `Code` | تنفيذ Imputation لنطاق المرور (Median + Mode)
**الوصف والدور التقني:**
يعالج الفقد في مؤشرات الضغط المروري واحتكاك الشبكة `traffic_` عبر الـ Median والـ Mode ويؤكد اكتمالها بنسبة 100%.

```python
traffic_num = [c for c in clean.columns
               if c.startswith('traffic_')
               and clean[c].dtype != object
               and clean[c].dtype.name != 'bool']

traffic_cat = [c for c in clean.columns
               if c.startswith('traffic_')
               and (clean[c].dtype == object or clean[c].dtype.name == 'bool')]
# ... (باقي الكود في الخلية)
```

---

### [Cell 035] — نوع الخلية: `Markdown` | عنوان فرعي 3.6: تعويض قيم نطاق النقل والمواصلات (Transit Domain)
**الوصف والدور التقني:**
مقدمة لمعالجة ميزات المحطات ومؤشرات الوصول للمواصلات.

> **محتوى النص:**
> ### 3.6 Impute — Transit domain

---

### [Cell 036] — نوع الخلية: `Code` | تنفيذ Imputation لنطاق المواصلات (Median + Mode)
**الوصف والدور التقني:**
يعوض أي غياب في محطات الأتوبيس والمترو ومسافات المشي `transit_` بالوسيط والمنوال ويتأكد من معالجتها كاملة.

```python
transit_num = [c for c in clean.columns
               if c.startswith('transit_')
               and clean[c].dtype != object
               and clean[c].dtype.name != 'bool']

transit_cat = [c for c in clean.columns
               if c.startswith('transit_')
               and (clean[c].dtype == object or clean[c].dtype.name == 'bool')]
# ... (باقي الكود في الخلية)
```

---

### [Cell 037] — نوع الخلية: `Markdown` | عنوان فرعي 3.7: تعويض قيم نطاق جودة الهواء (Air Quality Domain)
**الوصف والدور التقني:**
مقدمة لمعالجة بيانات رصد الغازات والملوثات (Sentinel-5P).

> **محتوى النص:**
> ### 3.7 Impute — Air Quality domain

---

### [Cell 038] — نوع الخلية: `Code` | تنفيذ Imputation لنطاق جودة الهواء (Median + Mode)
**الوصف والدور التقني:**
يعالج قيم أعمدة `air_quality_` الرقمية لتركيز NO2 بالوسيط والـ flags بالمنوال ويتحقق من نظافتها.

```python
aq_num = [c for c in clean.columns
          if c.startswith('air_quality_')
          and clean[c].dtype != object
          and clean[c].dtype.name != 'bool']

aq_cat = [c for c in clean.columns
          if c.startswith('air_quality_')
          and (clean[c].dtype == object or clean[c].dtype.name == 'bool')]
# ... (باقي الكود في الخلية)
```

---

### [Cell 039] — نوع الخلية: `Markdown` | عنوان فرعي 3.8: تعويض قيم نطاق المساحات الخضراء (Green Space Domain)
**الوصف والدور التقني:**
مقدمة لمعالجة مؤشرات الغطاء النباتي والحدائق.

> **محتوى النص:**
> ### 3.8 Impute — Green Space domain

---

### [Cell 040] — نوع الخلية: `Code` | تنفيذ Imputation لنطاق المساحات الخضراء (Median + Mode)
**الوصف والدور التقني:**
يعوض نسب ومساحات الحدائق ومؤشر NDVI السنوي `green_space_` بالوسيط الحسابي والمنوال ويطبع نتيجة التحقق.

```python
gs_num = [c for c in clean.columns
          if c.startswith('green_space_')
          and clean[c].dtype != object
          and clean[c].dtype.name != 'bool']

gs_cat = [c for c in clean.columns
          if c.startswith('green_space_')
          and (clean[c].dtype == object or clean[c].dtype.name == 'bool')]
# ... (باقي الكود في الخلية)
```

---

### [Cell 041] — نوع الخلية: `Markdown` | عنوان فرعي 3.9: التحقق الشامل النهائي من انتهاء القيم المفقودة
**الوصف والدور التقني:**
مقدمة لإجراء الفحص الحاسم على كامل المصفوفة.

> **محتوى النص:**
> ### 3.9 Verify — zero missing values remain

---

### [Cell 042] — نوع الخلية: `Code` | فحص والتأكد البرمجي من أن إجمالي القيم المفقودة = صفر
**الوصف والدور التقني:**
يحسب `clean.isna().sum().sum()` ويطبع رسالة تأكيد رسمية بأن جميع القيم المفقودة تم تعويضها بنجاح دون ترك أي خلية فارغة.

```python
total_remaining = clean.isna().sum().sum()
if total_remaining == 0:
    print('All missing values have been imputed successfully.')
else:
    still_missing = clean.isna().sum()
    still_missing = still_missing[still_missing > 0]
    print(f'{total_remaining} missing values still remain:')
    display(still_missing.to_frame('null_count'))
```

---

### [Cell 043] — نوع الخلية: `Code` | طباعة إحصائية ملخصة لأبعاد الداتا النظيفة
**الوصف والدور التقني:**
يعرض الشكل النهائي لـ `clean` بعد التنظيف (3,488 صف و 164 عمود) وعدد الصفوف والأعمدة التي تم استبعادها.

```python
print(f'Clean dataset shape: {clean.shape}')
print(f'  Rows removed (dedup):     {len(df) - len(clean)}')
print(f'  Columns removed (>50%):   {len(high_miss_cols)}')
```

---

### [Cell 044] — نوع الخلية: `Markdown` | عنوان القسم 4: التحليل الاستكشافي للبيانات (EDA)
**الوصف والدور التقني:**
يوضح أن جميع الرسومات والتحليلات اللاحقة تتم حصراً على الداتا النظيفة والمكتملة لضمان دقة الاستنتاجات ومصداقيتها.

> **محتوى النص:**
> ## 4. Exploratory Data Analysis (EDA)
> 
> > All EDA is performed on the **cleaned, imputed** dataset `clean`.
> > This ensures no missing values distort distributions or scatter plots.

---

### [Cell 045] — نوع الخلية: `Markdown` | عنوان فرعي 4.1: توزيع عدد الميزات حسب المجال
**الوصف والدور التقني:**
مقدمة لاستعراض نصيب كل قطاع من الأعمدة.

> **محتوى النص:**
> ### 4.1 Feature count by domain

---

### [Cell 046] — نوع الخلية: `Code` | رسم أفقي لعدد الفيتشرز في كل قطاع
**الوصف والدور التقني:**
يحصي عدد الأعمدة لكل مجال ويرسم Horizontal Bar Chart يوضح ثراء كل نطاق بعد التنظيف.

```python
domains = pd.Series(clean.columns.str.split('_').str[0]).value_counts().sort_values()
domains.plot.barh(color='steelblue')
plt.title('Features by domain')
plt.xlabel('Feature count')
plt.tight_layout()
plt.show()
```

---

### [Cell 047] — نوع الخلية: `Markdown` | عنوان فرعي 4.2: التوزيع المكاني الجغرافي لخلايا H3 في القاهرة
**الوصف والدور التقني:**
مقدمة لرسم خريطة الإحداثيات.

> **محتوى النص:**
> ### 4.2 Spatial distribution of H3 cells

---

### [Cell 048] — نوع الخلية: `Code` | رسم Scatter Map لمواقع الخلايا الجغرافية
**الوصف والدور التقني:**
يرسم خريطة مبعثرة بإحداثيات الطول والعرض (Latitude / Longitude) توضح الامتداد الجغرافي للقاهرة الكبرى وتغطية الخلايا السداسية.

```python
plt.scatter(clean.roads_longitude, clean.roads_latitude, s=3, alpha=.3, c='steelblue')
plt.title('H3-cell spatial distribution — Cairo')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.axis('equal')
plt.tight_layout()
plt.show()
```

---

### [Cell 049] — نوع الخلية: `Markdown` | عنوان فرعي 4.3: توزيع السكان (Population distribution)
**الوصف والدور التقني:**
مقدمة لتحليل أعداد السكان.

> **محتوى النص:**
> ### 4.3 Population distribution

---

### [Cell 050] — نوع الخلية: `Code` | استخراج إحصائيات السكان الوصفية
**الوصف والدور التقني:**
يطبع `describe()` لميزة عدد السكان (المتوسط، الانحراف، الربيعيات، والقيم القصوى).

```python
population = clean['population_population_worldpop_2026']
print(population.describe())
```

---

### [Cell 051] — نوع الخلية: `Code` | رسم مدرج تكراري ومنحنى كثافة لتوزيع السكان
**الوصف والدور التقني:**
يرسم Histogram مع منحنى KDE يوضح شدة التواء توزيع السكان وتركزه في قيم معينة.

```python
sns.histplot(population, bins=40, kde=True, color='steelblue')
plt.title('Population per H3 cell (WorldPop 2026)')
plt.xlabel('Population')
plt.tight_layout()
plt.show()
```

---

### [Cell 052] — نوع الخلية: `Markdown` | عنوان فرعي 4.4: توزيع الكثافة السكانية (Population density)
**الوصف والدور التقني:**
مقدمة لتحليل كثافة السكان لكل كم².

> **محتوى النص:**
> ### 4.4 Population density distribution

---

### [Cell 053] — نوع الخلية: `Code` | استخراج إحصائيات الكثافة السكانية الوصفية
**الوصف والدور التقني:**
يطبع المقاييس الإحصائية التفصيلية للكثافة السكانية.

```python
density = clean['population_population_density_worldpop_2026']
print(density.describe())
```

---

### [Cell 054] — نوع الخلية: `Code` | رسم مدرج تكراري لتوزيع الكثافة السكانية
**الوصف والدور التقني:**
يرسم Histogram ملون ومنحنى KDE يوضح التباين في كثافة الأحياء السكنية.

```python
sns.histplot(density, bins=40, kde=True, color='coral')
plt.title('Population density (residents / km²)')
plt.xlabel('Density')
plt.tight_layout()
plt.show()
```

---

### [Cell 055] — نوع الخلية: `Markdown` | عنوان فرعي 4.5: العلاقة بين عدد السكان والكثافة
**الوصف والدور التقني:**
مقدمة لدراسة الارتباط بين الحجم المطلق والكثافة.

> **محتوى النص:**
> ### 4.5 Population vs density

---

### [Cell 056] — نوع الخلية: `Code` | رسم Scatter Plot يوضح السكان مقابل الكثافة
**الوصف والدور التقني:**
يرسم شكلاً نقطياً يوضح طبيعة العلاقة غير الخطية بين عدد السكان وكثافتهم لكل هكتار/كم².

```python
plt.scatter(population, density, s=7, alpha=.3, c='purple')
plt.title('Population vs Density')
plt.xlabel('Population')
plt.ylabel('Density (residents / km²)')
plt.tight_layout()
plt.show()
```

---

### [Cell 057] — نوع الخلية: `Markdown` | عنوان فرعي 4.6: توزيع أطوال الطرق (Road length)
**الوصف والدور التقني:**
مقدمة لتحليل إجمالي شبكة الطرق.

> **محتوى النص:**
> ### 4.6 Road length distribution

---

### [Cell 058] — نوع الخلية: `Code` | استخراج إحصائيات أطوال الطرق في الخلايا
**الوصف والدور التقني:**
يطبع المؤشرات الإحصائية لإجمالي أطوال الطرق بالكيلومتر.

```python
road_length = clean['roads_road_length_km']
print(road_length.describe())
```

---

### [Cell 059] — نوع الخلية: `Code` | رسم Histogram لأطوال شبكة الطرق
**الوصف والدور التقني:**
يرسم توزيع أطوال الطرق بالكيلومتر لكل خلية مع منحنى الكثافة الاحتمالية.

```python
sns.histplot(road_length, bins=40, kde=True, color='green')
plt.title('Road length per H3 cell (km)')
plt.xlabel('Road length (km)')
plt.tight_layout()
plt.show()
```

---

### [Cell 060] — نوع الخلية: `Markdown` | عنوان فرعي 4.7: توزيع كثافة شبكة الطرق (Road density)
**الوصف والدور التقني:**
مقدمة لتحليل كثافة الطرق لكل كم².

> **محتوى النص:**
> ### 4.7 Road density distribution

---

### [Cell 061] — نوع الخلية: `Code` | رسم Histogram لكثافة الطرق
**الوصف والدور التقني:**
يرسم مدرجاً تكرارياً يوضح تفاوت شبكات الشوارع بين قلب المدينة وأطرافها الصحراوية.

```python
road_density = clean['roads_road_density_km_per_km2']
sns.histplot(road_density, bins=40, kde=True, color='darkgreen')
plt.title('Road density (km / km²)')
plt.xlabel('Road density')
plt.tight_layout()
plt.show()
```

---

### [Cell 062] — نوع الخلية: `Markdown` | عنوان فرعي 4.8: علاقة عدد السكان بأطوال شبكة الطرق
**الوصف والدور التقني:**
مقدمة لدراسة التناسب بين التواجد البشري والبنية التحتية.

> **محتوى النص:**
> ### 4.8 Population vs road length

---

### [Cell 063] — نوع الخلية: `Code` | رسم مبعثر للعلاقة بين السكان وأطوال الطرق
**الوصف والدور التقني:**
يرسم Scatter Plot يبين هل تتناسب البنية التحتية الطرقية طردياً مع حجم التكتلات السكنية أم توجد اختناقات.

```python
plt.scatter(population, road_length, s=7, alpha=.3, c='teal')
plt.title('Population vs Road length')
plt.xlabel('Population')
plt.ylabel('Road length (km)')
plt.tight_layout()
plt.show()
```

---

### [Cell 064] — نوع الخلية: `Markdown` | عنوان فرعي 4.9: مدى توفر خدمات النقل العام (Transit availability)
**الوصف والدور التقني:**
مقدمة لتحليل نسبة تغطية المواصلات.

> **محتوى النص:**
> ### 4.9 Transit availability

---

### [Cell 065] — نوع الخلية: `Code` | رسم Pie Chart لنسبة توفر وسائل المواصلات
**الوصف والدور التقني:**
يرسم مخططاً دائرياً يوضح نسبة الخلايا التي تخدمها وسائل النقل العام مقابل الخلايا المحرومة.

```python
transit_avail = clean['transit_has_transit'].value_counts()
transit_avail.plot.pie(autopct='%1.1f%%', ylabel='', colors=['steelblue', 'coral'])
plt.title('Transit availability across H3 cells')
plt.show()
```

---

### [Cell 066] — نوع الخلية: `Markdown` | عنوان فرعي 4.10: كثافة وعدد محطات النقل في الخلية
**الوصف والدور التقني:**
مقدمة لتحليل وفرة نقاط التوقف.

> **محتوى النص:**
> ### 4.10 Transit stop count

---

### [Cell 067] — نوع الخلية: `Code` | رسم Histogram لعدد محطات المواصلات
**الوصف والدور التقني:**
يرسم توزيع محطات الأتوبيس والمترو ويكشف تركز المحطات في نقاط معينة.

```python
stops = clean['transit_transit_stop_count']
sns.histplot(stops, bins=40, kde=True, color='mediumblue')
plt.title('Transit stop count per H3 cell')
plt.xlabel('Stop count')
plt.tight_layout()
plt.show()
```

---

### [Cell 068] — نوع الخلية: `Markdown` | عنوان فرعي 4.11: المسافة لأقرب محطة نقل جماعي
**الوصف والدور التقني:**
مقدمة لقياس مسافات الوصول.

> **محتوى النص:**
> ### 4.11 Nearest transit stop distance

---

### [Cell 069] — نوع الخلية: `Code` | رسم Histogram لمسافة المشي لأقرب محطة
**الوصف والدور التقني:**
يرسم توزيع المسافة بالمتر عبر شبكة الشوارع للوصول لأقرب نقطة نقل عام.

```python
distance = clean['transit_nearest_transit_stop_network_distance_m']
sns.histplot(distance, bins=40, kde=True, color='royalblue')
plt.title('Network distance to nearest transit stop (m)')
plt.xlabel('Distance (m)')
plt.tight_layout()
plt.show()
```

---

### [Cell 070] — نوع الخلية: `Markdown` | عنوان فرعي 4.12: تأثير مسافة المشي على مؤشر سهولة الوصول
**الوصف والدور التقني:**
مقدمة لدراسة جودة الوصول.

> **محتوى النص:**
> ### 4.12 Distance to stop vs transit accessibility score

---

### [Cell 071] — نوع الخلية: `Code` | رسم مبعثر بين المسافة ومؤشر الـ Accessibility Score
**الوصف والدور التقني:**
يوضح الارتباط العكسي بين المسافة المقطوعة ودرجة سهولة الوصول للمواصلات.

```python
access = clean['transit_transit_accessibility_score']
plt.scatter(distance, access, s=7, alpha=.3, c='navy')
plt.title('Distance to nearest stop vs Accessibility score')
plt.xlabel('Distance (m)')
plt.ylabel('Accessibility score')
plt.tight_layout()
plt.show()
```

---

### [Cell 072] — نوع الخلية: `Markdown` | عنوان فرعي 4.13: توزيع تركيز غاز ثاني أكسيد النيتروجين NO2
**الوصف والدور التقني:**
مقدمة لتحليل التلوث الهوائي.

> **محتوى النص:**
> ### 4.13 NO2 distribution

---

### [Cell 073] — نوع الخلية: `Code` | استخراج إحصائيات تركيز غاز NO2
**الوصف والدور التقني:**
يطبع المقاييس الإحصائية لبيانات القمر الصناعي Sentinel-5P للغاز.

```python
no2 = clean['air_quality_s5p_no2_tropospheric_column_mean_umol_m2']
print(no2.describe())
```

---

### [Cell 074] — نوع الخلية: `Code` | رسم Histogram لتوزيع تركيزات غاز NO2
**الوصف والدور التقني:**
يرسم مدرجاً تكرارياً يوضح بؤر التلوث الهوائي وانبعاثات العوادم.

```python
sns.histplot(no2, bins=40, kde=True, color='orangered')
plt.title('NO2 tropospheric column (µmol/m²)')
plt.xlabel('NO2 (µmol/m²)')
plt.tight_layout()
plt.show()
```

---

### [Cell 075] — نوع الخلية: `Markdown` | عنوان فرعي 4.14: العلاقة بين كثافة الطرق وتلوث الهواء (NO2)
**الوصف والدور التقني:**
مقدمة لربط البنية التحتية بالتلوث.

> **محتوى النص:**
> ### 4.14 Road density vs NO2

---

### [Cell 076] — نوع الخلية: `Code` | رسم مبعثر لكثافة الطرق مقابل تركيز NO2
**الوصف والدور التقني:**
يوضح كيف تسهم كثافة الطرق وحركة المرور في رفع تركيزات غاز ثاني أكسيد النيتروجين.

```python
plt.scatter(road_density, no2, s=7, alpha=.3, c='red')
plt.title('Road density vs NO2')
plt.xlabel('Road density (km/km²)')
plt.ylabel('NO2 (µmol/m²)')
plt.tight_layout()
plt.show()
```

---

### [Cell 077] — نوع الخلية: `Markdown` | عنوان فرعي 4.15: علاقة الكثافة السكانية بتلوث الهواء
**الوصف والدور التقني:**
مقدمة لربط الضغط البشري بانبعاثات الغازات.

> **محتوى النص:**
> ### 4.15 Population vs NO2

---

### [Cell 078] — نوع الخلية: `Code` | رسم مبعثر للسكان مقابل تركيز NO2
**الوصف والدور التقني:**
يرسم شكلاً نقطياً يوضح مدى تعرض الكتل السكانية الكبيرة لمستويات مرتفعة من الانبعاثات.

```python
plt.scatter(population, no2, s=7, alpha=.3, c='darkorange')
plt.title('Population vs NO2')
plt.xlabel('Population')
plt.ylabel('NO2 (µmol/m²)')
plt.tight_layout()
plt.show()
```

---

### [Cell 079] — نوع الخلية: `Markdown` | عنوان فرعي 4.16: توزيع مؤشر الغطاء النباتي السنوي NDVI
**الوصف والدور التقني:**
مقدمة لتحليل الرقعة الخضراء عبر الأقمار الصناعية.

> **محتوى النص:**
> ### 4.16 NDVI distribution

---

### [Cell 080] — نوع الخلية: `Code` | استخراج إحصائيات مؤشر NDVI السنوي
**الوصف والدور التقني:**
يطبع المقاييس الوصفية لمؤشر الفرق المعياري للغطاء النباتي.

```python
ndvi = clean['green_space_ndvi_mean_annual_2026']
print(ndvi.describe())
```

---

### [Cell 081] — نوع الخلية: `Code` | رسم Histogram لتوزيع مؤشر NDVI السنوي
**الوصف والدور التقني:**
يرسم توزيع الغطاء الأخضر ويكشف ندرة الغطاء النباتي في معظم خلايا القاهرة.

```python
sns.histplot(ndvi, bins=40, kde=True, color='limegreen')
plt.title('Annual NDVI mean (2026)')
plt.xlabel('NDVI')
plt.tight_layout()
plt.show()
```

---

### [Cell 082] — نوع الخلية: `Markdown` | عنوان فرعي 4.17: علاقة الغطاء النباتي (NDVI) بمستويات تلوث NO2
**الوصف والدور التقني:**
مقدمة لاختبار الأثر البيئي للمساحات الخضراء.

> **محتوى النص:**
> ### 4.17 NDVI vs NO2

---

### [Cell 083] — نوع الخلية: `Code` | رسم مبعثر لمؤشر NDVI مقابل تركيز NO2
**الوصف والدور التقني:**
يوضح الارتباط العكسي الإيجابي: المناطق ذات الغطاء النباتي المرتفع تشهد انخفاضاً ملحوظاً في تركيزات عوادم السيارات.

```python
plt.scatter(ndvi, no2, s=7, alpha=.3, c='forestgreen')
plt.title('NDVI vs NO2')
plt.xlabel('NDVI')
plt.ylabel('NO2 (µmol/m²)')
plt.tight_layout()
plt.show()
```

---

### [Cell 084] — نوع الخلية: `Markdown` | عنوان فرعي 4.18: توزيع مساحات الحدائق العامة (Public green space)
**الوصف والدور التقني:**
مقدمة لتحليل المتنزهات المتاحة للعامة.

> **محتوى النص:**
> ### 4.18 Public green space area

---

### [Cell 085] — نوع الخلية: `Code` | رسم Histogram لمساحة الحدائق العامة بالمتر المربع
**الوصف والدور التقني:**
يوضح التوزيع شديد الالتواء للمساحات الخضراء العامة وتركزها في أحياء محددة دون غيرها.

```python
green = clean['green_space_public_green_space_area_m2']
sns.histplot(green, bins=40, kde=True, color='seagreen')
plt.title('Public green space area per H3 cell (m²)')
plt.xlabel('Area (m²)')
plt.tight_layout()
plt.show()
```

---

### [Cell 086] — نوع الخلية: `Markdown` | عنوان فرعي 4.19: توزيع مؤشر الاحتكاك الهيكلي للمرور (Traffic friction index)
**الوصف والدور التقني:**
مقدمة لقياس صعوبة الحركة المرورية الهيكلية.

> **محتوى النص:**
> ### 4.19 Traffic friction index distribution

---

### [Cell 087] — نوع الخلية: `Code` | رسم Histogram لمؤشر احتكاك الشبكة المرورية
**الوصف والدور التقني:**
يرسم توزيع الـ Friction Index الممتد من 0 إلى 1 لتقييم كفاءة الحركة.

```python
friction = clean['traffic_structural_network_friction_index']
sns.histplot(friction, bins=40, kde=True, color='brown')
plt.title('Traffic structural network friction index')
plt.xlabel('Friction index')
plt.tight_layout()
plt.show()
```

---

### [Cell 088] — نوع الخلية: `Markdown` | عنوان فرعي 4.20: مصفوفة الارتباط لأعلى 25 ميزة متغيرة التباين
**الوصف والدور التقني:**
مقدمة لتحليل العلاقات المتعددة بين المتغيرات الأكثر تأثيراً.

> **محتوى النص:**
> ### 4.20 Correlation heatmap — top 25 high-variance features

---

### [Cell 089] — نوع الخلية: `Code` | رسم Heatmap احترافية لمصفوفة الارتباط Correlation Matrix
**الوصف والدور التقني:**
يحدد أعلى 25 ميزة من حيث الـ Variance وينشئ خريطة حرارية بألوان vlag متمركزة حول الصفر لكشف أقوى العلاقات الخطية الموجبة والسالبة.

```python
num_clean = clean.select_dtypes(include=np.number).columns.tolist()
top_var = clean[num_clean].var().sort_values(ascending=False).head(25).index
plt.figure(figsize=(14, 10))
sns.heatmap(clean[top_var].corr(), cmap='vlag', center=0,
            annot=False, linewidths=0.3)
plt.title('Correlation heatmap — top 25 high-variance numeric features')
plt.tight_layout()
plt.show()
```

---

### [Cell 090] — نوع الخلية: `Markdown` | عنوان القسم 5: المعالجة وهندسة الميزات (Preprocessing & Feature Engineering)
**الوصف والدور التقني:**
يشرح خطوات تحويل الداتا النظيفة إلى مصفوفة إدخال رقمية جاهزة لخوارزميات التعلم الآلي عبر خطوات متسلسلة.

> **محتوى النص:**
> ## 5. Preprocessing & Feature Engineering
> 
> Transform the clean dataset into a numeric, model-ready feature matrix.
> 
> | Step | Action |
> |------|--------|
> | 5.1 | Define & drop metadata / ID columns |
> | 5.2 | Drop constant / near-constant columns |
> | 5.3 | Build feature frame `X` |
> | 5.4 | Encode boolean columns → 0/1 |
> | 5.5 | One-hot encode low-cardinality categoricals |
> | 5.6 | Drop remaining high-cardinality text columns |
> | 5.7 | Log-transform skewed numeric features |
> | 5.8 | Validate (no NaN / Inf) |

---

### [Cell 091] — نوع الخلية: `Markdown` | عنوان فرعي 5.1: تحديد أعمدة البيانات الوصفية (Metadata / IDs) لحذفها
**الوصف والدور التقني:**
إيضاح لحصر الكلمات المفتاحية لأعمدة الـ metadata والروابط والجودة.

> **محتوى النص:**
> ### 5.1 Define metadata / ID columns to drop

---

### [Cell 092] — نوع الخلية: `Code` | بناء قائمة أعمدة الميتا-داتا والمعرفات غير التنبؤية
**الوصف والدور التقني:**
يحدد قائمة Tokens مثل source, url, doi, crs, version, quality_flag ومعرف h3_index ويستخرج قائمة الأعمدة التابعة لحذفها.

```python
META_TOKENS = (
    'source', 'url', 'doi', 'date', 'version', 'crs', 'grid',
    'analytical_grid', 'reference_year', 'observation_start', 'observation_end',
    'source_type', 'source_version', 'quality_flag', 'production_date',
    'snapshot_date', 'source_dataset', 'spatial_resolution_m',
    'native_spatial_resolution', 'source_url', 'population_type',
    'is_observed', 'is_estimated', 'is_derived', 'data_status',
    'index_available', 'coverage_flag',
# ... (باقي الكود في الخلية)
```

---

### [Cell 093] — نوع الخلية: `Markdown` | عنوان فرعي 5.2: تحديد وإسقاط الأعمدة الثابتة عديمة التباين
**الوصف والدور التقني:**
مقدمة لحذف الأعمدة التي تحمل قيمة واحدة فقط ولا تقدم أي معلومة.

> **محتوى النص:**
> ### 5.2 Drop constant / near-constant columns

---

### [Cell 094] — نوع الخلية: `Code` | كشف الأعمدة ذات التباين الصفري (Constant Columns)
**الوصف والدور التقني:**
يستخرج الأعمدة التي عدد قيمها الفريدة `nunique() <= 1` لتجنيب النموذج متدرباً أوزاناً ميتة.

```python
const_drop = [c for c in clean.columns
              if c not in meta_drop
              and clean[c].nunique(dropna=False) <= 1]
print(f'Constant columns to drop ({len(const_drop)}): {const_drop}')
```

---

### [Cell 095] — نوع الخلية: `Markdown` | عنوان فرعي 5.3: بناء إطار الميزات الصافية `X`
**الوصف والدور التقني:**
مقدمة لإنشاء مصفوفة المتغيرات المستقلة.

> **محتوى النص:**
> ### 5.3 Build feature frame X

---

### [Cell 096] — نوع الخلية: `Code` | تصفية مصفوفة الميزات المستقلة واستبعاد الأعمدة غير المرغوبة
**الوصف والدور التقني:**
يجمع قوائم الاستبعاد `all_drop` وينشئ مصفوفة جديدة `X` ويطبع أبعادها المنقحة.

```python
all_drop = list(set(meta_drop + const_drop))
X = clean[[c for c in clean.columns if c not in all_drop]].copy()
print(f'Feature frame shape: {X.shape}')
```

---

### [Cell 097] — نوع الخلية: `Markdown` | عنوان فرعي 5.4: تحويل الأعمدة المنطقية (Boolean) إلى أرقام 0 و 1
**الوصف والدور التقني:**
مقدمة لتشفير المتغيرات الثنائية.

> **محتوى النص:**
> ### 5.4 Encode boolean columns → 0/1 integers

---

### [Cell 098] — نوع الخلية: `Code` | تشفير المتغيرات المنطقية إلى أعداد صحيحة ثنائية (0/1)
**الوصف والدور التقني:**
يحدد الأعمدة الـ bool ويحولها باستخدام `.astype(int)` إلى 0 و 1 لتتوافق مع خوارزميات الـ ML.

```python
bool_cols = X.select_dtypes(include='bool').columns.tolist()
X[bool_cols] = X[bool_cols].astype(int)
print(f'Boolean columns encoded ({len(bool_cols)}): {bool_cols}')
```

---

### [Cell 099] — نوع الخلية: `Markdown` | عنوان فرعي 5.5: تشفير المتغيرات الفئوية منخفضة التكرار (One-Hot Encoding)
**الوصف والدور التقني:**
توضيح التعامل مع النصوص حسب الـ Cardinality.

> **محتوى النص:**
> ### 5.5 One-hot encode low-cardinality categorical columns

---

### [Cell 100] — نوع الخلية: `Code` | فرز المتغيرات الفئوية إلى منخفضة وعالية التعدد
**الوصف والدور التقني:**
يصنف الأعمدة النصية: فئات <= 10 قيم فريدة تُجهز للتشفير، وفئات > 10 قيم (نصوص عشوائية) تُجهز للإسقاط.

```python
cat_cols    = X.select_dtypes(include='object').columns.tolist()
low_card    = [c for c in cat_cols if X[c].nunique() <= 10]
high_card   = [c for c in cat_cols if X[c].nunique() >  10]
print(f'Low-cardinality  (encode, <= 10 unique): {low_card}')
print(f'High-cardinality (drop,    > 10 unique): {high_card}')
```

---

### [Cell 101] — نوع الخلية: `Code` | تطبيق One-Hot Encoding وإسقاط الفئة المرجعية الأولى
**الوصف والدور التقني:**
يطبق `pd.get_dummies(..., drop_first=True)` لتحويل الفئات إلى أعمدة ثنائية رقمية مع منع مشكلة Multicollinearity.

```python
X = pd.get_dummies(X, columns=low_card, drop_first=True, dtype=int)
print(f'Shape after OHE: {X.shape}')
```

---

### [Cell 102] — نوع الخلية: `Markdown` | عنوان فرعي 5.6: إسقاط الأعمدة النصية عالية التعدد المتبقية
**الوصف والدور التقني:**
مقدمة للتخلص من أي نصوص باقية بعد الـ OHE.

> **محتوى النص:**
> ### 5.6 Drop remaining high-cardinality text columns

---

### [Cell 103] — نوع الخلية: `Code` | إسقاط الأعمدة النصية غير القابلة للتعميم
**الوصف والدور التقني:**
يحذف أي أعمدة من نوع object متبقية ويطبع الأبعاد الصافية للمصفوفة.

```python
remaining_cat = X.select_dtypes(include='object').columns.tolist()
X = X.drop(columns=remaining_cat)
print(f'Dropped: {remaining_cat}')
print(f'Shape after dropping high-cardinality cols: {X.shape}')
```

---

### [Cell 104] — نوع الخلية: `Markdown` | عنوان فرعي 5.7: تطبيق التحويل اللوغاريتمي على الميزات شديدة الالتواء
**الوصف والدور التقني:**
شرح لمعالجة التوزيعات الملتوية التي تحوي ذيولاً طويلة وقيم Outliers.

> **محتوى النص:**
> ### 5.7 Log-transform heavily skewed numeric features

---

### [Cell 105] — نوع الخلية: `Code` | حساب معامل الالتواء Skewness لجميع الميزات الرقمية
**الوصف والدور التقني:**
يحسب الـ Skewness لكل عمود ويصفي الأعمدة ذات الالتواء الحاد التي تتجاوز القيمة المطلقة لها 1.

```python
from scipy.stats import skew

num_feat = X.select_dtypes(include=np.number).columns.tolist()
skewness = X[num_feat].apply(lambda c: skew(c.dropna()))
skewed_cols = skewness[skewness.abs() > 1].index.tolist()
print(f'Features with |skewness| > 1: {len(skewed_cols)}')
print(skewed_cols[:15], '...' if len(skewed_cols) > 15 else '')
```

---

### [Cell 106] — نوع الخلية: `Code` | تطبيق دالة `log1p` على الأعمدة الملتوية موجبة القيم
**الوصف والدور التقني:**
ينفذ التحويل الرياضي `np.log1p(x)` على الأعمدة الملتوية، وهو آمن للقيم الصفرية، مما يقلص أثر القيم الشاذة ويجعل التوزيع يقترب من الطبيعي.

```python
# log1p is safe for columns that can contain zero
log_applied = []
for col in skewed_cols:
    if (X[col] >= 0).all():
        X[col] = np.log1p(X[col])
        log_applied.append(col)
print(f'log1p applied to {len(log_applied)} columns.')
```

---

### [Cell 107] — نوع الخلية: `Markdown` | عنوان فرعي 5.8: التحقق النهائي من سلامة مصفوفة الميزات (خلوها من NaN و Inf)
**الوصف والدور التقني:**
مقدمة لفحص سلامة القيم الناتجة عن التحويلات الرياضية.

> **محتوى النص:**
> ### 5.8 Validate — no NaN or Inf in feature frame

---

### [Cell 108] — نوع الخلية: `Code` | التأكد البرمجي التام من عدم وجود قيم لا نهائية أو فارغة في `X`
**الوصف والدور التقني:**
يستبدل قيم inf بـ nan ويفحص وجود أي قيمة غير صالحة ليؤكد أن المصفوفة خالية تماماً وجاهزة 100%.

```python
bad = X.replace([np.inf, -np.inf], np.nan).isna().sum()
bad = bad[bad > 0]
if len(bad) == 0:
    print('Feature frame is clean — no NaN or Inf values.')
else:
    print('Problematic columns:')
    display(bad.to_frame('issues'))
```

---

### [Cell 109] — نوع الخلية: `Markdown` | عنوان القسم 6: تجهيز البيانات لتدريب النماذج (Final Model-Ready Data)
**الوصف والدور التقني:**
يشرح خطوات تجهيز التدريب: تحديد المتغير التابع، التقسيم المكاني الصارم، التقييس القياسي، واختبار خط الأساس.

> **محتوى النص:**
> ## 6. Final Model-Ready Data
> 
> | Step | Action |
> |------|--------|
> | 6.1 | Set target variable |
> | 6.2 | Separate features and target |
> | 6.3 | Spatial train/test split (70/30) |
> | 6.4 | StandardScaler normalisation |
> | 6.5 | Summary |
> | 6.6 | Random Forest baseline |

---

### [Cell 110] — نوع الخلية: `Markdown` | عنوان فرعي 6.1: تحديد وضبط المتغير التابع (Target Variable)
**الوصف والدور التقني:**
إرشاد للمستخدم لاختيار العمود المراد التنبؤ به.

> **محتوى النص:**
> ### 6.1 Set target variable

---

### [Cell 111] — نوع الخلية: `Code` | ضبط وتثبيت المتغير التابع `TARGET` وبذرة العشوائية
**الوصف والدور التقني:**
يحدد المتغير الافتراضي `transit_transit_accessibility_score` ويثبت `RANDOM_STATE = 42` لضمان قابلية إعادة تكرار التجربة.

```python
# ----------------------------------------------------------------
# Change TARGET to any numeric column you want to predict.
# Regression examples:
#   'transit_transit_accessibility_score'
#   'air_quality_s5p_no2_tropospheric_column_mean_umol_m2'
#   'traffic_structural_network_friction_index'
#   'green_space_total_green_space_fraction'
# ----------------------------------------------------------------
# ... (باقي الكود في الخلية)
```

---

### [Cell 112] — نوع الخلية: `Markdown` | عنوان فرعي 6.2: فصل المتغير التابع عن مصفوفة الميزات المستقلة
**الوصف والدور التقني:**
مقدمة لعزل X عن y.

> **محتوى النص:**
> ### 6.2 Separate features and target

---

### [Cell 113] — نوع الخلية: `Code` | تكوين المتجه التابع `y` ومصفوفة الميزات المستقلة `X_feat`
**الوصف والدور التقني:**
يتأكد من وجود التارجت، يعزله في `y`، ويحذفه من الميزات المستقلة `X_feat` ثم يطبع أبعاد وإحصائيات المتغير التابع.

```python
if TARGET not in X.columns:
    # Re-attach from clean if it was dropped during preprocessing
    X[TARGET] = clean.loc[X.index, TARGET].values
    print('Target re-attached from clean frame.')

y      = X[TARGET].copy()
X_feat = X.drop(columns=[TARGET])
print(f'Features: {X_feat.shape}  |  Target: {y.shape}')
# ... (باقي الكود في الخلية)
```

---

### [Cell 114] — نوع الخلية: `Markdown` | عنوان فرعي 6.3: التقسيم المكاني الصارم للتدريب والاختبار (Spatial Train/Test Split)
**الوصف والدور التقني:**
توضيح أهمية التقسيم المكاني لتفادي مشكلة Spatial Data Leakage.

> **محتوى النص:**
> ### 6.3 Spatial train/test split (70 / 30)

---

### [Cell 115] — نوع الخلية: `Markdown` | الأساس العلمي للتقسيم المكاني
**الوصف والدور التقني:**
يوضح أن الخلايا المتجاورة شديدة التشابه، والتقسيم العشوائي البسيط يسرب معلومات جغرافية ويزيف دقة النموذج، لذا يجب التقسيم إلى بلوكات مكانية مستقلة.

> **محتوى النص:**
> > **Why spatial split?** Urban data has strong spatial autocorrelation —
> > neighbouring cells are very similar. A random split would allow the model
> > to 'memorise' local patterns, inflating apparent accuracy.
> > Splitting by rounded-coordinate blocks ensures the test set is
> > **geographically separated** from training.

---

### [Cell 116] — نوع الخلية: `Code` | تنفيذ التقسيم المكاني للبيانات بنسبة 70% تدريب و 30% اختبار
**الوصف والدور التقني:**
يدمج إحداثيات خطوط الطول والعرض بعد تقريبها إلى خانتين عشريتين لتكوين كتل مكانية، ويخلط الكتل عشوائياً ويخصص 70% للتدريب و 30% للاختبار.

```python
lat_col = 'roads_latitude'
lon_col = 'roads_longitude'

blocks = (clean.loc[X_feat.index, lat_col].round(2).astype(str)
          + '|' +
          clean.loc[X_feat.index, lon_col].round(2).astype(str))

u = np.array(sorted(blocks.unique()))
# ... (باقي الكود في الخلية)
```

---

### [Cell 117] — نوع الخلية: `Markdown` | عنوان فرعي 6.4: التقييس المعياري للميزات باستخدام StandardScaler
**الوصف والدور التقني:**
مقدمة لتوحيد مقاييس الرسم لجميع الميزات.

> **محتوى النص:**
> ### 6.4 StandardScaler normalisation

---

### [Cell 118] — نوع الخلية: `Code` | تطبيق StandardScaler على التدريب ونقل التحويل للاختبار
**الوصف والدور التقني:**
ينشئ كائن StandardScaler، يطبق `fit_transform` على `X_train_raw` فقط لمنع تسريب بيانات الاختبار، ثم `transform` على `X_test_raw`، ويعيد المخرجات في DataFrames منظمة.

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()

X_train_raw = X_feat.loc[split.eq('train')]
X_test_raw  = X_feat.loc[split.eq('test')]
y_train     = y.loc[split.eq('train')]
y_test      = y.loc[split.eq('test')]
# ... (باقي الكود في الخلية)
```

---

### [Cell 119] — نوع الخلية: `Markdown` | عنوان فرعي 6.5: الملخص الإحصائي الشامل لمسار البيانات
**الوصف والدور التقني:**
مقدمة لعرض كشف حساب لجميع مراحل التحويل.

> **محتوى النص:**
> ### 6.5 Data pipeline summary

---

### [Cell 120] — نوع الخلية: `Code` | طباعة لوحة ملخص نهائية للبيانات والتقسيم
**الوصف والدور التقني:**
يطبع تقريراً منسقاً يوضح عدد الصفوف الأصلية، والصفوف بعد التنظيف، وعدد الفيتشرز النهائية، ونسبة التوزيع لعينات التدريب والاختبار.

```python
print('=' * 55)
print(f'  Raw rows:           {len(df)}')
print(f'  After dedup:        {len(clean)}')
print(f'  Features (final):   {X_feat.shape[1]}')
print(f'  Target:             {TARGET}')
print(f'  Train samples:      {X_train.shape[0]}')
print(f'  Test samples:       {X_test.shape[0]}')
print(f'  Split ratio:        {X_train.shape[0]/len(X_feat)*100:.1f}% train / '
# ... (باقي الكود في الخلية)
```

---

### [Cell 121] — نوع الخلية: `Markdown` | عنوان فرعي 6.6: اختبار نموذج خط الأساس (Random Forest Baseline)
**الوصف والدور التقني:**
مقدمة لتشغيل نموذج مرجعي سريع للتحقق من جاهزية البيانات وجودتها.

> **محتوى النص:**
> ### 6.6 Random Forest baseline

---

### [Cell 122] — نوع الخلية: `Code` | تدريب وتقييم نموذج الغابات العشوائية Random Forest
**الوصف والدور التقني:**
يدرب نموذج `RandomForestRegressor(n_estimators=200)` على `X_train` و `y_train`، يتنبأ ببيانات `X_test`، ويحسب مقاييس الأداء الدقيقة: معامل التحديد $R^2$ ومتوسط الخطأ المطلق MAE.

```python
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics  import r2_score, mean_absolute_error

rf = RandomForestRegressor(n_estimators=200, random_state=RANDOM_STATE, n_jobs=-1)
rf.fit(X_train, y_train)
y_pred = rf.predict(X_test)

r2  = r2_score(y_test, y_pred)
# ... (باقي الكود في الخلية)
```

---

### [Cell 123] — نوع الخلية: `Code` | حساب ورسم أهم 20 ميزة تنبؤية (Feature Importance)
**الوصف والدور التقني:**
يستخرج أوزان الأهمية النسبية لجميع الميزات من نموذج الغابة العشوائية ويرسم Horizontal Bar Chart لأعلى 20 ميزة تأثيراً في التنبؤ بسهولة الوصول للمواصلات.

```python
# Top-20 feature importances
importances = (pd.Series(rf.feature_importances_, index=X_train.columns)
               .sort_values(ascending=False).head(20))
importances.plot.barh(figsize=(9, 8), color='steelblue')
plt.title('Top 20 feature importances — Random Forest')
plt.gca().invert_yaxis()
plt.tight_layout()
plt.show()
```

---

### [Cell 124] — نوع الخلية: `Markdown` | عنوان فرعي 6.7: جدول الكائنات والمتغيرات الجاهزة للاستخدام البرمجي
**الوصف والدور التقني:**
يعرض جدولاً تفصيلياً بأسماء جميع الكائنات المتوفرة حالياً في ذاكرة الـ Kernel (`X_train`, `X_test`, `y_train`, `y_test`, `scaler`, `split`, `clean`) لتسهيل بناء أي نماذج تعلم آلي لاحقة.

> **محتوى النص:**
> ### 6.7 Objects ready for modelling
> 
> | Object | Description |
> |--------|-------------|
> | `X_train` | Scaled training features |
> | `X_test`  | Scaled test features |
> | `y_train` | Training target values |
> | `y_test`  | Test target values |
> | `scaler`  | Fitted `StandardScaler` |
> | `split`   | 'train'/'test' label per row |
> | `clean`   | Imputed, de-duplicated raw frame |
> 
> > Add your next model cells here.

---
