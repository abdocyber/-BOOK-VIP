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

  static String _digits(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(
          '$value'.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;
  }

  static Future<DocumentReference<Map<String, dynamic>>?> _findAccountRef(
    String identifier,
  ) async {
    final key = _digits(identifier);
    if (key.isEmpty) return null;

    final direct = db.collection('accounts').doc(key);
    final directSnap = await direct.get();
    if (directSnap.exists) return direct;

    final queries = [
      db.collection('accounts').where('accountNo', isEqualTo: key).limit(1),
      db.collection('accounts').where('identifier', isEqualTo: key).limit(1),
      db.collection('accounts').where('referenceNo', isEqualTo: key).limit(1),
      db.collection('accounts').where('رقم الحساب', isEqualTo: key).limit(1),
      db.collection('accounts').where('الرقم المرجعي', isEqualTo: key).limit(1),
    ];

    for (final q in queries) {
      final r = await q.get();
      if (r.docs.isNotEmpty) return r.docs.first.reference;
    }

    return null;
  }

  static Future<void> ensureDemoAccount() async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    await ensureSignedInAnonymously();

    const accountNo = '2777277';
    const referenceNo = '0123030248210001';

    final ref = db.collection('accounts').doc(accountNo);
    final snap = await ref.get();

    final data = {
      'accountNo': accountNo,
      'identifier': accountNo,
      'referenceNo': referenceNo,
      'fullName': 'حساب تجريبي',
      'name': 'حساب تجريبي',
      'accountName': 'حساب تجريبي',
      'accountType': 'حساب توفير',
      'phone': '249000000000',
      'password': '1234',
      'status': 'active',
      'currency': 'SDG',
      'balance': 50000.0,
      'الرصيد': 50000.0,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (snap.exists) {
      await ref.set({
        'accountNo': accountNo,
        'identifier': accountNo,
        'referenceNo': referenceNo,
        'password': '1234',
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await ref.set({
        ...data,
        'id': accountNo,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
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
      AppState.appDisabled = false;
      return false;
    }
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
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    await ensureSignedInAnonymously();

    final cleanAccountNo = _digits(accountNo);
    final cleanReferenceNo = _digits(referenceNo);

    if (cleanAccountNo.isEmpty) throw Exception('invalid_account_no');
    if (cleanReferenceNo.isEmpty) throw Exception('invalid_reference_no');

    final now = FieldValue.serverTimestamp();

    await db.collection('notify_transfer_data').doc(cleanAccountNo).set({
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
    }, SetOptions(merge: true));
  }

  static Future<BankAccount?> login(String identifier, String password) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    await ensureSignedInAnonymously();

    if (ApiService.enabled) {
      final api = await ApiService.postJson('/login', {
        'identifier': identifier,
        'password': password,
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

    final acc = BankAccount.fromMap({
      ...doc.data()!,
      'docId': doc.id,
    });

    if (acc.password != password || acc.status != 'active') return null;
    return acc;
  }

  static Future<BankAccount?> getAccount(String accountNo) async {
    _ensureFirebase();
    if (!await NetworkService.isOnline) throw Exception('offline');

    await ensureSignedInAnonymously();

    final ref = await _findAccountRef(accountNo);

    if (ref != null) {
      final doc = await ref.get();
      if (doc.exists) {
        return BankAccount.fromMap({
          ...doc.data()!,
          'docId': doc.id,
        });
      }
    }

    final notify = await db.collection('notify_transfer_data').doc(_digits(accountNo)).get();

    if (notify.exists) {
      return BankAccount.fromMap({
        ...notify.data()!,
        'docId': notify.id,
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

    await ensureSignedInAnonymously();

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

    await ensureSignedInAnonymously();

    if (amount <= 0) {
      throw Exception('invalid_amount');
    }

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
          receiverName: '${r['receiverName'] ?? 'مستلم'}',
          phone: '${r['phone'] ?? phone}',
          note: '${r['note'] ?? note}',
          amount: (r['amount'] is num)
              ? (r['amount'] as num).toDouble()
              : amount,
        );
      }
    }

    final fromRef = await _findAccountRef(fromAccount);
    if (fromRef == null) {
      throw Exception('sender_not_found');
    }

    final txId = DateTime.now().millisecondsSinceEpoch.toString();
    late ReceiptData receipt;

    await db.runTransaction((transaction) async {
      final fromSnap = await transaction.get(fromRef);

      if (!fromSnap.exists) {
        throw Exception('sender_not_found');
      }

      final fromData = fromSnap.data()!;
      final current = _num(fromData['balance'] ?? fromData['الرصيد']);

      if (current < amount) {
        throw Exception('insufficient_balance');
      }

      final newBalance = current - amount;

      transaction.update(fromRef, {
        'balance': newBalance,
        'الرصيد': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      receipt = ReceiptData(
        operationNumber: txId,
        date: _fmt(DateTime.now()),
        fromAccount:
            '${fromData['referenceNo'] ?? fromData['accountNo'] ?? fromAccount}',
        toAccount: toAccount,
        receiverName: 'مستلم',
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
        'mode': 'sender_debit_only',
        'receiverCredited': false,
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
    const m = [
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

    return '${p(d.day)}-${m[d.month - 1]}-${d.year} ${p(d.hour)}:${p(d.minute)}:${p(d.second)}';
  }
}
