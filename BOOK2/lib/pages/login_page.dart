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
                    // المساحة الحمراء العلوية
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: appH * 0.42, // Adjusted based on visual estimation
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
                            // أيقونة تغيير اللغة أعلى اليمين
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0, left: 10.0), // Adjusted padding
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8), // Slightly rounded corners
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'A ع',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14, // Adjusted font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: appH * 0.01), // Fine-tuned spacing

                            // الشعار الرئيسي
                            Image.asset(
                              'assets/img/bankak_logo_big.png', // Placeholder, ensure this path is correct
                              width: appW * 0.48,
                              height: appH * 0.12,
                              fit: BoxFit.contain,
                            ),

                            SizedBox(height: appH * 0.04), // Fine-tuned spacing

                            // حقل إدخال رقم المعرف
                            _buildNativeInputBox(
                              label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                              iconAsset: 'assets/img/loginmanicon.png', // Placeholder
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

                            const SizedBox(height: 14), // Fine-tuned spacing

                            // حقل إدخال كلمة المرور
                            _buildNativeInputBox(
                              label: 'ادخل كلمة المرور',
                              iconAsset: _obscurePassword ? 'assets/img/loginpinicon.png' : 'assets/img/loginpiniconold.png', // Placeholder
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
                                style: const TextStyle(fontSize: 18, color: Color(0xFF333333), letterSpacing: 3.0), // Adjusted letter spacing for '*' to match image
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            const SizedBox(height: 26), // Fine-tuned spacing

                            // زر تسجيل الدخول
                            GestureDetector(
                              onTap: loading ? null : login,
                              child: Container(
                                width: double.infinity,
                                height: s(52),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xffe53935), Color(0xffb71c1c)], // Exact colors from image analysis
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  border: Border.all(color: const Color(0xff8e0000), width: 1.2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: s(26), // Half the button height for gloss effect
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8.5)), // Slightly less than button radius
                                          gradient: LinearGradient(
                                            colors: [Colors.white.withOpacity(0.35), Colors.transparent], // Gloss effect
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                          )
                                        : const Text(
                                            'تسجيل الدخول',
                                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 22), // Fine-tuned spacing

                            // روابط التسجيل
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'لا تستطيع تسجيل الدخول؟',
                                    style: TextStyle(color: Color(0xFF757575), fontSize: 13.5, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'تسجيل جديد؟',
                                    style: TextStyle(color: Color(0xFF757575), fontSize: 13.5, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18), // Fine-tuned spacing

                            // أيقونة شارك رمز
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center, // Centered for QR code and text
                                children: [
                                  Image.asset(
                                    'assets/img/slidscanandpay.png', // Placeholder
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

                            SizedBox(height: appH * 0.05), // Fine-tuned spacing

                            // أزرار شريط التواصل السفلي
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFooterCircleButton(label: 'بنك الخرطوم', assetPath: 'assets/img/bok.png'), // Placeholder
                                _buildFooterCircleButton(label: 'موقعنا', assetPath: 'assets/img/locate.png'), // Placeholder
                                _buildFooterCircleButton(label: 'المساعدة', assetPath: 'assets/img/contact.png'), // Placeholder
                                _buildFooterCircleButton(label: 'فيس بوك', assetPath: 'assets/img/fb.png'), // Placeholder
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

  Widget _buildNativeInputBox({
    required String label,
    required String iconAsset,
    required Widget child,
    required double scale,
    VoidCallback? onIconTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align label to start
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onIconTap,
            child: Image.asset(iconAsset, width: 28, height: 28, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCircleButton({required String label, required String assetPath}) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF616161), fontSize: 12.5, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
