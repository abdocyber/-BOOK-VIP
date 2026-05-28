import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
import '../models/account.dart';
import '../models/receipt.dart';
import '../services/firebase_service.dart';
import '../services/session_service.dart';

class SendToPage extends StatefulWidget {
  const SendToPage({super.key});

  @override
  State<SendToPage> createState() => _SendToPageState();
}

class _SendToPageState extends State<SendToPage> {
  final amount = TextEditingController();
  final note = TextEditingController();
  final phone = TextEditingController(text: '249');

  BankAccount? receiver;
  bool loading = true;
  String to = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (to.isEmpty) {
      to = '${ModalRoute.of(context)?.settings.arguments ?? ''}'.trim();
      load();
    }
  }

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      receiver = await FirebaseService.getAccount(to);
    } catch (e) {
      debugPrint('SENDTO LOAD ERROR: $e');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  // ====== توليد رقم العملية بتنسيق 2001978xxxx ======
  String _generateOperationNumber() {
    final random = Random();
    final last4 = random.nextInt(9000) + 1000; // 1000-9999
    return '2001978$last4';
  }

  // ====== تنسيق رقم الحساب لـ 16 رقم مع فراغات ======
  String _formatAccount16(String account) {
    final digitsOnly = account.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length >= 16) {
      final acc16 = digitsOnly.substring(0, 16);
      return acc16.replaceAllMapped(
        RegExp(r'.{4}'),
        (match) => '${match.group(0)} ',
      ).trim();
    }

    // إكمال بأصفار إذا أقل من 16
    final padded = digitsOnly.padLeft(16, '0');
    return padded.replaceAllMapped(
      RegExp(r'.{4}'),
      (match) => '${match.group(0)} ',
    ).trim();
  }

  // ====== توليد رقم الحساب المرسل بتنسيق 0123 XXXX XXXX XXXX ======
  String _generateSenderAccount16(String accountNo, String referenceNo) {
    // أولاً: نحاول استخدام accountNo إذا كان 16 رقم
    String digitsOnly = accountNo.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length >= 16) {
      // إذا كان يبدأ بـ 0123 نستخدمه مباشرة
      if (digitsOnly.startsWith('0123')) {
        return digitsOnly.substring(0, 16);
      }
      // إذا لم يبدأ بـ 0123، نستبدل البداية
      return '0123' + digitsOnly.substring(4, 16);
    }

    // إذا كان أقل من 16 رقم، نستخدم referenceNo
    String refDigits = referenceNo.replaceAll(RegExp(r'[^0-9]'), '');

    // نولد: 0123 + referenceNo مكمل بأصفار حتى 16
    String base = refDigits.padLeft(12, '0'); // 12 رقم بعد 0123
    if (base.length > 12) {
      base = base.substring(base.length - 12); // آخر 12 رقم
    }

    return '0123' + base;
  }

  // ====== جلب رقم الحساب المستلم الكامل 16 رقم من Firebase ======
  Future<String> _getReceiverAccount16(String referenceOrShort) async {
    final cleanRef = referenceOrShort.replaceAll(RegExp(r'[^0-9]'), '');

    // إذا كان بالفعل 16 رقم ويبدأ بـ 0123
    if (cleanRef.length >= 16 && cleanRef.startsWith('0123')) {
      return cleanRef.substring(0, 16);
    }

    try {
      // البحث في Firebase بالرقم المرجعي
      final doc = await FirebaseFirestore.instance
          .collection('accounts')
          .where('referenceNo', isEqualTo: cleanRef)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        final data = doc.docs.first.data();
        final accountNo = data['accountNo']?.toString() ?? '';
        final digitsOnly = accountNo.replaceAll(RegExp(r'[^0-9]'), '');

        if (digitsOnly.length >= 16) {
          if (digitsOnly.startsWith('0123')) {
            return digitsOnly.substring(0, 16);
          }
          return '0123' + digitsOnly.substring(4, 16);
        }

        // إذا كان accountNo قصير، نولد منه
        final refNo = data['referenceNo']?.toString() ?? cleanRef;
        return _generateSenderAccount16(accountNo, refNo);
      }

      // البحث بحقل accountNo إذا كان يحتوي الرقم
      final doc2 = await FirebaseFirestore.instance
          .collection('accounts')
          .where('accountNo', isGreaterThanOrEqualTo: cleanRef)
          .where('accountNo', isLessThan: cleanRef + 'z')
          .limit(1)
          .get();

      if (doc2.docs.isNotEmpty) {
        final data = doc2.docs.first.data();
        final accountNo = data['accountNo']?.toString() ?? '';
        final refNo = data['referenceNo']?.toString() ?? cleanRef;
        return _generateSenderAccount16(accountNo, refNo);
      }
    } catch (e) {
      debugPrint('Error fetching receiver account 16: $e');
    }

    // fallback: توليد من الرقم المُرسل
    return _generateSenderAccount16('', cleanRef);
  }

  Object? _pickReceiptValue(List<Object? Function()> getters) {
    for (final getter in getters) {
      try {
        final value = getter();
        if (value != null && '$value'.trim().isNotEmpty) return value;
      } catch (_) {}
    }
    return null;
  }

  Future<void> _saveTransferIconReceipt({
    required ReceiptData receipt,
    required String fromAccount,
    required String toAccount,
    required double transferAmount,
    required String noteText,
    required String phoneText,
    required String receiverName,
  }) async {
    final dynamic r = receipt;

    // ====== توليد رقم العملية بتنسيق 2001978xxxx ======
    final operationNumber = _generateOperationNumber();

    final createdAt = '${_pickReceiptValue([
          () => r.createdAt,
          () => r.date,
        ]) ?? DateTime.now().toIso8601String()}';

    final cleanReceiverName = receiverName.trim().isEmpty ? 'مستلم' : receiverName.trim();
    final cleanNote = noteText.trim().isEmpty ? 'N/A' : noteText.trim();
    final cleanPhone = phoneText.trim().isEmpty ? 'N/A' : phoneText.trim();

    await FirebaseFirestore.instance
        .collection('transfericon')
        .doc(operationNumber)
        .set({
          'operationNumber': operationNumber,
          'id': operationNumber,
          'transactionId': operationNumber,
          'createdAt': createdAt,
          'date': createdAt,
          'createdAtServer': FieldValue.serverTimestamp(),
          'amount': transferAmount,
          'from': fromAccount,
          'accountFrom': fromAccount,
          'fromAccount': fromAccount,
          'to': toAccount,
          'accountTo': toAccount,
          'toAccount': toAccount,
          'receiverName': cleanReceiverName,
          'accountName': cleanReceiverName,
          'phone': cleanPhone,
          'mobile': cleanPhone,
          'note': cleanNote,
          'comment': cleanNote,
          'status': 'success',
          'operationType': 'تحويل إلى حساب آخر',
          'title': 'تحويل إلى حساب آخر',
          'type': 'transfer',
        }, SetOptions(merge: true));
  }

  Future<void> submit() async {
    final rawAmount = amount.text.trim().replaceAll(',', '');
    final a = double.tryParse(rawAmount) ?? 0;

    if (a <= 0) {
      toast('يرجى إدخال المبلغ');
      return;
    }

    final current = SessionService.current;

    // ====== توليد 16 رقم للحساب المرسل (يبدأ بـ 0123) ======
    String fullFromAccount = '';
    if (current != null) {
      fullFromAccount = _generateSenderAccount16(
        current.accountNo ?? '',
        current.referenceNo ?? '',
      );
    }

    // ====== جلب 16 رقم للحساب المستلم من Firebase ======
    String fullToAccount = '';
    if (receiver != null) {
      fullToAccount = _generateSenderAccount16(
        receiver!.accountNo ?? '',
        receiver!.referenceNo ?? to,
      );
    } else {
      fullToAccount = await _getReceiverAccount16(to);
    }

    final fullReceiverName =
        (receiver?.fullName.trim().isNotEmpty ?? false) ? receiver!.fullName.trim() : 'مستلم';

    // ====== التحقق النهائي ======
    if (fullFromAccount.length != 16 || !fullFromAccount.startsWith('0123')) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/error',
        arguments: {
          'message': 'رقم حساب المرسل غير صحيح (يجب 16 رقم يبدأ بـ 0123)',
          'retryRoute': '/login',
        },
      );
      return;
    }

    if (fullToAccount.length != 16 || !fullToAccount.startsWith('0123')) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/error',
        arguments: {
          'message': 'رقم حساب المستلم غير صحيح (يجب 16 رقم يبدأ بـ 0123)',
          'retryRoute': '/sendto',
          'to': to,
        },
      );
      return;
    }

    // ====== طباعة للتأكد ======
    debugPrint('=== ✅ ACCOUNTS 16 DIGITS VERIFIED ===');
    debugPrint('From Account (16): $fullFromAccount');
    debugPrint('From Formatted: ${_formatAccount16(fullFromAccount)}');
    debugPrint('To Account (16): $fullToAccount');
    debugPrint('To Formatted: ${_formatAccount16(fullToAccount)}');
    debugPrint('=====================================');

    try {
      final noteText = note.text.trim().isEmpty ? 'N/A' : note.text.trim();
      final phoneText = phone.text.trim().isEmpty ? 'N/A' : phone.text.trim();

      final ReceiptData receipt = await FirebaseService.transfer(
        fromAccount: fullFromAccount,
        toAccount: fullToAccount,
        amount: a,
        note: noteText,
        phone: phoneText,
      );

      await _saveTransferIconReceipt(
        receipt: receipt,
        fromAccount: fullFromAccount,
        toAccount: fullToAccount,
        transferAmount: a,
        noteText: noteText,
        phoneText: phoneText,
        receiverName: fullReceiverName,
      );

      if (!mounted) return;

      final dynamic r = receipt;

      // ====== توليد رقم العملية بتنسيق 2001978xxxx ======
      final operationNumber = _generateOperationNumber();

      final createdAt = '${_pickReceiptValue([
            () => r.createdAt,
            () => r.date,
          ]) ?? DateTime.now().toIso8601String()}';

      Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (_) => ConfirmLandingScreen(
      nextRoute: '/success',
      nextArguments: {
        'operationNumber': operationNumber,
        'id': operationNumber,
        'transactionId': operationNumber,
        'createdAt': createdAt,
        'date': createdAt,
        'amount': a,
        'from': fullFromAccount,
        'accountFrom': fullFromAccount,
        'fromAccount': fullFromAccount,
        'to': fullToAccount,
        'accountTo': fullToAccount,
        'toAccount': fullToAccount,
        'receiverName': fullReceiverName,
        'accountName': fullReceiverName,
        'phone': phoneText,
        'mobile': phoneText,
        'note': noteText,
        'comment': noteText,
        'status': 'success',
        'operationType': 'تحويل إلى حساب آخر',
        'title': 'تحويل إلى حساب آخر',
      },
    ),
  ),
  (route) => false,
);
      return;
    } catch (e) {
      if (!mounted) return;

      final err = e.toString();

      String message = 'تعذر تنفيذ التحويل';

      if (err.contains('invalid_amount')) {
        message = 'المبلغ غير صحيح';
      } else if (err.contains('insufficient_balance')) {
        message = 'لايوجد رصيد كافي لإجراء المعاملة';
      } else if (err.contains('sender_not_found')) {
        message = 'حساب المرسل غير موجود أو غير مربوط بشكل صحيح';
      } else if (err.contains('permission-denied')) {
        message = 'صلاحيات قاعدة البيانات تمنع تنفيذ التحويل';
      } else if (err.contains('offline')) {
        message = 'تأكد من الاتصال بالإنترنت';
      } else {
        message = 'خطأ التحويل: $err';
      }

      Navigator.pushReplacementNamed(
        context,
        '/error',
        arguments: {
          'message': message,
          'rawError': err,
          'retryRoute': '/sendto',
          'to': to,
        },
      );
      return;
    }
  }

  void toast(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s, textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            color: const Color(0xfff2f2f2),
            child: Column(
              children: [
                Container(
                  height: 88,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xffff0b0b),
                        Color(0xffc91c22),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/img/bankak_logo_big.png',
                          width: 135,
                        ),
                      ),
                      Positioned(
                        right: 18,
                        bottom: 18,
                        child: IconButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 72,
                  child: Stack(
                    children: [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 48),
                          child: Text(
                            'تحويل لحسابات بنك الخرطوم',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 13,
                        child: InkWell(
                          onTap: () => safeBack(context, '/transfer_bank'),
                          child: Image.asset(
                            'assets/img/back.png',
                            width: 75,
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 58,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xffff0505),
                        Color(0xffc5122a),
                      ],
                    ),
                  ),
                  child: const Text(
                    'دفع مباشر',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (loading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 14,
                            ),
                            height: 235,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xff9d9d9d),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // ====== عرض 16 رقم مُنسق ======
                                _info('رقم الحساب', _formatAccount16(
                                  _generateSenderAccount16(
                                    receiver?.accountNo ?? '',
                                    receiver?.referenceNo ?? to,
                                  )
                                )),
                                _info('الاسم', receiver?.fullName ?? 'مستلم'),
                                _info(
                                  'نوع الحساب',
                                  receiver?.accountType ?? 'حساب توفير',
                                ),
                                _info('الفرع', receiver?.branch ?? 'الخرطوم'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xff999999),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                _inputRow(
                                  'dropdownarr.png',
                                  null,
                                  initial: _formatAccount16(
                                    _generateSenderAccount16(
                                      SessionService.current?.accountNo ?? '',
                                      SessionService.current?.referenceNo ?? '',
                                    )
                                  ),
                                  label: 'اختر الحساب',
                                ),
                                _line(),
                                _inputRow(
                                  'newmobile.png',
                                  phone,
                                  label: '249 - رقم الهاتف للرسالة النصية',
                                ),
                                _line(),
                                _inputRow(
                                  'money.png',
                                  amount,
                                  hint: 'أدخل المبلغ',
                                  keyboard: TextInputType.number,
                                ),
                                _line(),
                                _inputRow(
                                  'comment.png',
                                  note,
                                  hint: 'ملاحظات',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _redButton('تأكيد', submit),
                                _redButton(
                                  'إلغاء',
                                  () => safeBack(context, '/transfer_bank'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 98,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xff666666),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          ':',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xff666666),
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xff666666),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _line() => Container(height: 1, color: const Color(0xffb6b6b6));

  Widget _inputRow(
    String icon,
    TextEditingController? controller, {
    String? hint,
    String? label,
    String? initial,
    TextInputType keyboard = TextInputType.text,
  }) {
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Center(
              child: Image.asset(
                'assets/img/$icon',
                width: 34,
                height: 32,
                errorBuilder: (_, __, ___) => const Icon(Icons.edit),
              ),
            ),
          ),
          Expanded(
            child: controller == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (label != null)
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff777777),
                          ),
                        ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          initial ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff555555),
                          ),
                        ),
                      ),
                    ],
                  )
                : TextField(
                    controller: controller,
                    keyboardType: keyboard,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint ?? label,
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: const TextStyle(
                        fontSize: 20,
                        color: Color(0xff777777),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _redButton(String text, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/img/button.png',
            width: 120,
            height: 55,
            fit: BoxFit.fill,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
class ConfirmLandingScreen extends StatefulWidget {
  final String nextRoute;
  final Object? nextArguments;

  const ConfirmLandingScreen({
    super.key,
    required this.nextRoute,
    this.nextArguments,
  });

  @override
  State<ConfirmLandingScreen> createState() => _ConfirmLandingScreenState();
}

class _ConfirmLandingScreenState extends State<ConfirmLandingScreen> {
  int _index = 0;
  Timer? _frameTimer;
  Timer? _goNextTimer;

  // أسماء صور التحميل الصحيحة داخل assets/img ويتم عرضها بهذا الترتيب.
  static const List<String> _frames = [
    'assets/img/loading.png',
    'assets/img/loading1.png',
    'assets/img/loading2.png',
    'assets/img/loading3.png',
    'assets/img/loading4.png',
    'assets/img/loading5.png',
    'assets/img/loading6.png',
    'assets/img/loading7.png',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // تحميل الصور مسبقاً حتى لا تظهر صفحة بيضاء أثناء تبديل الفريمات.
    for (final frame in _frames) {
      precacheImage(AssetImage(frame), context);
    }
  }

  @override
  void initState() {
    super.initState();

    _frameTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % _frames.length;
      });
    });

    _goNextTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        widget.nextRoute,
        (route) => false,
        arguments: widget.nextArguments,
      );
    });
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _goNextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frames[_index];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Image.asset(
            frame,
            key: ValueKey<String>(frame),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('CONFIRM LANDING IMAGE ERROR: $frame => $error');
              return Center(
                child: Text(
                  'تعذر تحميل الصورة: $frame',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE31E24),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
