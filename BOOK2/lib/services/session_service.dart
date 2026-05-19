import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';

class SessionService {
  static BankAccount? current;
  static Future<void> save(BankAccount a) async {
    current = a;
    final p = await SharedPreferences.getInstance();
    await p.setString('accountNo', a.accountNo);
    await p.setString('fullName', a.fullName);
    await p.setString('referenceNo', a.referenceNo);
  }
  static Future<void> logout() async {
    current = null;
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}
