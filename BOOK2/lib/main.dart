import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PaintingBinding.instance.imageCache.maximumSize = 120;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 80 << 20;

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xffef1017),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 8));
    await FirebaseService.ensureSignedInAnonymously();
    AppState.firebaseReady = true;
    try {
      await FirebaseService.ensureDemoAccount();
    } catch (_) {
      // الحساب التجريبي لا يجب أن يمنع تشغيل التطبيق إذا كانت الصلاحيات لا تسمح بالإنشاء.
    }
  } catch (e) {
    AppState.firebaseReady = false;
    AppState.firebaseError = e.toString();
  }

  // لا ننتظر الأذونات قبل عرض الواجهة حتى لا تتأخر صفحة تسجيل الدخول.
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
      theme: ThemeData(
        fontFamily: 'Rubik',
        useMaterial3: false,
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: Colors.white,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoLagPageTransitionsBuilder(),
            TargetPlatform.iOS: _NoLagPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/',
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

    // التطبيق online فقط؛ لكن عند انقطاع السيرفر نبقي المستخدم في صفحة الدخول برسالة مناسبة.
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
    return const Scaffold(backgroundColor: Colors.white);
  }
}

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'يجب توفر اتصال بيانات لتشغيل التطبيق',
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
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

void safeBack(BuildContext context, String fallbackRoute) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushReplacementNamed(context, fallbackRoute);
  }
}


class AppDisabledPage extends StatelessWidget {
  const AppDisabledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
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
      ),
    );
  }
}
