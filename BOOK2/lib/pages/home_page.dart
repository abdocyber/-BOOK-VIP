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

  // منطق تسجيل الدخول محفوظ كما هو لضمان عمل قاعدة البيانات
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
                    // المساحة الحمراء العلوية
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: appH * 0.42,
                      child: Container(
                        color: const Color(0xFFE31E24),
                      ),
                    ),

                    // محتوى الواجهة الكاملة
                    SafeArea(
                      bottom: false,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(horizontal: s(24)),
                        child: Column(
                          children: [
                            // 1. تحريك أيقونة تغيير اللغة للأسفل
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(top: s(35), right: s(5)),
                                child: Image.asset(
                                  'assets/img/arab_lang_icon.png',
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
                            
                            SizedBox(height: appH * 0.01),

                            // الشعار الرئيسي
                            Image.asset(
                              'assets/img/bankak_logo_big.png',
                              width: appW * 0.48,
                              height: appH * 0.12,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: appH * 0.04),

                            // حقل إدخال رقم المعرف (تم نقل الأيقونة لليسار)
                            _buildNativeInputBox(
                              label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                              iconAsset: 'assets/img/loginmanicon.png',
                              scale: scale,
                              child: TextField(
                                controller: id,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 16, color: Color(0xFF333333), fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '3024821',
                                  hintStyle: TextStyle(color: Colors.black26, fontSize: 16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // حقل إدخال كلمة المرور (تم نقل الأيقونة لليسار)
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
                                style: const TextStyle(fontSize: 18, color: Color(0xFF333333), letterSpacing: 3.0),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            const SizedBox(height: 26),

                            // زر تسجيل الدخول (button.png)
                            GestureDetector(
                              onTap: loading ? null : login,
                              child: Container(
                                width: double.infinity,
                                height: s(55),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('assets/img/button.png'),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                        )
                                      : const Text(
                                          'تسجيل الدخول',
                                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 2. عكس اتجاه الروابط (تسجيل جديد يمين ، لا تستطيع تسجيل الدخول يسار)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'تسجيل جديد؟',
                                    style: TextStyle(color: Color(0xFF757575), fontSize: 13.5, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'لا تستطيع تسجيل الدخول؟',
                                    style: TextStyle(color: Color(0xFF757575), fontSize: 13.5, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // أيقونة شارك رمز
                            Align(
                              alignment: Alignment.centerLeft, // تم محاذاتها بناءً على التنسيق المطلوب
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/img/slidscanandpay.png',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'شارك رمز',
                                    style: TextStyle(color: Color(0xFF757575), fontSize: 12),
                                  )
                                ],
                              ),
                            ),

                            SizedBox(height: appH * 0.05),

                            // 3. أزرار شريط التواصل السفلي تم إضافتها وضبطها
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSocialIcon('فيس بوك', 'assets/img/logfacebookicon.png', scale),
                                _buildSocialIcon('المساعدة', 'assets/img/logcallcentericon.png', scale),
                                _buildSocialIcon('مواقعنا', 'assets/img/loglocationicon.png', scale),
                                _buildSocialIcon('بنك الخرطوم', 'assets/img/logbokicon.png', scale),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
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

  // 4. تم عكس ترتيب العناصر داخل هذا الـ Widget لتكون الأيقونة على اليسار والنص على اليمين
  Widget _buildNativeInputBox({
    required String label,
    required String iconAsset,
    required double scale,
    required Widget child,
    VoidCallback? onIconTap,
  }) {
    double s(double v) => v * scale;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: s(8), right: s(12)),
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: s(11), fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: s(8), left: s(12), right: s(12)),
            child: Row(
              children: [
                Expanded(child: child), // حقل الإدخال أصبح على اليمين (في بيئة RTL)
                SizedBox(width: s(10)),
                GestureDetector(
                  onTap: onIconTap,
                  child: Image.asset(iconAsset, width: s(24), height: s(24), fit: BoxFit.contain),
                ), // الأيقونة أصبحت على اليسار
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String label, String iconAsset, double scale) {
    double s(double v) => v * scale;
    return Column(
      children: [
        Container(
          width: s(42),
          height: s(42),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Image.asset(iconAsset, width: s(42), height: s(42), fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: const Color(0xFF757575), fontSize: s(10), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
