# تجهيز BOOK-VIP للبناء على GitHub Actions

## ما تم تجهيزه

- إضافة Workflow في المسار الجذري: `.github/workflows/build-apk.yml`
- ضبط البناء ليعمل من مجلد `BOOK2`
- استخدام Flutter `3.24.5` و Java `17`
- رفع ملف APK الناتج كـ Artifact باسم `book-vip-release-apk`
- الحفاظ على تصميم واجهات Flutter كما هو
- إبقاء صفحة تسجيل الدخول مربوطة بـ Firebase كما هي
- جعل صفحة تفاصيل الحساب تجلب آخر بيانات الحساب من Firebase عند فتحها حتى يظهر الرصيد المحدث
- إضافة خصم رصيد من لوحة الأدمن مع تسجيل العملية في `admin_logs`
- تقليل أذونات Android المطلوبة إلى الأذونات اللازمة للتشغيل والبناء فقط

## طريقة الرفع إلى GitHub

1. افتح المستودع `abdocyber/BOOK-VIP`.
2. ارفع محتويات هذا المجلد كما هي إلى جذر المستودع.
3. تأكد أن الملف موجود هنا:

```text
.github/workflows/build-apk.yml
```

4. اذهب إلى تبويب Actions.
5. افتح Workflow باسم `Build Flutter APK`.
6. اضغط `Run workflow`.
7. بعد اكتمال البناء، حمل APK من Artifacts.

## Firebase

ملفات Firebase الحالية موجودة داخل المشروع:

```text
BOOK2/lib/firebase_options.dart
BOOK2/android/app/google-services.json
BOOK2/firestore.rules
BOOK2/admin/admin.html
```

لو عندك API حكومي/رسمي خارج Firebase، أضف رابط السيرفر في GitHub Variables باسم:

```text
BANKAK_API_BASE_URL
```

من المسار:

```text
Settings → Secrets and variables → Actions → Variables
```
