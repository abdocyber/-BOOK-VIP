import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/session_service.dart';
import '../services/firebase_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool showStatement = false;
  bool showQr = false;

  @override
  void initState() {
    super.initState();
    _refreshAccountDetails();
  }

  Future<void> _refreshAccountDetails() async {
    final accountNo = SessionService.current?.accountNo;
    if (accountNo == null || accountNo.isEmpty) return;
    try {
      final latest = await FirebaseService.getAccount(accountNo);
      if (latest != null && mounted) {
        setState(() => SessionService.current = latest);
      }
    } catch (_) {
      // إبقاء البيانات الحالية دون تغيير في حالة ضعف الاتصال.
    }
  }

  String _buildAccountNo(String identifier) {
    final base = identifier.replaceAll(RegExp(r'\D'), '');
    final clean = base.isEmpty ? '3024821' : base;
    return '0123${clean.padLeft(8, '0')}0001';
  }

  String _buildIban(String identifier) {
    final base = identifier.replaceAll(RegExp(r'\D'), '');
    final clean = base.isEmpty ? '3024821' : base;
    return 'SD6804030${clean.padLeft(8, '0')}0001';
  }

  String _formatBalance(double value) {
    final text = value.toStringAsFixed(2);

    if (text.endsWith('.00')) {
      return '${value.toStringAsFixed(0)}.0';
    }

    if (text.endsWith('0')) {
      return value.toStringAsFixed(1);
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final a = SessionService.current;
    final identifier = a?.accountNo ?? '3024821';

    final ref = (a?.referenceNo ?? '').isNotEmpty
        ? a!.referenceNo
        : _buildAccountNo(identifier);

    final iban = (a?.iban ?? '').isNotEmpty
        ? a!.iban
        : _buildIban(identifier);

    final balance = _formatBalance(a?.balance ?? 31.7); // مطابقة رصيد الشاشة الافتراضي

    final accountType = (a?.accountType ?? '').isNotEmpty
        ? a!.accountType
        : 'حساب توفير';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffececec), // الخلفية الرمادية الفاتحة والناعمة للتطبيق
        body: Center(
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth.clamp(0.0, 430.0);
              final isMobile = w <= 520;

              final shellBottom = isMobile ? 46.0 : 64.0;
              final topbarHeight = isMobile ? 58.0 : 65.0;
              final brandWidth = isMobile ? 102.0 : 120.0;

              final menuWidth = isMobile ? 32.0 : 38.0;
              final menuHeight = isMobile ? 22.0 : 26.0;
              final barWidth = isMobile ? 28.0 : 34.0;

              final titleTopPad = isMobile ? 12.0 : 16.0;
              final titleSidePad = isMobile ? 14.0 : 24.0;
              final titleSize = isMobile ? 17.5 : 22.0;

              final backTop = isMobile ? 10.0 : 12.0;
              final backRight = isMobile ? 12.0 : 14.0;
              final backW = isMobile ? 70.0 : 52.0;
              final backH = isMobile ? 40.0 : 52.0;

              final contentPadding = isMobile
                  ? const EdgeInsets.fromLTRB(14, 12, 14, 12)
                  : const EdgeInsets.fromLTRB(20, 12, 20, 18);

              return SizedBox(
                width: w,
                height: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      width: w,
                      color: const Color(0xffececec),
                      padding: EdgeInsets.only(bottom: shellBottom),
                      child: Column(
                        children: [
                          // 1. شريط التطبيق العلوي الأحمر (AppBar) بالتدرج والأيقونات الرسمية
                          Container(
                            height: topbarHeight,
                            padding: EdgeInsets.only(bottom: isMobile ? 4 : 5),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xfff50c0c),
                                  Color(0xffd71920),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Image.asset(
                                    'assets/img/white_logo_n.png',
                                    width: brandWidth,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/img/bankak_logo_big.png',
                                      width: brandWidth,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: isMobile ? 12 : 14,
                                  bottom: isMobile ? 12 : 12,
                                  child: InkWell(
                                    onTap: () => safeBack(context, '/home'),
                                    child: _MenuIcon(
                                      width: menuWidth,
                                      height: menuHeight,
                                      barWidth: barWidth,
                                      barHeight: 3,
                                      gap: isMobile ? 8 : 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. شريط تفاصيل الحساب وزر العودة (back.png) متموضع بدقة كالصورة
                          SizedBox(
                            height: isMobile ? 55 : 55,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(titleSidePad, titleTopPad, titleSidePad, 0),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'تفاصيل الحساب',
                                        style: TextStyle(
                                          color: const Color(0xff202020),
                                          fontSize: titleSize,
                                          height: 1.15,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Rubik',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: backRight,
                                  top: backTop,
                                  child: InkWell(
                                    onTap: () => safeBack(context, '/home'),
                                    child: Image.asset(
                                      'assets/img/back.png',
                                      width: backW,
                                      height: backH,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 3. كرت الحساب الرئيسي المعاد توزيع عناصره بالملي طبقاً للصورة المستلمة
                          Padding(
                            padding: contentPadding,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xffdddddd),
                                  width: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // أ) أقصى اليمين: أيقونة الحقيبة الحمراء الثابتة بالحجم المتناسق
                                        ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xffd71920),
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                            'assets/img/money_bag.png',
                                            width: 46,
                                            height: 46,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.account_balance_wallet,
                                              size: 46,
                                              color: Color(0xffd71920),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // ب) الوسط: عمود البيانات النصية الموجه بالكامل يميناً وبألوان الشاشة الرسمية
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                accountType,
                                                style: const TextStyle(
                                                  color: Color(0xffdf2c2c), // درجة اللون الأحمر لحساب التوفير
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Rubik',
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'الحساب- $ref',
                                                style: const TextStyle(
                                                  color: Color(0xff91312b), // اللون البني المحمر للبيانات
                                                  fontSize: 13.0,
                                                  fontFamily: 'Rubik',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'IBAN -$iban',
                                                style: const TextStyle(
                                                  color: Color(0xff91312b),
                                                  fontSize: 13.0,
                                                  fontFamily: 'Rubik',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ج) أقصى اليسار: دائرة "جنيه" الحمراء وتحتها الرصيد الأخضر الصافي
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Color(0xffd71920),
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'جنيه',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Rubik',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              balance,
                                              style: const TextStyle(
                                                color: Color(0xff1ca84c), // درجة اللون الأخضر الصافي للرصيد
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // الفاصل الأفقي الداخلي الدقيق للكارت
                                  Container(
                                    height: 0.8,
                                    color: const Color(0xffbcbcbc),
                                  ),

                                  // 4. خيارات الأزرار السفلية (عرض الكشف ورمز الـ QR) معدلة الترتيب والمحاذاة كالصورة تماماً
                                  SizedBox(
                                    height: 48,
                                    child: Row(
                                      children: [
                                        // زر عرض كشف الحساب (اليمين) - مصفوف النص أولاً يميناً ثم الأيقونة يساراً
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => setState(() => showStatement = true),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'عرض كشف\nالحساب',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xff252525),
                                                    fontSize: 12.5,
                                                    height: 1.1,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Rubik',
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Image.asset(
                                                  'assets/img/ic_statement.png',
                                                  width: 26,
                                                  height: 26,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) => const Icon(Icons.description, size: 26),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // الفاصل العمودي الداخلي بين الخيارين
                                        Container(
                                          width: 0.8,
                                          color: const Color(0xffc9c9c9),
                                        ),

                                        // زر رمز الدفع السريع QR (اليسار) - مصفوف النص أولاً يميناً ثم الأيقونة يساراً
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => setState(() => showQr = true),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'رمز الدفع\nالسريع QR',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xff252525),
                                                    fontSize: 12.5,
                                                    height: 1.1,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Rubik',
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Image.asset(
                                                  'assets/img/ic_qr_code.png',
                                                  width: 22,
                                                  height: 22,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 22),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 5. شريط حقوق بنك الخرطوم الملاصق تماماً للقاع السفلي للشاشة
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 38,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xffd9d9d9),
                          border: Border(
                            top: BorderSide(
                              color: Color(0xffcfcfcf),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          '© 2024 بنك الخرطوم|بنكك حساب',
                          style: TextStyle(
                            color: Color(0xff1f1f1f),
                            fontSize: 13,
                            fontFamily: 'Rubik',
                          ),
                        ),
                      ),
                    ),

                    // طبقات الـ Overlays المنبثقة الحالية الخاصة بك دون أي تعديل
                    if (showStatement)
                      _StatementOverlay(
                        accountNo: ref,
                        iban: iban,
                        balance: '$balance جنيه',
                        accountType: accountType,
                        onClose: () => setState(() => showStatement = false),
                      ),

                    if (showQr)
                      _QrOverlay(
                        text: ref,
                        onClose: () => setState(() => showQr = false),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final double width;
  final double height;
  final double barWidth;
  final double barHeight;
  final double gap;

  const _MenuIcon({
    required this.width,
    required this.height,
    required this.barWidth,
    required this.barHeight,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(right: 0, top: 0, child: _bar()),
          Positioned(right: 0, top: gap, child: _bar()),
          Positioned(right: 0, top: gap * 2, child: _bar()),
        ],
      ),
    );
  }

  Widget _bar() {
    return Container(
      width: barWidth,
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _StatementOverlay extends StatelessWidget {
  final String accountNo;
  final String iban;
  final String balance;
  final String accountType;
  final VoidCallback onClose;

  const _StatementOverlay({
    required this.accountNo,
    required this.iban,
    required this.balance,
    required this.accountType,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _OverlayBase(
      onClose: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'كشف الحساب',
            style: TextStyle(
              color: Color(0xff202020),
              fontSize: 22,
              fontFamily: 'Rubik',
            ),
          ),
          const SizedBox(height: 12),
          _stmtRow('رقم الحساب', accountNo),
          _stmtRow('IBAN', iban),
          _stmtRow('الرصيد بالجنيه', balance),
          _stmtRow('نوع الحساب', accountType),
          const SizedBox(height: 14),
          _CloseButton(onTap: onClose),
        ],
      ),
    );
  }

  Widget _stmtRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffefefef),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xff666666),
              fontSize: 17,
              fontFamily: 'Rubik',
            ),
          ),
          const Spacer(),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xff333333),
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'Rubik',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrOverlay extends StatelessWidget {
  final String text;
  final VoidCallback onClose;

  const _QrOverlay({
    required this.text,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _OverlayBase(
      onClose: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'رمز الدفع السريع QR',
            style: TextStyle(
              color: Color(0xff202020),
              fontSize: 22,
              fontFamily: 'Rubik',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: _SimpleQrPainter(text),
            ),
          ),
          const SizedBox(height: 14),
          _CloseButton(onTap: onClose),
        ],
      ),
    );
  }
}

class _OverlayBase extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const _OverlayBase({
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: InkWell(
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(.45),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {},
            child: Container(
              width: math.min(MediaQuery.of(context).size.width * .92, 480),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.28),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xffd71920),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'إغلاق',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Rubik',
          ),
        ),
      ),
    );
  }
}

class _SimpleQrPainter extends CustomPainter {
  final String text;

  const _SimpleQrPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 21;

    final bg = Paint()..color = Colors.white;
    final fg = Paint()..color = const Color(0xff111111);

    canvas.drawRect(Offset.zero & size, bg);

    void finder(int x, int y) {
      canvas.drawRect(
        Rect.fromLTWH(x * cell, y * cell, 7 * cell, 7 * cell),
        fg,
      );

      canvas.drawRect(
        Rect.fromLTWH((x + 1) * cell, (y + 1) * cell, 5 * cell, 5 * cell),
        bg,
      );

      canvas.drawRect(
        Rect.fromLTWH((x + 2) * cell, (y + 2) * cell, 3 * cell, 3 * cell),
        fg,
      );
    }

    finder(0, 0);
    finder(14, 0);
    finder(0, 14);

    var seed = text.codeUnits.fold<int>(0, (a, c) => a + c);
    seed = seed == 0 ? 12345 : seed;

    for (var i = 0; i < 21; i++) {
      for (var j = 0; j < 21; j++) {
        if ((i < 7 && j < 7) ||
            (i < 7 && j >= 14) ||
            (i >= 14 && j < 7)) {
          continue;
        }

        seed = (seed * 1664525 + 1013904223) & 0xffffffff;

        if (seed % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              j * cell,
              i * cell,
              cell,
              cell,
            ),
            fg,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleQrPainter oldDelegate) {
    return oldDelegate.text != text;
  }
}