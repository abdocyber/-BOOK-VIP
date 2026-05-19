# Bankak Flutter Final Package

حزمة Flutter منظمة للتحويل من مشروع PWA إلى تطبيق Android حقيقي، مع صفحات الواجهة الأساسية، الربط مع Firebase، لوحة أدمن خارجية، وأذونات Android.

## الصفحات الموجودة
- Login
- Home
- Notify / إضافة حساب
- Account details
- Transfer
- Transfer Bank
- SendTo
- Success receipt
- Error insufficient balance
- Transactions
- White receipt details

## مهم قبل البناء
افتح الملف:

```text
lib/firebase_options.dart
```

واستبدل قيم `REPLACE_ME` بقيم Firebase الحقيقية، أو نفذ:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## البناء على GitHub
ارفع المشروع إلى GitHub، ثم افتح:

```text
Actions > Build Flutter APK > Run workflow
```

سيتم إخراج APK من Artifacts.

## لوحة الأدمن
الملف موجود هنا:

```text
admin/admin.html
```

ارفعه كصفحة خارجية، وضع نفس إعدادات Firebase داخله.

## Firestore Rules
انسخ محتوى:

```text
firestore.rules
```

إلى Firebase Console > Firestore Database > Rules.

## ملاحظة مطابقة التصميم
تم استخدام نفس ملفات PWA والصور الأصلية داخل `assets/`، وتم تحويل الصفحات الأساسية إلى Flutter مع نفس الألوان والمقاسات والتدرجات والاتجاه RTL. المطابقة النهائية 100% تحتاج اختبار بصري بعد البناء على جهاز Android ومراجعة أي فروقات صغيرة حسب دقة الشاشة والخطوط.

## نسخة تحسين السلاسة + API

تمت إضافة:
- `lib/services/network_service.dart` لفحص اتصال البيانات ومنع تشغيل التطبيق offline.
- `lib/services/api_service.dart` كطبقة API اختيارية بجانب Firebase.
- تحسين كاش الصور والـ precache داخل `main.dart` لتقليل lag.
- تثبيت Portrait وتخفيف انتقال الصفحات.
- ملف `PERFORMANCE_AND_API.md` لشرح تشغيل API خارجي.

### بناء مع API خارجي اختياري

```bash
flutter build apk --release --dart-define=BANKAK_API_BASE_URL=https://your-api-domain.com
```

بدون هذا الخيار سيعمل التطبيق عبر Firebase مباشرة.
