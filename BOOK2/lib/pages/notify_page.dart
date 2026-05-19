import 'package:flutter/material.dart';
import '../main.dart';
import '../services/firebase_service.dart';
import '../services/session_service.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage({super.key});

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  final accountNo = TextEditingController();
  final referenceNo = TextEditingController();
  final fullName = TextEditingController();
  final branch = TextEditingController(text: 'الخرطوم');
  final balance = TextEditingController(text: '0');
  final password = TextEditingController(text: '1234');

  String accountType = 'حساب توفير';
  bool saving = false;

  @override
  void dispose() {
    accountNo.dispose();
    referenceNo.dispose();
    fullName.dispose();
    branch.dispose();
    balance.dispose();
super.dispose();
  }

  String buildReferenceNo(String acc) {
    final clean = acc.replaceAll(RegExp(r'\D'), '');
    return '0123${clean.padLeft(8, '0')}0001'.substring(0, 16);
  }

  Future<void> submitForm() async {
    final acc = accountNo.text.replaceAll(RegExp(r'\D'), '');
    final refRaw = referenceNo.text.replaceAll(RegExp(r'\D'), '');
    final name = fullName.text.trim();

    if (acc.isEmpty) {
      return toast('يرجى إدخال رقم الحساب');
    }

    if (name.isEmpty) {
      return toast('يرجى إدخال إسم صاحب الحساب');
    }

    final ref = refRaw.isEmpty
        ? buildReferenceNo(acc)
        : refRaw.substring(0, refRaw.length > 16 ? 16 : refRaw.length);

    setState(() => saving = true);

    try {
      await FirebaseService.saveNotifyTransferData(
        accountNo: acc,
        referenceNo: ref,
        fullName: name,
        accountType: accountType,
        branch: branch.text.trim().isEmpty ? 'الخرطوم' : branch.text.trim(),
        balance: 0.isEmpty ? '1234' : password.text.trim(),
      );

      if (!mounted) return;

      toast('تم حفظ بيانات التحويل بنجاح');

      accountNo.clear();
      referenceNo.clear();
      fullName.clear();
      branch.text = 'الخرطوم';
setState(() {
        accountType = 'حساب توفير';
      });
    } catch (_) {
      if (mounted) {
        toast('تعذر حفظ الحساب في قاعدة البيانات');
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> logoutApp() async {
    await SessionService.logout();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffededed),
        body: Center(
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth.clamp(0.0, 430.0);

              return SizedBox(
                width: w,
                child: Container(
                  color: const Color(0xfff4f4f4),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xffef1017),
                              Color(0xffbc0d12),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/img/scanpayheader.png',
                                height: 58,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 17,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                                },
                                child: Image.asset(
                                  'assets/img/dehaze_24.png',
                                  width: 30,
                                  color: Colors.white,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              top: 17,
                              child: InkWell(
                                onTap: logoutApp,
                                child: Image.asset(
                                  'assets/img/logout_icon.png',
                                  width: 27,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 56,
                        child: Stack(
                          children: [
                            Positioned(
                              right: 10,
                              top: 5,
                              child: InkWell(
                                onTap: () => safeBack(context, '/home'),
                                child: Image.asset(
                                  'assets/img/back.png',
                                  width: 75,
                                  height: 38,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(60, 15, 60, 10),
                                child: Text(
                                  'إضافة بيانات حساب',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xff111111),
                                    fontSize: 21,
                                    fontFamily: 'Rubik',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xffdddddd),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.08),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('رقم الحساب'),
                                _input(
                                  controller: accountNo,
                                  hint: 'مثال: 2777277',
                                  keyboardType: TextInputType.number,
                                  maxLength: 16,
                                ),

                                _label('الرقم المرجعي'),
                                _input(
                                  controller: referenceNo,
                                  hint: '16 رقم',
                                  keyboardType: TextInputType.number,
                                  maxLength: 16,
                                ),

                                _label('إسم صاحب الحساب'),
                                _input(
                                  controller: fullName,
                                  hint: 'اسم المستلم',
                                  keyboardType: TextInputType.text,
                                ),

                                _label('نوع الحساب'),
                                Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: fieldDecoration(),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: accountType,
                                      isExpanded: true,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Rubik',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'حساب توفير',
                                          child: Text('حساب توفير'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'توفير مميز',
                                          child: Text('توفير مميز'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'حساب جاري',
                                          child: Text('حساب جاري'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        setState(() {
                                          accountType = v ?? 'حساب توفير';
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                _label('الفرع'),
                                _input(
                                  controller: branch,
                                  hint: 'الخرطوم',
                                  keyboardType: TextInputType.text,
                                ),
const SizedBox(height: 16),

                                InkWell(
                                  onTap: saving ? null : submitForm,
                                  child: Container(
                                    width: double.infinity,
                                    height: 46,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffef1017),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: saving
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'حفظ في قاعدة البيانات',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontFamily: 'Rubik',
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'بعد الحفظ يتم تخزين بيانات التحويل فقط. الحسابات المضافة هنا تستخدم كمستلمين للتحويل فقط ولا يتم تسجيلها كحسابات دخول داخل التطبيق.',
                                  style: TextStyle(
                                    color: Color(0xff777777),
                                    fontSize: 12,
                                    height: 1.5,
                                    fontFamily: 'Rubik',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff333333),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Rubik',
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    int? maxLength,
  }) {
    return Container(
      height: 44,
      decoration: fieldDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Rubik',
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xff777777),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  BoxDecoration fieldDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color(0xffcccccc),
      ),
      borderRadius: BorderRadius.circular(7),
    );
  }
}