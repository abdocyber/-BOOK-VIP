import 'package:flutter/material.dart';
// المحافظة الكاملة على خدماتك لتعمل الصفحة بدون مشاكل
import '../services/firebase_service.dart';
import '../services/session_service.dart';
import '../services/app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // الكنترولرز والمتغيرات الأصلية الخاصة بك
  final id = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  
  // متغير تفاعلي للتحكم في حالة عرض أو إخفاء كلمة المرور
  bool _obscurePassword = true;

  @override
  void dispose() {
    id.dispose();
    pass.dispose();
    super.dispose();
  }

  // دالة تسجيل الدخول المرتبطة بـ Firebase الخاصة بك دون تعديل
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
      textDirection: TextDirection.rtl, // التوجيه العربي من اليمين لليسار
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7), // لون الخلفية الرمادي الناعم المطابق تماماً
        body: LayoutBuilder(
          builder: (context, constraints) {
            final appW = constraints.maxWidth;
            final appH = constraints.maxHeight;
            final horizontalPadding = appW * 0.06;

            return Stack(
              children: [
                // 1. المساحة الحمراء العلوية لبنك الخرطوم (42% من الشاشة)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: appH * 0.42,
                  child: Container(
                    color: const Color(0xFFE31E24),
                  ),
                ),

                // 2. محتوى الواجهة الكاملة قابلة للتمرير
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        // أيقونة تغيير اللغة المرفقة أعلى اليمين
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Image.asset(
                              'assets/img/arab_lang_icon.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: appH * 0.01),

                        // الشعار الرئيسي المرفق
                        Image.asset(
                          'assets/img/bankak_logo_big.png',
                          width: appW * 0.48,
                          height: appH * 0.12,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: appH * 0.04),

                        // حقل إدخال رقم المعرف (الأيقونة يسار، النص يمين)
                        _buildNativeInputBox(
                          label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                          iconAsset: 'assets/img/loginmanicon.png',
                          child: TextField(
                            controller: id,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            textAlign: TextAlign.right, // الإدخال يبدأ من اليمين كالأصل
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

                        // حقل إدخال كلمة المرور (الأيقونة يسار، النص يمين)
                        _buildNativeInputBox(
                          label: 'ادخل كلمة المرور',
                          iconAsset: _obscurePassword ? 'assets/img/loginpinicon.png' : 'assets/img/loginpiniconold.png',
                          onIconTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: TextField(
                            controller: pass,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => login(), // الدخول السريع من الكيبورد
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

                        // زر تسجيل الدخول (استخدام الكود المجسم 3D لضمان الجودة العالية)
                        GestureDetector(
                          onTap: loading ? null : login,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [Color(0xffe53935), Color(0xffb71c1c)], // أحمر مجسم
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
                                // اللمعة الزجاجية العلوية
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 26,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8.5)),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.35),
                                          Colors.transparent,
                                        ],
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // روابط استعادة الحساب والتسجيل الجديد
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

                        const SizedBox(height: 18),

                        // أيقونة شارك رمز المرفقة
                        Align(
                          alignment: Alignment.centerRight,
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

                        // أزرار شريط التواصل السفلي الأربعة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFooterCircleButton(label: 'بنك الخرطوم', assetPath: 'assets/img/bok.png'),
                            _buildFooterCircleButton(label: 'موقعنا', assetPath: 'assets/img/locate.png'),
                            _buildFooterCircleButton(label: 'المساعدة', assetPath: 'assets/img/contact.png'),
                            _buildFooterCircleButton(label: 'فيس بوك', assetPath: 'assets/img/fb.png'),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ويدجت داخلي לבناء الحقول تم تعديله لتكون الأيقونة في اليسار (آخر الـ Row في وضع الـ RTL)
  Widget _buildNativeInputBox({
    required String label,
    required String iconAsset,
    required Widget child,
    VoidCallback? onIconTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // حشوة مريحة للعين
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // النص والحقل على اليمين
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          
          // الأيقونة الجانبية على اليسار (مطابق تماماً לתطبيق بنكك الأصلي)
          GestureDetector(
            onTap: onIconTap,
            child: Image.asset(iconAsset, width: 28, height: 28, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  // ويدجت بناء الأزرار الدائرية البيضاء أسفل الصفحة
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
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
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
