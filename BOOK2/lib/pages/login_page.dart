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

    final disabled = await FirebaseService.refreshAppConfig();
    if (!mounted) return;
    if (disabled) {
      Navigator.pushReplacementNamed(context, '/app_disabled');
      return;
    }

    final account = id.text.trim();
    final password = pass.text.trim();

    if (account.isEmpty) return toast('يرجى إدخال رقم الحساب');
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
    final screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width * 0.07;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // لون الخلفية الرمادي الناعم المطابق تماماً للنصف السفلي
        body: Stack(
          children: [
            // 1. المساحة الحمراء العلوية لبنك الخرطوم
            Container(
              height: screenSize.height * 0.43,
              color: const Color(0xFFE31E24),
            ),

            // 2. محتوى الواجهة الكاملة قابلة للتمرير لحماية التصميم عند فتح الكيبورد
            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    // أيقونة تغيير اللغة المرفقة (arab_lang_icon.png) أعلى اليمين
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.asset(
                          'assets/img/arab_lang_icon.png',
                          width: 35,
                          height: 35,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenSize.height * 0.01),

                    // الشعار الرئيسي المرفق (bankak_logo_big.png)
                    Image.asset(
                      'assets/img/bankak_logo_big.png',
                      width: screenSize.width * 0.52,
                      height: screenSize.height * 0.16,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: screenSize.height * 0.05),

                    // حقل إدخال رقم المعرف / رقم الحساب
                    _buildNativeInputBox(
                      label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                      iconAsset: 'assets/img/loginmanicon.png',
                      child: TextField(
                        controller: id,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left, // إدخال الأرقام يبدأ من اليسار كالأصل
                        style: const TextStyle(fontSize: 17, color: Color(0xFF333333), fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '2777277',
                          hintStyle: TextStyle(color: Colors.black26, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // حقل إدخال كلمة المرور مع تبديل تفاعلي لأيقونات العين المرفقة
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
                        obscureText: _obscurePassword,
                        obscuringCharacter: '*',
                        textAlign: TextAlign.center, // تظهر النجوم في المنتصف تماماً مطابقة للشكل الأصلي
                        style: const TextStyle(fontSize: 18, color: Color(0xFF333333), letterSpacing: 3.0),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر تسجيل الدخول باستخدام خلفية button.9.png الأصلية اللامعة
                    GestureDetector(
                      onTap: loading ? null : login,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/button.9.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Center(
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // روابط استعادة الحساب والتسجيل الجديد بنفس التموضع والأبعاد
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'لا تستطيع تسجيل الدخول؟',
                            style: TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'تسجيل جديد؟',
                            style: TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // أيقونة شارك رمز المرفقة (slidscanandpay.png)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/img/slidscanandpay.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'شارك رمز',
                            style: TextStyle(color: Colors.black45, fontSize: 12),
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.08),

                    // أزرار شريط التواصل السفلي الأربعة المرفقة كاملة ومطابقة 100%
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFooterCircleButton(label: 'بنك الخرطوم', assetPath: 'assets/img/bok.png'),
                        _buildFooterCircleButton(label: 'موقعنا', assetPath: 'assets/img/locate.png'),
                        _buildFooterCircleButton(label: 'المساعدة', assetPath: 'assets/img/contact.png'),
                        _buildFooterCircleButton(label: 'فيس بوك', assetPath: 'assets/img/fb.png'),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت داخلي لبناء الحقول البيضاء بشكل مرن ومنظم ومطابق للأبعاد والأيقونات الجانبية
  Widget _buildNativeInputBox({
    required String label,
    required String iconAsset,
    required Widget child,
    VoidCallback? onIconTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // الأيقونة الجانبية التفاعلية أو الثابتة
          GestureDetector(
            onTap: onIconTap,
            child: Image.asset(iconAsset, width: 28, height: 28, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          
          // نصوص وتلميحات الحقل الداخلي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت بناء الأزرار الدائرية البيضاء أسفل الصفحة بالأيقونات المرفقة كاملة ومطابقة للـ Shadow والأبعاد
  Widget _buildFooterCircleButton({required String label, required String assetPath}) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 3,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(1.5), // إطار أبيض جمالي خفيف حول الأيقونات المرفقة الدائرية
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}