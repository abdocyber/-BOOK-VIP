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

  static String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    final cleaned = '$value'
        .replaceAll(',', '')
        .replaceAll('SDG', '')
        .replaceAll('جنيه', '')
        .replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  static Future<DocumentReference<Map<String, dynamic>>?> _findAccountRef(
    String identifier,
  ) async {
    final key = _digits(identifier);
    if (key.isEmpty) return null;

    final directRef = db.collection('accounts').doc(key);
    final directSnap = await directRef.get();
    if (directSnap.exists) return directRef;

    final queries = [
      db.collection('accounts').where('accountNo', isEqualTo: key).limit(1),
      db.collection('accounts').where('referenceNo', isEqualTo: key).limit(1),
      db.collection('accounts').where('identifier', isEqualTo: key).limit(1),
      db.collection('accounts').where('رقم الحساب', isEqualTo: key).limit(1),
      db.collection('accounts').where('الرقم المرجعي', isEqualTo: key).limit(1),
    ];

    for (final q in queries) {
      final r = await q.get();
      if (r.docs.isNotEmpty) return r.docs.first.reference;
    }

    return null;
  }

  static Future<Map<String, dynamic>?> _findNotifyReceiver(
    String identifier,
  ) async {
    final key = _digits(identifier);
    if (key.isEmpty) return null;

    final direct = await db.collection('notify_transfer_data').doc(key).get();
    if (direct.exists) {
      return {...direct.data()!, 'docId': direct.id};
    }

    final queries = [
      db.collection('notify_transfer_data').where('accountNo', isEqualTo: key).limit(1),
      db.collection('notify_transfer_data').where('referenceNo', isEqualTo: key).limit(1),
      db.collection('notify_transfer_data').where('رقم الحساب', isEqualTo: key).limit(1),
      db.collection('notify_transfer_data').where('الرقم المرجعي', isEqualTo: key).limit(1),
    ];

    for (final q in queries) {
      final r = await q.get();
      if (r.docs.isNotEmpty) {
        final d = r.docs.first;
        return {...d.data(), 'docId': d.id};
      }
    }

    return null;
  }

  static Future<void> ensureDemoAccount() async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    const demoAccountNo = '2777277';
    const demoReferenceNo = '0123002777277001';

    final ref = db.collection('accounts').doc(demoAccountNo);
    final snap = await ref.get();

    await ref.set({
      'accountNo': demoAccountNo,
      'id': demoAccountNo,
      'identifier': demoAccountNo,
      'referenceNo': demoReferenceNo,
      'iban': 'SD6804030002777277001',
      'fullName': 'حساب تجريبي',
      'name': 'حساب تجريبي',
      'accountName': 'حساب تجريبي',
      'accountType': 'حساب توفير',
      'phone': '249000000000',
      'balance': snap.exists ? FieldValue.increment(0) : 50000.0,
      'الرصيد': snap.exists ? FieldValue.increment(0) : 50000.0,
'status': 'active',
      'currency': 'SDG',
      'source': 'demo_seed',
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> getAppConfig() async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    final doc = await db.collection('app_settings').doc('config').get();
    if (!doc.exists) {
      return {'isAppDisabled': false, 'disabledMessage': ''};
    }
    return doc.data() ?? {'isAppDisabled': false, 'disabledMessage': ''};
  }

  static Future<bool> refreshAppConfig() async {
    try {
      final config = await getAppConfig();
      AppState.appDisabled = config['isAppDisabled'] == true;
      AppState.appDisabledMessage =
          '${config['disabledMessage'] ?? ''}'.trim().isEmpty
              ? 'التطبيق متوقف مؤقتًا، يرجى المحاولة لاحقًا'
              : '${config['disabledMessage']}';
      return AppState.appDisabled;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveNotifyTransferData({
    required String accountNo,
    required String referenceNo,
    required String fullName,
    required String accountType,
    required String branch,
    double balance = 0,
  }) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    await ensureSignedInAnonymously();

    final cleanAccountNo = _digits(accountNo);
    final cleanReferenceNo = _digits(referenceNo);
    final now = FieldValue.serverTimestamp();

    final payload = {
      'accountNo': cleanAccountNo,
      'referenceNo': cleanReferenceNo,
      'fullName': fullName.trim(),
      'accountName': fullName.trim(),
      'name': fullName.trim(),
      'accountType': accountType.trim(),
      'branch': branch.trim(),
      'currency': 'SDG',
      'status': 'active',
      'source': 'notify_page',
      'transferOnly': true,
      'canLogin': false,
      'updatedAt': now,
      'createdAt': now,
    };

    // notify_transfer_data فقط للمستلمين.
    // لا يتم إنشاء حساب دخول داخل accounts من صفحة notify.
    // لا يتم حفظ كلمة مرور من notify.
    await db
        .collection('notify_transfer_data')
        .doc(cleanAccountNo)
        .set(payload, SetOptions(merge: true));
  }) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    final cleanAccountNo = _digits(accountNo);
    final cleanReferenceNo = _digits(referenceNo);
    final now = FieldValue.serverTimestamp();

    final payload = {
      'accountNo': cleanAccountNo,
      'referenceNo': cleanReferenceNo,
      'fullName': fullName,
      'accountName': fullName,
      'accountType': accountType,
      'branch': branch,
'currency': 'SDG',
      'status': 'active',
      'source': 'notify_page',
      'transferOnly': true,
      'canLogin': false,
      'createdAt': now,
      'updatedAt': now,
    };

    await db
        .collection('notify_transfer_data')
        .doc(cleanAccountNo)
        .set(payload, SetOptions(merge: true));
  }

  static Future<BankAccount?> login(String identifier, String password) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    if (ApiService.enabled) {
      final api = await ApiService.postJson('/login', {
        'identifier': identifier,
});

      if (api != null && api['ok'] == true && api['account'] is Map) {
        return BankAccount.fromMap(
          Map<String, dynamic>.from(api['account'] as Map),
        );
      }

      if (api != null && api['ok'] == false) return null;
    }

    final ref = await _findAccountRef(identifier);
    if (ref == null) return null;

    final doc = await ref.get();
    if (!doc.exists) return null;

    final acc = BankAccount.fromMap({...doc.data()!, 'docId': doc.id});
    if (acc.password != password || acc.status != 'active') return null;
    return acc;
  }

  static Future<BankAccount?> getAccount(String accountNo) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    if (ApiService.enabled) {
      final api = await ApiService.getJson('/accounts/$accountNo');
      if (api != null && api['account'] is Map) {
        return BankAccount.fromMap(
          Map<String, dynamic>.from(api['account'] as Map),
        );
      }
    }

    final ref = await _findAccountRef(accountNo);
    if (ref != null) {
      final doc = await ref.get();
      if (doc.exists) {
        return BankAccount.fromMap({...doc.data()!, 'docId': doc.id});
      }
    }

    final notify = await _findNotifyReceiver(accountNo);
    if (notify != null) {
      return BankAccount.fromMap({
        ...notify,
        'balance': 0.0,
        'الرصيد': 0.0,
        'status': 'active',
      });
    }

    return null;
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

    if (amount <= 0) throw Exception('invalid_amount');

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
          operationNumber:
              '${r['operationNumber'] ?? r['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          date: '${r['date'] ?? _fmt(DateTime.now())}',
          fromAccount: '${r['fromAccount'] ?? fromAccount}',
          toAccount: '${r['toAccount'] ?? toAccount}',
          receiverName: '${r['receiverName'] ?? ''}',
          phone: '${r['phone'] ?? phone}',
          note: '${r['note'] ?? note}',
          amount: (r['amount'] is num)
              ? (r['amount'] as num).toDouble()
              : amount,
        );
      }
    }

    final fromRef = await _findAccountRef(fromAccount);
    if (fromRef == null) throw Exception('sender_not_found');

    final toRef = await _findAccountRef(toAccount);
    final notifyReceiver =
        toRef == null ? await _findNotifyReceiver(toAccount) : null;

    if (toRef == null && notifyReceiver == null) {
      throw Exception('receiver_not_found');
    }

    final txId = DateTime.now().millisecondsSinceEpoch.toString();
    late ReceiptData receipt;

    await db.runTransaction((transaction) async {
      final fromSnap = await transaction.get(fromRef);
      if (!fromSnap.exists) throw Exception('sender_not_found');

      final fromData = fromSnap.data()!;
      final current = _toDouble(fromData['balance'] ?? fromData['الرصيد']);

      if (current < amount) {
        throw Exception('insufficient_balance');
      }

      Map<String, dynamic> receiverData;

      if (toRef != null) {
        final toSnap = await transaction.get(toRef);
        if (!toSnap.exists) throw Exception('receiver_not_found');

        receiverData = toSnap.data()!;
        final receiverBalance =
            _toDouble(receiverData['balance'] ?? receiverData['الرصيد']);

        transaction.update(toRef, {
          'balance': receiverBalance + amount,
          'الرصيد': receiverBalance + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        receiverData = notifyReceiver!;
      }

      final newSenderBalance = current - amount;

      transaction.update(fromRef, {
        'balance': newSenderBalance,
        'الرصيد': newSenderBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final receiverAccount =
          '${receiverData['referenceNo'] ?? receiverData['accountNo'] ?? toAccount}';

      final receiverName =
          '${receiverData['fullName'] ?? receiverData['accountName'] ?? receiverData['name'] ?? ''}';

      receipt = ReceiptData(
        operationNumber: txId,
        date: _fmt(DateTime.now()),
        fromAccount:
            '${fromData['referenceNo'] ?? fromData['accountNo'] ?? fromAccount}',
        toAccount: receiverAccount,
        receiverName: receiverName,
        phone: phone,
        note: note,
        amount: amount,
      );

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
        'receiverSource': toRef == null ? 'notify_transfer_data' : 'accounts',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return receipt;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> transactions() {
    return db
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static String _fmt(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    String p(int n) => n.toString().padLeft(2, '0');

    return '${p(d.day)}-${months[d.month - 1]}-${d.year} ${p(d.hour)}:${p(d.minute)}:${p(d.second)}';
  }
}
