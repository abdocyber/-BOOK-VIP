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
  }) async {
    final dynamic r = receipt;

    final operationNumber = '${_pickReceiptValue([
          () => r.operationNumber,
          () => r.id,
          () => r.transactionId,
        ]) ?? DateTime.now().millisecondsSinceEpoch}';

    final createdAt = '${_pickReceiptValue([
          () => r.createdAt,
          () => r.date,
        ]) ?? DateTime.now().toIso8601String()}';

    final receiverName =
        (receiver?.fullName.trim().isNotEmpty ?? false)
            ? receiver!.fullName.trim()
            : 'مستلم';

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
          'receiverName': receiverName,
          'accountName': receiverName,
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

final fullFromAccount =
    (current?.accountNo.trim().isNotEmpty ?? false)
        ? current!.accountNo.trim()
        : '';

final fullToAccount =
    (receiver?.accountNo.trim().isNotEmpty ?? false)
        ? receiver!.accountNo.trim()
        : to;

final fullReceiverName =
    (receiver?.fullName.trim().isNotEmpty ?? false)
        ? receiver!.fullName.trim()
        : 'مستلم';

    if (fullFromAccount.isEmpty) {
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/error',
        arguments: {
          'message': 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى',
          'retryRoute': '/login',
        },
      );
      return;
    }

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
      );

      if (!mounted) return;

      final dynamic r = receipt;

      final operationNumber = '${_pickReceiptValue([
            () => r.operationNumber,
            () => r.id,
            () => r.transactionId,
          ]) ?? DateTime.now().millisecondsSinceEpoch}';

      final createdAt = '${_pickReceiptValue([
            () => r.createdAt,
            () => r.date,
          ]) ?? DateTime.now().toIso8601String()}';

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/success',
        (route) => false,
        arguments: {
          'operationNumber': operationNumber,
          'id': operationNumber,
          'transactionId': operationNumber,
          'createdAt': createdAt,
          'date': createdAt,
          'amount': a,
          'from': fromAccount,
          'accountFrom': fromAccount,
          'fromAccount': fromAccount,
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
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/home'),
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
                              fontSize: 22,
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
                      fontSize: 22,
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
                              vertical: 22,
                              horizontal: 25,
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
                                _info('رقم الحساب', receiver?.referenceNo ?? to),
                                _info('الاسم', receiver?.fullName ?? 'مستلم'),
                                _info(
                                  'نوع الحساب',
                                  receiver?.accountType ?? 'حساب توفير',
                                ),
                                _info('الفرع', 'الباقير'),
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
                                  initial:
                                      SessionService.current?.referenceNo ??
                                      SessionService.current?.accountNo ??
                                      '',
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
                          const SizedBox(height: 52),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 52),
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
            fontSize: 20,
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
              fontSize: 16,
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
                height: 34,
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
                            fontSize: 15,
                            color: Color(0xff777777),
                          ),
                        ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          initial ?? '',
                          style: const TextStyle(
                            fontSize: 22,
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
                        fontSize: 22,
                        color: Color(0xff777777),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 18),
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
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
