# 🗄️ 06_Initial Database: Primary Draft Relational Database

> ⚠️ **تنبيه هام للفريق (Important Notice):**
> هذه القاعدة هي **قاعدة بيانات أولية مبدئية (Initial / Staging Database)** تم إنشاؤها لغرض التجميع المبدئي وتسهيل الاستعلامات الأولية والاستكشاف. **ليست هي قاعدة البيانات النهائية (Production Database)** التي سنعتمد عليها في المراحل المتقدمة وتنفيذ النماذج؛ حيث سيتم تحديث وتطوير الهيكل النهائي (Final Schema) لاحقاً بناءً على مخرجات التنظيف وهندسة الخصائص.

---

## ⚠️ تعليمات الاستخدام (Download & Extraction Note)

> **ملاحظة:** إذا كنت تقوم بتحميل هذه البيانات عبر الملف المضغوط **`06_Initial Database.zip`** من المجلد الرئيسي، يرجى تنزيله على جهازك وفك الضغط (Unzip/Extract) للوصول إلى ملف قاعدة البيانات الأولية **`urbanmind_ai.db`**.

---

## 📂 محتويات المجلد والـ Database Structure

### 1. `urbanmind_ai.db` (ملف قاعدة البيانات الأولية)
ملف قاعدة بيانات روابطية مبدئية (Draft Relational Database) بنظام **SQLite** يضم الجداول الأساسية التالية للاستعلام السريع:

* **`master_dataset`**: الشيت المبدئي المدمج لمؤشرات الأحياء السكانية والبيئية (المفتاح المبدئي: `district_ar`).
* **`cairo_population_districts`**: جدول التوزيع الديموغرافي المفصل لذكور وإناث والأسر لكل حي.
* **`cairo_districts_population`**: جدول المساحات الجغرافية والكثافات السكانية مقاسة بـ (Person/km²).
* **`cairo_natural_population_growth`**: جدول السجلات التاريخية لمعدلات المواليد والوفيات والنمو الطبيعي.
* **`cairo_environmental_infrastructure`**: جدول المنشآت البيئية والمساحات الخضراء والحدائق.
* **`cairo_waste_management_workforce`**: جدول عمالة ومعدات النظافة والجمع السكني بالقطاعات.

---

## 💻 طريقة الاتصال والاستعلام التجريبي (How to Query in Python & SQL)

يمكنك الاتصال بقاعدة البيانات الأولية واستكشاف الجداول المبدئية مباشرة في بايثون باستخدّام `sqlite3` أو `pandas`:

```python
import sqlite3
import pandas as pd

# 1. الاتصال بقاعدة البيانات الأولية
conn = sqlite3.connect('06_Initial Database/urbanmind_ai.db')

# 2. قراءة جدول الأحياء التجريبي
df_master = pd.read_sql_query("SELECT * FROM master_dataset", conn)

# 3. إغلاق الاتصال
conn.close()
