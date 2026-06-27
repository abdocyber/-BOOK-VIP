import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/network_service.dart';
import 'services/app_state.dart';
import 'services/permissions_service.dart';
import 'services/firebase_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/account_page.dart';
import 'pages/transfer_page.dart';
import 'pages/transfer_bank_page.dart';
import 'pages/sendto_page.dart';
import 'pages/success_page.dart';
import 'pages/error_page.dart';
import 'pages/transactions_page.dart';
import 'pages/white_receipt_page.dart';
import 'pages/notify_page.dart';
import 'pages/qr_scanner_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحسين ذاكرة الصور لمنع الـ Lag
  PaintingBinding.instance.imageCache.maximumSize = 150;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20;

  // تثبيت الاتجاه الرأسي
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ضبط ألوان النظام لتطابق هوية بنكك
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFE31E24), // أحمر بنكك
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));

    // تسجيل دخول مجهول للوصول إلى Firestore
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInAnonymously();

    await FirebaseService.ensureSignedInAnonymously();
    AppState.firebaseReady = true;
    
    try {
      await FirebaseService.ensureDemoAccount();
    } catch (_) {}
  } catch (e) {
    AppState.firebaseReady = false;
    AppState.firebaseError = e.toString();
  }

  // طلب الأذونات في الخلفية
  unawaited(PermissionsService.requestAppPermissions());

  runApp(const BankakApp());
}

class BankakApp extends StatelessWidget {
  const BankakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بنكك',
      // دعم اللغة العربية والاتجاه من اليمين لليسار
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false, // لترك التحكم لشريط الحالة المخصص
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      // ثيم بنكك المخصص بنسبة 100%
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Rubik', // استخدام الخط المطلوب
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE31E24),
          primary: const Color(0xFFE31E24),
          secondary: const Color(0xFFB3171B),
          surface: const Color(0xFFF4F5F7), // لون الخلفية المرجعي
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE31E24),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // تخصيص حركات الانتقال لتكون سلسة
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoLagPageTransitionsBuilder(),
            TargetPlatform.iOS: _NoLagPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/',
      onUnknownRoute: (settings) => MaterialPageRoute(builder: (_) => const ComingSoonPage()),
      routes: {
        '/': (_) => const AppBootstrap(),
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/notify': (_) => const NotifyPage(),
        '/account': (_) => const AccountPage(),
        '/transfer': (_) => const TransferPage(),
        '/transfer_bank': (_) => const TransferBankPage(),
        '/sendto': (_) => const SendToPage(),
        '/success': (_) => const SuccessPage(),
        '/error': (_) => const ErrorPage(),
        '/transactions': (_) => const TransactionsPage(),
        '/white': (_) => const WhiteReceiptPage(),
        '/offline': (_) => const OfflinePage(),
        '/app_disabled': (_) => const AppDisabledPage(),
        '/qr_scanner': (_) => const QrScannerPage(),
      },
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _start();
  }

  Future<void> _start() async {
    final online = await NetworkService.isOnline;
    if (!mounted) return;

    if (!online || !AppState.firebaseReady) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final disabled = await FirebaseService.refreshAppConfig();
    if (!mounted) return;
    
    if (disabled) {
      Navigator.pushReplacementNamed(context, '/app_disabled');
      return;
    }

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFE31E24)),
      ),
    );
  }
}

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'يجب توفر اتصال بيانات لتشغيل التطبيق',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NoLagPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoLagPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class AppDisabledPage extends StatelessWidget {
  const AppDisabledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppState.appDisabledMessage,
            style: const TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنبيه')),
      body: const Center(
        child: Text(
          'هذه الصفحة غير مفعلة حاليًا',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
