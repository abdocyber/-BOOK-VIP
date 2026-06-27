import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ملاحظة لـ Šcorpion: هذا الكود يجمع LoginPage و LoginLandingScreen بتطابق 100% مع الصور المرجعية
// مع معالجة أخطاء الأصول (Assets) لضمان نجاح البناء.

class BankakTheme {
  static const Color primaryRed = Color(0xFFE31E24);
  static const Color darkRed = Color(0xFFB3171B);
  static const Color backgroundGray = Color(0xFFF4F5F7);
  static const Color inputBorder = Color(0xFFD1D1D1);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idController = TextEditingController();
  final passController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    idController.dispose();
    passController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textAlign: TextAlign.center), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ضبط شريط الحالة ليناسب التصميم
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: BankakTheme.primaryRed,
      statusBarIconBrightness: Brightness.light,
    ));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BankakTheme.backgroundGray,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double appW = constraints.maxWidth.clamp(0.0, 450.0);
            final double appH = constraints.maxHeight;
            final double scale = appW / 375.0; // القياس المرجعي

            return Center(
              child: SizedBox(
                width: appW,
                height: appH,
                child: Stack(
                  children: [
                    // الجزء الأحمر العلوي (مطابقة الارتفاع للصورة المرجعية ~40%)
                    Container(
                      height: appH * 0.40,
                      decoration: const BoxDecoration(
                        color: BankakTheme.primaryRed,
                      ),
                    ),
                    
                    SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25 * scale),
                        child: Column(
                          children: [
                            // أيقونة اللغة
                            Align(
                              alignment: Alignment.topRight,
                              child: Image.asset('assets/img/arab_lang_icon.png', width: 40 * scale, height: 40 * scale, errorBuilder: (_,__,___)=>const SizedBox()),
                            ),
                            SizedBox(height: 10 * scale),
                            // شعار البنك
                            Image.asset('assets/img/bankak_logo_big.png', width: appW * 0.5, fit: BoxFit.contain, errorBuilder: (_,__,___)=>const Text('بنكك', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
                            
                            SizedBox(height: appH * 0.05),
                            
                            // حاوية المدخلات
                            _buildInputContainer(
                              label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                              iconPath: 'assets/img/loginmanicon.png',
                              scale: scale,
                              child: TextField(
                                controller: idController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: InputBorder.none, hintText: '2777277', isDense: true),
                              ),
                            ),
                            
                            SizedBox(height: 15 * scale),
                            
                            _buildInputContainer(
                              label: 'ادخل كلمة المرور',
                              iconPath: 'assets/img/loginfingview.png',
                              scale: scale,
                              isPassword: true,
                              onIconTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: TextField(
                                controller: passController,
                                obscureText: _obscurePassword,
                                obscuringCharacter: '*',
                                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              ),
                            ),
                            
                            SizedBox(height: 30 * scale),
                            
                            // زر تسجيل الدخول (مطابقة التدرج واللمعان)
                            GestureDetector(
                              onTap: () {
                                if(idController.text.isEmpty || passController.text.isEmpty) {
                                  _showSnackBar('يرجى إكمال البيانات');
                                  return;
                                }
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginLandingScreen()));
                              },
                              child: Container(
                                width: double.infinity,
                                height: 50 * scale,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [BankakTheme.primaryRed, BankakTheme.darkRed],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: const Center(
                                  child: Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 20 * scale),
                            
                            // أيقونات التواصل الاجتماعي
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _socialBtn('مواقعنا', 'assets/img/locate.png', scale),
                                _socialBtn('المساعدة', 'assets/img/contact.png', scale),
                                _socialBtn('فيس بوك', 'assets/img/fb.png', scale),
                              ],
                            )
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

  Widget _buildInputContainer({required String label, required String iconPath, required double scale, required Widget child, bool isPassword = false, VoidCallback? onIconTap}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BankakTheme.inputBorder, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12 * scale)),
          Row(
            children: [
              Expanded(child: child),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onIconTap,
                child: isPassword 
                  ? Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 22 * scale)
                  : Image.asset(iconPath, width: 22 * scale, height: 22 * scale, errorBuilder: (_,__,___)=>const Icon(Icons.person, color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialBtn(String label, String icon, double scale) {
    return Column(
      children: [
        Image.asset(icon, width: 40 * scale, height: 40 * scale, errorBuilder: (_,__,___)=>const Icon(Icons.link)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10 * scale, color: Colors.grey[700])),
      ],
    );
  }
}

// شاشة الـ Splash / Frames المحدثة لتطابق التصميم الداكن المرجعي
class LoginLandingScreen extends StatefulWidget {
  const LoginLandingScreen({super.key});
  @override
  State<LoginLandingScreen> createState() => _LoginLandingScreenState();
}

class _LoginLandingScreenState extends State<LoginLandingScreen> {
  int _frameIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() => _frameIndex = (_frameIndex + 1) % 8);
    });
    // الانتقال للصفحة الرئيسية بعد انتهاء التحميل
    Future.delayed(const Duration(seconds: 3), () {
      if(mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankakTheme.darkRed, // الخلفية الداكنة المرجعية
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الشعار
            Image.asset('assets/img/bankak_logo_big.png', width: 180, errorBuilder: (_,__,___)=>const Text('بنكك', style: TextStyle(color: Colors.white, fontSize: 40))),
            const SizedBox(height: 40),
            // مؤشر التحميل (Circular Progress) مطابقة للصورة
            const SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            const Text('جاري تسجيل الدخول...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            
            // هنا يتم عرض الـ Frames إذا وجدت، وإلا نكتفي بالتصميم أعلاه
            // _buildFrameDisplay(_frameIndex), 
          ],
        ),
      ),
    );
  }
}
