# تقرير فحص جاهزية GitHub Build

تم فحص النسخة وتجهيزها للبناء على GitHub Actions من مجلد `BOOK2`.

## المسارات الأساسية

- التطبيق: `BOOK2/`
- لوحة الأدمن الخارجية: `admin/admin.html`
- ملف البناء: `.github/workflows/build-apk.yml`
- قواعد Firestore: `admin/firestore.rules` و `BOOK2/firestore.rules`

## الحساب التجريبي

- رقم الحساب: `3024821`
- الرقم المرجعي: `0123003024821001`
- كلمة المرور: `1234`
- الرصيد الابتدائي: `50000`

## ملاحظات التشغيل

1. ارفع محتويات هذا الملف إلى جذر مستودع GitHub.
2. من GitHub افتح `Actions` ثم شغل `Build Flutter APK`.
3. بعد اكتمال البناء ستجد APK داخل Artifacts باسم `app-release-apk`.
4. لوحة الأدمن ليست داخل APK؛ افتح `admin/admin.html` خارج التطبيق لإدارة الحسابات والإيقاف والشحن والخصم.
