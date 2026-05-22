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

  // --- منطق الربط وقواعد البيانات (محفوظ كما هو) ---
  Future<void> login() async {
    if (loading) return;
    if (!AppState.firebaseReady) return toast('توقف الاتصال بالخادم');
    final account = id.text.trim();
    final password = pass.text.trim();
    if (account.isEmpty || password.isEmpty) return toast('يرجى ملء كافة البيانات');
    
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
      if (mounted) toast('تعذر الاتصال بالخادم');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, textAlign: TextAlign.center)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. الخلفية (أحمر علوي / أبيض سفلي)
            Column(
              children: [
                Expanded(flex: 55, child: Container(color: const Color(0xFFE31E24))),
                Expanded(flex: 45, child: Container(color: Colors.white)),
              ],
            ),
            
            // 2. المحتوى
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildTopHeader(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    
                    // الكروت (مطابقة دقيقة للأحجام)
                    _buildInputCard('رقم الحساب', id, 'loginmanicon.png', false),
                    const SizedBox(height: 15),
                    _buildInputCard('كلمة المرور', pass, _obscurePassword ? 'loginpiniconold.png' : 'loginpinicon.png', true),
                    
                    const SizedBox(height: 25),
                    _buildPrimaryButton('تسجيل الدخول', 'green_btn.png'),
                    const SizedBox(height: 25),
                    
                    // روابط التسجيل و الـ QR
                    _buildFooterLinks(),
                    
                    const SizedBox(height: 40),
                    _buildBottomContactRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Image.asset('assets/img/power.png', width: 32, height: 32),
      Image.asset('assets/img/bankak_logo_big.png', width: 120),
      Image.asset('assets/img/dehaze_24.png', width: 32, height: 32),
    ],
  );

  Widget _buildInputCard(String label, TextEditingController controller, String icon, bool isPass) => Container(
    height: 65,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300)),
    child: Row(
      children: [
        Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 12, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              TextField(controller: controller, obscureText: isPass && _obscurePassword, decoration: const InputDecoration(border: InputBorder.none, isDense: true)),
            ],
          ),
        )),
        GestureDetector(
          onTap: isPass ? () => setState(() => _obscurePassword = !_obscurePassword) : null,
          child: Padding(padding: const EdgeInsets.all(15), child: Image.asset('assets/img/$icon', width: 24)),
        ),
      ],
    ),
  );

  Widget _buildPrimaryButton(String text, String img) => GestureDetector(
    onTap: login,
    child: Container(
      height: 50,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/img/$img'), fit: BoxFit.fill), borderRadius: BorderRadius.circular(6)),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
    ),
  );

  Widget _buildFooterLinks() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('تسجيل جديد؟', style: TextStyle(color: Colors.grey)),
      Column(children: [
        const Text('لاتستطيع تسجيل الدخول؟', style: TextStyle(color: Colors.grey)),
        Row(children: [const Text('شارك رمز'), Image.asset('assets/img/slidscanandpay.png', width: 32)])
      ]),
    ],
  );

  Widget _buildBottomContactRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _footerItem('بنك الخرطوم', 'bok.png'),
      _footerItem('موقعنا', 'locate.png'),
      _footerItem('المساعدة', 'contact.png'),
      _footerItem('فيس بوك', 'fb.png'),
    ],
  );

  Widget _footerItem(String label, String img) => Column(children: [
    Image.asset('assets/img/$img', width: 45),
    Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))
  ]);
}
