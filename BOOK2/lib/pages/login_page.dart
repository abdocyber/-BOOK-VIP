import 'package:flutter/material.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl, // التوجيه الصحيح
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7), // لون الخلفية الرمادي الفاتح
        body: LayoutBuilder(
          builder: (context, constraints) {
            final appW = constraints.maxWidth.clamp(0.0, 430.0);
            final appH = constraints.maxHeight;
            final scale = (appW / 360.0).clamp(0.8, 1.2);
            double s(double value) => value * scale;

            return Center(
              child: SizedBox(
                width: appW,
                height: appH,
                child: Stack(
                  children: [
                    // المساحة الحمراء العلوية (نفس لون الصورة المرجعية)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: appH * 0.42,
                      child: Container(
                        color: const Color(0xFFE31E24),
                      ),
                    ),

                    // محتوى الواجهة
                    SafeArea(
                      bottom: false,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(horizontal: s(24)),
                        child: Column(
                          children: [
                            // أيقونة تغيير اللغة أعلى اليمين
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(top: s(10)),
                                child: Image.asset(
                                  'assets/img/arab_lang_icon.png',
                                  width: s(32),
                                  height: s(32),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: appH * 0.015),

                            // الشعار الرئيسي المرفق
                            Image.asset(
                              'assets/img/bankak_logo_big.png',
                              width: s(180),
                              height: s(80),
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: appH * 0.04),

                            // حقل إدخال رقم المعرف
                            _buildNativeInputBox(
                              label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                              iconAsset: 'assets/img/loginmanicon.png',
                              scale: scale,
                              child: TextField(
                                controller: id,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.right, // الإدخال لليمين
                                style: TextStyle(fontSize: s(16), color: const Color(0xFF888888), fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '2777277',
                                  hintStyle: TextStyle(color: Colors.black26),
                                ),
                              ),
                            ),

                            SizedBox(height: s(14)),

                            // حقل إدخال كلمة المرور
                            _buildNativeInputBox(
                              label: 'ادخل كلمة المرور',
                              iconAsset: _obscurePassword ? 'assets/img/loginpinicon.png' : 'assets/img/loginpiniconold.png',
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
                                style: TextStyle(fontSize: s(18), color: const Color(0xFF888888), letterSpacing: 4.0),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            SizedBox(height: s(24)),

                            // زر تسجيل الدخول باستخدام صورتك button.9.png الأصلية
                            GestureDetector(
                              onTap: loading ? null : login,
                              child: Container(
                                width: double.infinity,
                                height: s(50),
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/img/button.9.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Center(
                                  child: loading
                                      ? SizedBox(
                                          height: s(20),
                                          width: s(20),
                                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                        )
                                      : Text(
                                          'تسجيل الدخول',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: s(18),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            SizedBox(height: s(22)),

                            // الروابط بترتيب الصورة الجديدة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'لا تستطيع تسجيل الدخول؟',
                                    style: TextStyle(color: const Color(0xFF666666), fontSize: s(13.5), fontWeight: FontWeight.w500),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'تسجيل جديد؟',
                                    style: TextStyle(color: const Color(0xFF666666), fontSize: s(13.5), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: s(20)),

                            // أيقونة شارك رمز
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/img/slidscanandpay.png',
                                    width: s(46),
                                    height: s(46),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: s(4)),
                                  Text(
                                    'شارك رمز',
                                    style: TextStyle(color: const Color(0xFF666666), fontSize: s(12)),
                                  )
                                ],
                              ),
                            ),

                            SizedBox(height: appH * 0.05),

                            // أزرار شريط التواصل السفلي بنفس الترتيب في الصورة الجديدة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFooterCircleButton(label: 'بنك الخرطوم', assetPath: 'assets/img/bok.png', scale: scale),
                                _buildFooterCircleButton(label: 'موقعنا', assetPath: 'assets/img/locate.png', scale: scale),
                                _buildFooterCircleButton(label: 'المساعدة', assetPath: 'assets/img/contact.png', scale: scale),
                                _buildFooterCircleButton(label: 'فيس بوك', assetPath: 'assets/img/fb.png', scale: scale),
                              ],
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

  // الحقول البيضاء، الأيقونة يساراً والنصوص يميناً بدقة
  Widget _buildNativeInputBox({
    required String label,
    required String iconAsset,
    required Widget child,
    required double scale,
    VoidCallback? onIconTap,
  }) {
    double s(double value) => value * scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(color: const Color(0xFF999999), fontSize: s(11.5), fontWeight: FontWeight.w400),
                ),
                SizedBox(height: s(2)),
                child,
              ],
            ),
          ),
          SizedBox(width: s(12)),
          GestureDetector(
            onTap: onIconTap,
            child: Image.asset(iconAsset, width: s(28), height: s(28), fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  // الأزرار السفلية
  Widget _buildFooterCircleButton({required String label, required String assetPath, required double scale}) {
    double s(double value) => value * scale;
    return Column(
      children: [
        Container(
          width: s(54),
          height: s(54),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(s(1.0)),
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(height: s(6)),
        Text(
          label,
          style: TextStyle(color: const Color(0xFF666666), fontSize: s(12.5), fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
