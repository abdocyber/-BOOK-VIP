import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';
import '../services/session_service.dart';
import '../services/app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final id = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    id.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (loading) return;

    if (!AppState.firebaseReady) {
      return toast('توقف الاتصال بالخادم، لا يمكن تسجيل الدخول الآن');
    }

    final account = id.text.trim();
    final password = pass.text.trim();

    if (account.isEmpty) return toast('يرجى إدخال رقم المعرف');
    if (password.isEmpty) return toast('يرجى إدخال كلمة المرور');

    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    try {
      final acc = await FirebaseService.login(account, password);
      if (!mounted) return;

      if (acc == null) {
        pass.clear();
        toast('بيانات الدخول غير صحيحة');
      } else {
        await SessionService.save(acc);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (_) {
      if (mounted) toast('تعذر الاتصال بالخادم، ابقَ في صفحة تسجيل الدخول');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFE31E24),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final appW = constraints.maxWidth.clamp(0.0, 430.0);
            final appH = constraints.maxHeight;
            final scale = appW / 360.0;
            double s(double value) => value * scale;

            return Center(
              child: SizedBox(
                width: appW,
                height: appH,
                child: Stack(
                  children: [
                    // المساحة الحمراء العلوية مع التدرج
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: appH * 0.45,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFE31E24),
                              Color(0xFFB71C1C),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // محتوى الواجهة الكاملة
                    SafeArea(
                      bottom: false,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          children: [
                            // 1. أيقونة اللغة ع/A في أعلى اليمين
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(top: s(10), left: s(15)),
                                child: Image.asset(
                                  'assets/img/chlang.png',
                                  width: s(38),
                                  height: s(38),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: s(38),
                                    height: s(38),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text('A\nع', 
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: s(15)),

                            // 2. الشعار الرئيسي
                            Image.asset(
                              'assets/img/bankak_logo_big.png',
                              width: appW * 0.55,
                              height: s(110),
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: s(35)),

                            // 3. حقل إدخال رقم المعرف
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: s(25)),
                              child: _buildInputBox(
                                label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                                icon: 'assets/img/loginmanicon.png',
                                scale: scale,
                                child: TextField(
                                  controller: id,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: s(18), color: const Color(0xFF333333), fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '3024821',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: s(18)),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: s(12)),

                            // 4. حقل إدخال كلمة المرور
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: s(25)),
                              child: _buildInputBox(
                                label: 'ادخل كلمة المرور',
                                icon: _obscurePassword ? 'assets/img/loginfingview.png' : 'assets/img/loginfingview.png',
                                scale: scale,
                                onIconTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: TextField(
                                  controller: pass,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => login(),
                                  obscureText: _obscurePassword,
                                  obscuringCharacter: '*',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: s(20), color: const Color(0xFF333333), letterSpacing: s(2)),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '*********',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: s(20), letterSpacing: s(2)),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: s(25)),

                            // 5. زر تسجيل الدخول (استخدام الصورة)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: s(25)),
                              child: GestureDetector(
                                onTap: loading ? null : login,
                                child: Image.asset(
                                  'assets/img/button.png',
                                  width: double.infinity,
                                  height: s(55),
                                  fit: BoxFit.fill,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: double.infinity,
                                    height: s(55),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFE31E24), Color(0xFFB71C1C)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: s(25)),

                            // 6. روابط التسجيل (عكس الاتجاه لتطابق الصورة)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: s(25)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'تسجيل جديد؟',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: s(15), fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'لاتستطيع تسجيل الدخول؟',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: s(15), fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: s(20)),

                            // 7. شارك رمز
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: s(25)),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/img/slidscanandpay.png',
                                    width: s(35),
                                    height: s(35),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: s(10)),
                                  Text(
                                    'شارك رمز',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: s(14)),
                                  )
                                ],
                              ),
                            ),

                            SizedBox(height: appH * 0.15),

                            // 8. أزرار التواصل السفلي
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: s(20)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFooterButton(scale, 'assets/img/newbokirada.png', 'بنك الخرطوم'),
                                  _buildFooterButton(scale, 'assets/img/newmishwar.png', 'مواقعنا'),
                                  _buildFooterButton(scale, 'assets/img/newcanar.png', 'المساعدة'),
                                  _buildFooterButton(scale, 'assets/img/linkedin.png', 'فيس بوك'),
                                ],
                              ),
                            ),
                            SizedBox(height: s(20)),
                          ],
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
    );
  }

  Widget _buildInputBox({
    required String label,
    required String icon,
    required double scale,
    required Widget child,
    VoidCallback? onIconTap,
  }) {
    double s(double value) => value * scale;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(8)),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: s(8), right: s(50)),
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: s(12)),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(8)),
                child: GestureDetector(
                  onTap: onIconTap,
                  child: Image.asset(
                    icon,
                    width: s(28),
                    height: s(28),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: s(15)),
                  child: child,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(double scale, String asset, String label) {
    double s(double value) => value * scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          asset,
          width: s(45),
          height: s(45),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: s(45),
            height: s(45),
            decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          ),
        ),
        SizedBox(height: s(5)),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: s(11)),
        ),
      ],
    );
  }
}
