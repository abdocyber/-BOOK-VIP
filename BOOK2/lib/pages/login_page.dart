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

  // منطق الربط وقاعدة البيانات محفوظ كما هو
  Future<void> login() async {
    if (loading) return;

    if (!AppState.firebaseReady) {
      return toast('توقف الاتصال بالخادم');
    }

    final account = id.text.trim();
    final password = pass.text.trim();

    if (account.isEmpty || password.isEmpty) {
      return toast('يرجى ملء كافة البيانات');
    }

    setState(() => loading = true);

    try {
      final acc = await FirebaseService.login(account, password);

      if (!mounted) return;

      if (acc == null) {
        pass.clear();
        toast('بيانات الدخول غير صحيحة');
      } else {
        await SessionService.save(acc);

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (_) {
      if (mounted) {
        toast('تعذر الاتصال بالخادم');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.36,
                  child: Container(
                    color: const Color(0xffed1c24),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xfff4f4f4),
                  ),
                ),
              ],
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    _buildTopHeader(),

                    const SizedBox(height: 84),

                    _buildInputCard(
                      label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                      controller: id,
                      icon: 'loginmanicon.png',
                      isPass: false,
                      example: '3024821',
                    ),

                    const SizedBox(height: 20),

                    _buildInputCard(
                      label: 'ادخل كلمة المرور',
                      controller: pass,
                      icon: _obscurePassword
                          ? 'loginpiniconold.png'
                          : 'loginpinicon.png',
                      isPass: true,
                      example: '',
                    ),

                    const SizedBox(height: 28),

                    _buildPrimaryButton(),

                    const SizedBox(height: 34),

                    _buildFooterLinks(),

                    const SizedBox(height: 56),

                    _buildBottomContactRow(),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            if (loading)
              Container(
                color: Colors.black.withOpacity(0.12),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xffed1c24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return SizedBox(
      height: 126,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: -6,
            child: Image.asset(
              'assets/img/power.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),

          Center(
            child: Image.asset(
              'assets/img/bankak_logo_big.png',
              width: 176,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/img/white_logo_n.png',
                width: 150,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          Positioned(
            top: 2,
            left: -4,
            child: Image.asset(
              'assets/img/dehaze_24.png',
              width: 43,
              height: 43,
              color: Colors.white,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.menu,
                color: Colors.white,
                size: 43,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String icon,
    required bool isPass,
    required String example,
  }) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xffb9b9b9),
          width: 1.0,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 8,
                top: 8,
                bottom: 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff8f8f8f),
                      fontSize: 14.5,
                      height: 1.05,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      obscureText: isPass && _obscurePassword,
                      keyboardType: isPass
                          ? TextInputType.visiblePassword
                          : TextInputType.number,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(top: 2),
                        hintText: isPass ? '**********' : example,
                        hintTextDirection: TextDirection.ltr,
                        hintStyle: const TextStyle(
                          color: Color(0xff4f4f4f),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: isPass
                ? () => setState(() => _obscurePassword = !_obscurePassword)
                : null,
            child: SizedBox(
              width: 74,
              height: double.infinity,
              child: Center(
                child: Image.asset(
                  'assets/img/$icon',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    isPass
                        ? (_obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined)
                        : Icons.person_outline,
                    color: const Color(0xff5c5c5c),
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return GestureDetector(
      onTap: login,
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/img/green_btn.png',
              width: double.infinity,
              height: 56,
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffffa3a3),
                      Color(0xffef2b2b),
                      Color(0xffe11212),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xffb82020),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),

            const Text(
              'تسجيل الدخول',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w400,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'تسجيل جديد؟',
          style: TextStyle(
            color: Color(0xff777777),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'لاتستطيع تسجيل الدخول؟',
              style: TextStyle(
                color: Color(0xff777777),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 18),

            Image.asset(
              'assets/img/slidscanandpay.png',
              width: 58,
              height: 58,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.qr_code_2,
                color: Color(0xffed1c24),
                size: 58,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'شارك رمز',
              style: TextStyle(
                color: Color(0xff777777),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomContactRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _footerItem('بنك الخرطوم', 'bok.png'),
        _footerItem('موقعنا', 'locate.png'),
        _footerItem('المساعدة', 'contact.png'),
        _footerItem('فيس بوك', 'fb.png'),
      ],
    );
  }

  Widget _footerItem(String label, String img) {
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            'assets/img/$img',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.circle,
              color: Color(0xff777777),
              size: 40,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff777777),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
