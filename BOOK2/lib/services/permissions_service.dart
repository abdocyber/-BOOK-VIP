import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  PermissionsService._();

  static Future<void> requestAppPermissions() async {
    try {
      // أقل أذونات لازمة للتطبيق حتى لا يفشل التشغيل على إصدارات Android الحديثة.
      // لم يتم طلب SMS أو إدارة الملفات لأن التطبيق لا يحتاجها للبناء أو تسجيل الدخول.
      await [
        Permission.locationWhenInUse,
      ].request();
    } catch (_) {
      // بعض الأذونات غير متاحة في كل إصدارات أندرويد؛ تجاهلها حتى لا يتوقف التطبيق.
    }
  }
}
