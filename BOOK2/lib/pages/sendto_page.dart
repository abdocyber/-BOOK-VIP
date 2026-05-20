import 'package:flutter/material.dart';
import '../main.dart';
import '../services/firebase_service.dart';
import '../services/session_service.dart';
import '../models/account.dart';
import '../models/receipt.dart';

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
  bool isSubmitting = false; // متغير جديد للتحكم في زر التأكيد
  String to = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (to.isEmpty) {
      to = '${ModalRoute.of(context)?.settings.arguments ?? ''}';
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
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  // --- الدالة المحدثة للتعامل مع الرصيد وحالة التحميل ---
  Future<void> submit() async {
    final a = double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
    if (a <= 0) return toast('يرجى إدخال المبلغ');
    
    setState(() => isSubmitting = true); // تفعيل التحميل عند الضغط

    try {
      final from = SessionService.current?.accountNo ?? '';
      
      final ReceiptData r = await FirebaseService.transfer(
        fromAccount: from,
        toAccount: to,
        amount: a,
        note: note.text.trim().isEmpty ? 'N/A' : note.text.trim(),
        phone: phone.text.trim().isEmpty ? 'N/A' : phone.text.trim(),
      );
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/success', arguments: r);
      
    } catch (e) {
      if (!mounted) return;
      setState(() => isSubmitting = false); // إيقاف التحميل
      
      // فحص نوع الخطأ الوارد من قاعدة البيانات
      if (e.toString().contains('insufficient_balance')) {
        toast('عفواً، الرصيد غير كافي لإتمام التحويل');
      } else {
        toast('تعذر تنفيذ التحويل، يرجى المحاولة لاحقاً');
        // Navigator.pushReplacementNamed(context, '/error');
      }
    }
  }

  void toast(String s) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Rubik'))),
      );

  @override
  Widget build(BuildContext context) => Directionality(
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
                            colors: [Color(0xffff0b0b), Color(0xffc91c22)])),
                    child: Stack(children: [
                      Center(child: Image.asset('assets/img/bankak_logo_big.png', width: 135)),
                      Positioned(
                          right: 18,
                          bottom: 18,
                          child: IconButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                              icon: const Icon(Icons.menu, color: Colors.white, size: 36)))
                    ]),
                  ),
                  SizedBox(
                    height: 72,
                    child: Stack(children: [
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.only(right: 48),
                              child: Text('تحويل لحسابات بنك الخرطوم',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)))),
                      Positioned(
                          right: 15,
                          top: 13,
                          child: InkWell(
                              onTap: () => safeBack(context, '/transfer_bank'),
                              child: Image.asset('assets/img/back.png', width: 75, height: 40)))
                    ]),
                  ),
                  Container(
                      height: 58,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xffff0505), Color(0xffc5122a)])),
                      child: const Text('دفع مباشر',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                  if (loading)
                    const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.red)))
                  else
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(children: [
                      Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 25),
                          height: 235,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xff9d9d9d)),
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                            _info('رقم الحساب', receiver?.referenceNo ?? to),
                            _info('الاسم', receiver?.fullName ?? 'مستلم تجريبي'), // لتفادي ظهور 'غير مسجل'
                            _info('نوع الحساب', receiver?.accountType ?? 'حساب توفير'),
                            _info('الفرع', 'الباقير'),
                          ])),
                      const SizedBox(height: 22),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xff999999)),
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(children: [
                            _inputRow('dropdownarr.png', null, initial: '0123030248210001', label: 'اختر الحساب'),
                            _line(),
                            _inputRow('newmobile.png', phone, label: '249 - رقم الهاتف للرسالة النصية'),
                            _line(),
                            _inputRow('money.png', amount, hint: 'أدخل المبلغ', keyboard: TextInputType.number),
                            _line(),
                            _inputRow('comment.png', note, hint: 'ملاحظات'),
                          ])),
                      const SizedBox(height: 52),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 52),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            _redButton('إلغاء', () => safeBack(context, '/transfer_bank'), false),
                            _redButton('تأكيد', isSubmitting ? null : submit, isSubmitting),
                          ])),
                      const SizedBox(height: 30),
                    ]))),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _info(String label, String value) => Row(children: [
        SizedBox(
            width: 98,
            child: Text(label,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Color(0xff666666), fontSize: 17, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        const Text(':', style: TextStyle(fontSize: 20, color: Color(0xff666666), fontWeight: FontWeight.bold)),
        Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Color(0xff666666), fontSize: 16, fontWeight: FontWeight.bold)))
      ]);

  Widget _line() => Container(height: 1, color: const Color(0xffb6b6b6));

  Widget _inputRow(String icon, TextEditingController? controller,
          {String? hint, String? label, String? initial, TextInputType keyboard = TextInputType.text}) =>
      SizedBox(
          height: 70,
          child: Row(children: [
            SizedBox(
                width: 70,
                child: Center(
                    child: Image.asset('assets/img/$icon',
                        width: 34, height: 34, errorBuilder: (_, __, ___) => const Icon(Icons.edit)))),
            Expanded(
                child: controller == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            if (label != null) Text(label, style: const TextStyle(fontSize: 15, color: Color(0xff777777))),
                            Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(initial ?? '',
                                    style: const TextStyle(
                                        fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff555555))))
                          ])
                    : TextField(
                        controller: controller,
                        keyboardType: keyboard,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: hint ?? label,
                            hintTextDirection: TextDirection.rtl,
                            hintStyle: const TextStyle(fontSize: 22, color: Color(0xff777777))))),
            const SizedBox(width: 18)
          ]));

  // تعديل زر التأكيد ليظهر مؤشر تحميل
  Widget _redButton(String text, VoidCallback? tap, bool isLoading) => InkWell(
      onTap: tap,
      child: Stack(alignment: Alignment.center, children: [
        Image.asset('assets/img/button.png', width: 120, height: 55, fit: BoxFit.fill),
        isLoading 
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold))
      ]));
}
