# BOOK2 - نسخة جاهزة للبناء

تم تجهيز هذه النسخة للبناء على GitHub Actions مع تحسين سرعة صفحة تسجيل الدخول.

## أهم التعديلات

- إصلاح تركيب `ThemeData` في `lib/main.dart`.
- تفعيل خط Rubik لكل التطبيق.
- عدم انتظار طلب الأذونات قبل عرض التطبيق، لتقليل تأخير صفحة تسجيل الدخول.
- إزالة التحميل المسبق الثقيل لكل الأيقونات عند بداية التطبيق.
- تحسين صفحة تسجيل الدخول باستعمال `cacheWidth/cacheHeight` لصورة الخلفية لتقليل استهلاك الذاكرة وتسريع الواجهة.
- تحديث ملف GitHub Actions لإصلاح Gradle wrapper تلقائياً قبل البناء.
- جعل `flutter analyze` لا يفشل بسبب التحذيرات أو معلومات التنسيق فقط.
- الإبقاء على أخطاء Dart الحقيقية كأخطاء توقف البناء.

## البناء على GitHub

ادخل إلى:

```text
Actions → Build Flutter APK → Run workflow
```

بعد النجاح ستجد الملف في:

```text
Artifacts → bankak-release-apk
```

## البناء محلياً

قبل البناء المحلي يفضل تشغيل:

```bash
flutter create --platforms=android --project-name bankak_flutter_final .
flutter pub get
flutter build apk --release
```

سيظهر APK هنا:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Firebase

تأكد من تفعيل:

- Authentication → Anonymous
- Authentication → Email/Password
- Firestore Database

