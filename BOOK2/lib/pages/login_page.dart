import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // للتحكم في المدخلات وإظهار/إخفاء كلمة المرور
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // الثوابت البكسلية الدقيقة للمطابقة مع الصورة
  static const double inputCardHeight = 42.0; // تصغير ارتفاع الكرت بدقة
  static const double borderRadiusValue = 6.0;
  static const double labelFontSize = 14.5;
  static const double inputFontSize = 15.0;

  // ارتفاع ثابت للمنطقة الحمراء لمنع تشوه التصميم عند ظهور الكيبورد
  static const double redBannerHeight = 340.0;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تحديد الاتجاه من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white, // الجزء السفلي أبيض نقي
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. المنطقة العلوية (الأحمر + الكروت المتداخلة)
              Stack(
                clipBehavior: Clip.none, // هام جداً للسماح للكروت بالخروج عن حدود الـ Stack
                children: [
                  // الخلفية الحمراء المتدرجة
                  Container(
                    height: redBannerHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xffe31e24), // أحمر فاتح علوي
                          Color(0xffc62828), // أحمر داكن سفلي
                        ],
                      ),
                    ),
                  ),

                  // شريط الأدوات العلوي (الشعار والأيقونات)
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // أيقونة القائمة (يمين)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              'assets/img/dehaze_24.png',
                              width: 32, height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.menu, color: Colors.white, size: 32),
                            ),
                          ),
                          // الشعار (المنتصف)
                          Image.asset(
                            'assets/img/white_logo_n.png', // أو bankak_logo.png
                            width: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, color: Colors.white, size: 40),
                          ),
                          // أيقونة الخروج (يسار)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/img/power.png',
                              width: 32, height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.power_settings_new, color: Colors.white, size: 32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // كروت الإدخال (رقم الحساب وكلمة المرور)
                  // بوضع bottom: -21، سينزل كرت كلمة المرور (والذي ارتفاعه 42)
                  // أسفل الخط الأحمر بمقدار النصف (21px)، مما يحقق نقطة المنتصف تماماً!
                  Positioned(
                    bottom: -(inputCardHeight / 2),
                    left: 18.0,
                    right: 18.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // حقل رقم الحساب
                        _buildInputCard(
                          labelText: 'رقم الحساب',
                          controller: _accountController,
                          iconPath: 'assets/img/ic_account_circle_grey.png',
                          fallbackIcon: Icons.person_outline,
                          keyboardType: TextInputType.number,
                        ),
                        
                        const SizedBox(height: 18), // تباعد دقيق

                        // حقل كلمة المرور (هذا الحقل سيقع منتصفه على الحد الفاصل)
                        _buildInputCard(
                          labelText: 'كلمة المرور',
                          controller: _passwordController,
                          iconPath: 'assets/img/ic_lock_grey.png',
                          fallbackIcon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          toggleVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 2. المنطقة السفلية (الأزرار البيضاء)
              // إضافة مسافة لتعويض خروج الكروت عن الـ Stack (21px) + مسافة جمالية (40px)
              const SizedBox(height: (inputCardHeight / 2) + 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  children: [
                    // زر تسجيل الدخول الأخضر
                    _buildPrimaryButton(
                      text: 'تسجيل الدخول',
                      imagePath: 'assets/img/green_btn.png',
                      onTap: () {
                        // منطق تسجيل الدخول هنا (ربط مع قاعدة البيانات)
                      },
                    ),

                    const SizedBox(height: 24),

                    // الأزرار الثانوية (هل نسيت - تصفح) الحمراء
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryButton(
                            text: 'هل نسيت ؟',
                            imagePath: 'assets/img/red_btn.png',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildSecondaryButton(
                            text: 'تصفح بنكك',
                            imagePath: 'assets/img/red_btn.png',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40), // مسافة سفلية نهائية
            ],
          ),
        ),
      ),
    );
  }

  // بناء كروت الإدخال مع التسمية الخارجية والارتفاع المضغوط
  Widget _buildInputCard({
    required String labelText,
    required TextEditingController controller,
    required String iconPath,
    required IconData fallbackIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // نص التسمية (رقم الحساب / كلمة المرور)
        Padding(
          padding: const EdgeInsets.only(right: 6.0, bottom: 6.0),
          child: Text(
            labelText,
            style: const TextStyle(
              color: Color(0xfff5f5f5), // لون التسميات في المنطقة الحمراء أبيض مائل للرمادي
              fontSize: labelFontSize,
              fontWeight: FontWeight.w500,
              fontFamily: 'Cairo', // أو Rubik
            ),
          ),
        ),
        
        // الكرت الأبيض المضغوط (42px)
        Container(
          height: inputCardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffdcdcdc), width: 1.2),
            borderRadius: BorderRadius.circular(borderRadiusValue),
            // ظل خفيف جداً يبرز الكرت
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              // أيقونة الحقل الملونة بالرمادي
              Image.asset(
                iconPath,
                width: 22, height: 22,
                color: const Color(0xff757575),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: const Color(0xff757575), size: 22),
              ),
              const SizedBox(width: 10),
              
              // الحقل النصي
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: isPassword && !isPasswordVisible,
                  // إجبار الأرقام لتكون من اليسار لليمين لسهولة القراءة
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xff444444), // رمادي داكن للنص المدخل
                    fontSize: inputFontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10), // لضبط تمركز النص داخل الكرت المضغوط
                  ),
                ),
              ),
              
              // أيقونة إظهار/إخفاء كلمة المرور (إن وجدت)
              if (isPassword)
                InkWell(
                  onTap: toggleVisibility,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Image.asset(
                      'assets/img/ic_visibility_grey.png', // استخدم أيقونتك هنا
                      width: 22, height: 22,
                      color: const Color(0xff757575),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xff757575), size: 22),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // بناء زر تسجيل الدخول الأخضر الرئيسي
  Widget _buildPrimaryButton({required String text, required String imagePath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: Container(
        height: 50, // ارتفاع الزر الرئيسي
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // دمج لون خلفية احتياطي في حال عدم تحميل الصورة
          color: const Color(0xff368e1c), 
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  // بناء الأزرار الثانوية الحمراء
  Widget _buildSecondaryButton({required String text, required String imagePath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: Container(
        height: 48,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xffd33234), // لون خلفية احتياطي
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
      ),
    );
  }
}
