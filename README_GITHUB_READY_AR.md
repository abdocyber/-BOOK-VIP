# تجهيز GitHub والبناء

- التطبيق داخل مجلد `BOOK2`.
- لوحة الإدارة خارج التطبيق داخل مجلد `admin` في جذر المستودع.
- ملف GitHub Actions في `.github/workflows/build-apk.yml` وسيبني APK من مجلد `BOOK2`.

## Firebase

ارفع القواعد الموجودة في `admin/firestore.rules` إلى Firebase Console > Firestore Database > Rules.

## إيقاف التطبيق

من `admin/admin.html` يمكن تعديل document التالي:

`app_settings/config`

الحقول:

- `isAppDisabled`: true/false
- `disabledMessage`: الرسالة التي تظهر للمستخدم

## بيانات notify

صفحة notify تحفظ البيانات في:

`notify_transfer_data/{accountNo}`

وللحفاظ على التوافق مع التحويل تحفظ/تحدّث الحساب أيضًا في:

`accounts/{accountNo}`
