# 📊 UrbanMind AI Data Directory

يحتوي هذا المجلد على مجموعات البيانات الكاملة لمشروع **UrbanMind AI** لمدينة القاهرة، مقسمة ومصنفة بحسب القطاع التخصصي.

---

## 📂 محتويات مجلد البيانات (Data Architecture Index)

### 🛣️ 1. مجلد `01_road/` (شبكة الطرق والجغرافيا)
* **المحتوى:** يحتوي على ملفات شبكة الطرق (`cairo_roads_csv.zip` و `cairo_roads1.7z` و `cairo_roads.gpkg`).
* **الوصف:** يغطي أكثر من 322,000 قطاع طريق بالقاهرة بأطوالها، اتجاهاتها، تصنيفاتها (`road_class`)، والمحيط الجغرافي الخطي.

---

### 🚌 2. ملف `02_gtfs_transit.zip` (بيانات النقل الجماعي والـ GTFS)
* **المحتوى:** يضم ملفات GTFS القياسية:
  * `agency.csv`: شركات وهيئات النقل المشغلة (7 شركات).
  * `routes.csv`: خطوط ومسارات المواصلات المعتمدة (602 مساراً).
  * `trips.csv`: الرحلات اليومية المجدولة لكل مسار (9,810 رحلة).
  * `stop_times.csv`: مواعيد وصول ومغادرة الحافلات عند المحطات (222,804 سجل).
  * `stops.csv`: المواقع الجغرافية لمحطات النقل (2,222 محطة).
  * `shapes.csv`: نقاط رسم خط سير الرحلات على الخريطة (181,717 نقطة).
  * `frequencies.csv`: أزمنة التقاطر والترددات (`headway_secs`).
  * `calendar.csv` & `calendar_dates.csv` & `feed_info.csv`: مواعيد التشغيل وإصدار التغذية.
  * `integrated_stops.csv` & `stop_features.csv`: ربط المحطات بالكثافة السكانية الخادمة ومعدل الرحلات اليومية.

---

### 👥 3. ملف `03_demographics.zip` (البيانات السكانية والديموغرافية)
* **المحتوى:** يضم ملفات التوزيع السكاني لـ 43 حيًا بالقاهرة:
  * `master_dataset_2.csv`: الشيت المدمج الرئيسي للأحياء السكانية والبيئية.
  * `cairo_population_districts.csv`: التوزيع الديموغرافي المفصل (ذكور/إناث، عدد الأسر، حجم الأسرة).
  * `Cairo_Population_Estimates_2025_Translated.csv`: التقديرات السكانية الرسمية المترجمة لعام 2025.
  * `cairo_districts_population.csv`: مساحات الأحياء بالكيلومتر المربع والكثافات السكانية.
  * `cairo_natural_population_growth.csv`: سجلات معدلات المواليد والوفيات والزيادة الطبيعية.

---

### ♻️ 4. ملف `04_environment_governance.zip` (البيئة، النظافة، والمزايدات)
* **المحتوى:** يضم ملفات البنية التحتية والخدمات:
  * `cairo_waste_management_workforce.csv`: عمالة ومعدات النظافة والجمع السكني بالقطاعات.
  * `cairo_environmental_infrastructure.csv`: المساحات الخضراء (`green_parks_sqm`)، المقالب، والمدافن الصحية ومصانع التدوير.
  * `cairo_microbus_routes_auction.csv`: كراسات ومواصفات مزايدات خطوط ومواقف الميكروباص الجديدة.
  * `cairo_digital_governance_complaints.csv`: بيانات منظومة الشكاوى الموحدة والربط الـ GIS الـ 52 طبقة.

---

### 🌤️ 5. ملف `05_weather.zip` (الطقس والمناخ)
* **المحتوى:** يضم السجلات المناخية التاريخية لمدينة القاهرة:
  * `weather_cairo.csv`: السلسلة الزمنية التاريخية بالساعة (17,544 تسجيلاً) للحرارة الأمطار، والرياح.
  * `weather_hourly_profile.csv`: النمط المتوسط المتوقع للطقس خلال ساعات اليوم الـ 24.

---

### 🗄️ 6. ملف `06_Initial Database.zip` (قاعدة البيانات الهيكلية)
* **المحتوى:** يتضمن ملف قاعدة البيانات **`urbanmind_ai.db`** (SQLite Database).
* **الوصف:** يحتوي على الجداول المدمجة جاهزة للاستعلام المباشر بلغة SQL دون الحاجة لإعادة دمج ملفات الـ CSV.

---

## 🔗 خريطة ربط المفاتيح (Joining Primary Keys)

| المفتاح (Key) | الجداول المرتبطة | الغرض من الدمج |
| :--- | :--- | :--- |
| **`district_ar`** | `master_dataset_2` $\leftrightarrow$ `cairo_environmental_infrastructure` $\leftrightarrow$ `cairo_waste_management_workforce` | حساب نصيب الفرد بالحي من عمال النظافة والمساحات الخضراء. |
| **`route_id`** | `routes.csv` $\leftrightarrow$ `trips.csv` $\leftrightarrow$ `cairo_microbus_routes_auction` | ربط مسارات النقل بالرحلات والمزايدات. |
| **`stop_id`** | `stops.csv` $\leftrightarrow$ `stop_times.csv` $\leftrightarrow$ `stop_features.csv` | تحديد الموقع الجغرافي للمحطة ومعدل رحلاتها اليومي. |
| **`trip_id`** | `trips.csv` $\leftrightarrow$ `stop_times.csv` $\leftrightarrow$ `frequencies.csv` | قياس زمن التقاطر ومواعيد الوصول للرحلات. |
| **`shape_id`** | `trips.csv` $\leftrightarrow$ `shapes.csv` | رسم الخط الهيكلي الجغرافي للمسار على الخريطة. |
