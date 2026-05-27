import 'dart:async';
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
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginLandingScreen(),
            ),
          );
        }
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
        body: Stack(
          children: [
            LayoutBuilder(
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
                            // أيقونة تغيير اللغة (chlang.png)
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                child: Image.asset(
                                  'assets/img/arab_lang_icon.png',
                                  width: s(38),
                                  height: s(38),
                                  fit: BoxFit.contain,
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

                            // حقل إدخال رقم المعرف (عكس اتجاه الأيقونة لليسار)
                            _buildNativeInputBox(
                              label: 'أدخل رقم المعرف (رقم الحساب أو 249-رقم الموبايل)',
                              iconAsset: 'assets/img/loginmanicon.png',
                              scale: scale,
                              iconOnLeft: true, // الأيقونة على اليسار
                              child: TextField(
                                controller: id,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 16, color: Color(0xFF333333), fontWeight: FontWeight.w400),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '2777277',
                                  hintStyle: TextStyle(color: Colors.black26, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // حقل إدخال كلمة المرور (عكس اتجاه الأيقونة لليسار)
                            _buildNativeInputBox(
                              label: 'ادخل كلمة المرور',
                              iconAsset: 'assets/img/loginfingview.png',
                              scale: scale,
                              iconOnLeft: true, // الأيقونة على اليسار
                              useEyeIcon: true,
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

                            // زر تسجيل الدخول
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

                            // روابط التسجيل (عكس الاتجاه)
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
                              alignment: Alignment.centerLeft,
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

                            SizedBox(height: appH * 0.1), // تحريك للأسفل

                            // أزرار شريط التواصل السفلي (استخدام الصور الأصلية)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSocialIcon('بنك الخرطوم', 'assets/img/bok.png', scale),
                                _buildSocialIcon('مواقعنا', 'assets/img/locate.png', scale),
                                _buildSocialIcon('المساعدة', 'assets/img/contact.png', scale),
                                _buildSocialIcon('فيس بوك', 'assets/img/fb.png', scale),
                              ],
                            ),
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
            if (loading)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFb80006),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/bankak_logo_big.png',
                        width: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'جاري تسجيل الدخول...',
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
          ],
        ),
      ),
    );
  }

  Widget _buildNativeInputBox({
    required String label,
    required String iconAsset,
    required double scale,
    required Widget child,
    bool iconOnLeft = false,
    bool useEyeIcon = false,
    double borderWidth = 0.45,
    VoidCallback? onIconTap,
  }) {
    double s(double v) => v * scale;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x66000000), width: borderWidth),
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
                if (!iconOnLeft) ...[
                  Image.asset(iconAsset, width: s(24), height: s(24), fit: BoxFit.contain),
                  SizedBox(width: s(10)),
                ],
                Expanded(child: child),
                if (iconOnLeft) ...[
                  SizedBox(width: s(10)),
                  GestureDetector(
                    onTap: onIconTap,
                    child: SizedBox(
                      width: s(24),
                      height: s(24),
                      child: useEyeIcon
                          ? Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF777777),
                              size: s(24),
                            )
                          : Image.asset(iconAsset, fit: BoxFit.contain),
                    ),
                  ),
                ],
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
        Image.asset(iconAsset, width: s(42), height: s(42), fit: BoxFit.contain),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: const Color(0xFF757575), fontSize: s(10), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class LoginLandingScreen extends StatefulWidget {
  const LoginLandingScreen({super.key});

  @override
  State<LoginLandingScreen> createState() => _LoginLandingScreenState();
}

class _LoginLandingScreenState extends State<LoginLandingScreen> {
  int _index = 0;
  Timer? _frameTimer;
  Timer? _goHomeTimer;

  // تم وضع الاسمين المحتملين للصور حتى لا تظهر شاشة بيضاء إذا كان اسم الملفات
  // في assets مكتوب logining بدل loggingin.
  static const List<List<String>> _frames = [
    ['assets/img/loggingin1.png', 'assets/img/logining1.png'],
    ['assets/img/loggingin2.png', 'assets/img/logining2.png'],
    ['assets/img/loggingin3.png', 'assets/img/logining3.png'],
    ['assets/img/loggingin4.png', 'assets/img/logining4.png'],
    ['assets/img/loggingin5.png', 'assets/img/logining5.png'],
    ['assets/img/loggingin6.png', 'assets/img/logining6.png'],
    ['assets/img/loggingin7.png', 'assets/img/logining7.png'],
    ['assets/img/loggingin8.png', 'assets/img/logining8.png'],
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // تحميل الصور مسبقاً بدون إجبار التطبيق على التوقف إذا كان أحد المسارات غير موجود.
    for (final frameGroup in _frames) {
      for (final frame in frameGroup) {
        precacheImage(AssetImage(frame), context).catchError((_) {});
      }
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _frameTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % _frames.length;
      });
    });

    _goHomeTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _goHomeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frames = _frames[_index];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: _LandingFrameImage(
            frames: frames,
          ),
        ),
      ),
    );
  }
}

class _LandingFrameImage extends StatelessWidget {
  final List<String> frames;
  final int index;

  const _LandingFrameImage({
    required this.frames,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (index >= frames.length) {
      return const _LandingFallback();
    }

    final frame = frames[index];

    return Image.asset(
      frame,
      key: ValueKey<String>(frame),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return _LandingFrameImage(
          frames: frames,
          index: index + 1,
        );
      },
    );
  }
}

class _LandingFallback extends StatelessWidget {
  const _LandingFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE31E24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/img/bankak_logo_big.png',
              width: 185,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text(
                'بنكك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 34),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'جاري تسجيل الدخول...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
