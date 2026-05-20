import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/account.dart';
import '../models/receipt.dart';
import 'api_service.dart';
import 'network_service.dart';
import 'app_state.dart';

class FirebaseService {
  FirebaseService._();
  static final db = FirebaseFirestore.instance;
  static final auth = FirebaseAuth.instance;

  static Future<void> ensureSignedInAnonymously() async {
    if (auth.currentUser != null) return;
    await auth.signInAnonymously().timeout(const Duration(seconds: 10));
  }

  static void _ensureFirebase() {
    if (!AppState.firebaseReady) {
      throw Exception('firebase_unavailable');
    }
  }

  static Future<BankAccount?> login(String identifier, String password) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');
    if (ApiService.enabled) {
      final api = await ApiService.postJson('/login', {'identifier': identifier, 'password': password});
      if (api != null && api['ok'] == true && api['account'] is Map) {
        return BankAccount.fromMap(Map<String, dynamic>.from(api['account'] as Map));
      }
      if (api != null && api['ok'] == false) return null;
    }
    final doc = await db.collection('accounts').doc(identifier).get();
    if (!doc.exists) return null;
    final acc = BankAccount.fromMap(doc.data()!);
    if (acc.password != password || acc.status != 'active') return null;
    return acc;
  }

  static Future<BankAccount?> getAccount(String accountNo) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');
    if (ApiService.enabled) {
      final api = await ApiService.getJson('/accounts/$accountNo');
      if (api != null && api['account'] is Map) {
        return BankAccount.fromMap(Map<String, dynamic>.from(api['account'] as Map));
      }
    }
    final doc = await db.collection('accounts').doc(accountNo).get();
    if (!doc.exists) return null;
    return BankAccount.fromMap(doc.data()!);
  }

  static Future<void> saveAccount(BankAccount account) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');
    if (ApiService.enabled) {
      final api = await ApiService.postJson('/accounts/save', account.toMap());
      if (api != null && api['ok'] == true) return;
    }
    await db.collection('accounts').doc(account.accountNo).set({
      ...account.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<ReceiptData> transfer({
    required String fromAccount,
    required String toAccount,
    required double amount,
    String note = 'N/A',
    String phone = 'N/A',
  }) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');
    
    if (ApiService.enabled) {
      final api = await ApiService.postJson('/transfer', {
        'fromAccount': fromAccount,
        'toAccount': toAccount,
        'amount': amount,
        'note': note,
        'phone': phone,
      });
      if (api != null && api['receipt'] is Map) {
        final r = Map<String, dynamic>.from(api['receipt'] as Map);
        return ReceiptData(
          operationNumber: '${r['operationNumber'] ?? r['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          date: '${r['date'] ?? _fmt(DateTime.now())}',
          fromAccount: '${r['fromAccount'] ?? fromAccount}',
          toAccount: '${r['toAccount'] ?? toAccount}',
          receiverName: '${r['receiverName'] ?? ''}',
          phone: '${r['phone'] ?? phone}',
          note: '${r['note'] ?? note}',
          amount: (r['amount'] is num) ? (r['amount'] as num).toDouble() : amount,
        );
      }
    }

    final txId = DateTime.now().millisecondsSinceEpoch.toString();
    late ReceiptData receipt;
    
    await db.runTransaction((transaction) async {
      // 1. تعريف مسار المرسل فقط
      final fromRef = db.collection('accounts').doc(fromAccount);
      final fromSnap = await transaction.get(fromRef);
      
      if (!fromSnap.exists) throw Exception('sender_not_found');
      
      final fromData = fromSnap.data()!;
      final current = (fromData['balance'] is num) ? (fromData['balance'] as num).toDouble() : 0.0;
      
      // 2. التحقق من أن الرصيد يكفي (إذا لم يكن كافياً يتم إيقاف العملية ورمي خطأ)
      if (current < amount) throw Exception('insufficient_balance');
      
      // 3. خصم المبلغ من المرسل فقط
      transaction.update(fromRef, {'balance': current - amount, 'updatedAt': FieldValue.serverTimestamp()});
      
      // -- تم إزالة قراءة وتحديث بيانات المستلم نهائياً لتفادي مشكلة الصلاحيات الحمراء --

      final now = DateTime.now();
      receipt = ReceiptData(
        operationNumber: txId,
        date: _fmt(now),
        fromAccount: '${fromData['referenceNo'] ?? fromAccount}',
        toAccount: toAccount, // نضع الرقم المدخل دون الحاجة لقراءة بياناته
        receiverName: 'مستلم', // اسم افتراضي لأننا لم نصل لقاعدة بياناته
        phone: phone,
        note: note,
        amount: amount,
      );
      
      // 4. تسجيل العملية في الإيصالات
      transaction.set(db.collection('transactions').doc(txId), {
        'id': txId,
        'operationNumber': txId,
        'date': receipt.date,
        'fromAccount': receipt.fromAccount,
        'toAccount': receipt.toAccount,
        'receiverName': receipt.receiverName,
        'phone': phone,
        'note': note,
        'amount': amount,
        'status': 'success',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    
    return receipt;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> transactions() =>
      db.collection('transactions').orderBy('createdAt', descending: true).snapshots();

  static String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    String p(int n)=>n.toString().padLeft(2,'0');
    return '${p(d.day)}-${m[d.month-1]}-${d.year} ${p(d.hour)}:${p(d.minute)}:${p(d.second)}';
  }

  static String _compatDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static Future<void> _compatEnsureSignedIn() async {
    if (FirebaseAuth.instance.currentUser != null) return;
    await FirebaseAuth.instance.signInAnonymously().timeout(const Duration(seconds: 10));
  }

  static Future<void> ensureDemoAccount() async {
    await _compatEnsureSignedIn();

    const demoAccountNo = '2777277';
    const demoReferenceNo = '0123002777277001';

    final ref = FirebaseFirestore.instance
        .collection('demo_accounts')
        .doc(demoAccountNo);

    final snap = await ref.get();

    if (snap.exists) {
      await ref.set({
        'accountNo': demoAccountNo,
        'identifier': demoAccountNo,
        'referenceNo': demoReferenceNo,
        'password': '1234',
        'status': 'active',
        'isDemo': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

  static Future<bool> refreshAppConfig() async {
    try {
      await _compatEnsureSignedIn();

      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('config')
          .get();

      final data = doc.data() ?? {};

      AppState.appDisabled = data['isAppDisabled'] == true;
      AppState.appDisabledMessage =
          '${data['disabledMessage'] ?? ''}'.trim().isEmpty
              ? 'التطبيق متوقف مؤقتًا، يرجى المحاولة لاحقًا'
              : '${data['disabledMessage']}';

      return AppState.appDisabled;
    } catch (_) {
      AppState.appDisabled = false;
      return false;
    }

  static Future<void> saveNotifyTransferData({
    required String accountNo,
    required String referenceNo,
    required String fullName,
    required String accountType,
    required String branch,
    String? password,
    double balance = 0,
  }) async {
    await _compatEnsureSignedIn();

    final cleanAccountNo = _compatDigits(accountNo);
    final cleanReferenceNo = _compatDigits(referenceNo);

    if (cleanAccountNo.isEmpty) throw Exception('invalid_account_no');
    if (cleanReferenceNo.isEmpty) throw Exception('invalid_reference_no');

    final now = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('demo_receivers')
        .doc(cleanAccountNo)
        .set({
      'accountNo': cleanAccountNo,
      'referenceNo': cleanReferenceNo,
      'fullName': fullName.trim(),
      'accountName': fullName.trim(),
      'name': fullName.trim(),
      'accountType': accountType.trim(),
      'branch': branch.trim(),
      'currency': 'DEMO',
      'status': 'active',
      'source': 'notify_page',
      'transferOnly': true,
      'canLogin': false,
      'isDemoReceiver': true,
      'updatedAt': now,
      'createdAt': now,
    }, SetOptions(merge: true));
  }

}
