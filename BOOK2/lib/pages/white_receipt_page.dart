import 'package:flutter/material.dart';

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  bool showToast = false;

  // استقبال البيانات الحقيقية من الـ Firebase والخدمات الممررة عبر الـ Arguments دون مساس
  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '15-May-2026 08:09:23';

    final text = '$v';
    final parsed = DateTime.tryParse(text);

    if (parsed == null) return text;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    String p(int n) => n.toString().padLeft(2, '0');

    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} '
        '${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
  }

  String _fmtMoney(dynamic v) {
    final n = v is num
        ? v.toDouble()
        : double.tryParse('$v'.replaceAll(',', '')) ?? 40000.00;

    return n.toStringAsFixed(2);
  }

  String _statusAr(dynamic v) {
    return '$v' == 'success' || '$v'.isEmpty ? 'نجاح' : '$v';
  }

  void _showSoon() {
    setState(() => showToast = true);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => showToast = false);
      }
    });
  }

  void _shareTx(Map<String, dynamic> d) {
    final id = '${d['operationNumber'] ?? d['id'] ?? '20019502790'}';
    final amount = _fmtMoney(d['amount'] ?? 40000.00);
    final to = '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0033 0443 6676 0001'}';

    final text = 'تفاصيل المعاملة\nرقم العملية: $id\nالمبلغ: $amount\nإلى: $to';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _data(context);

    // الـ 9 صفوف المطابقة للصورة تماماً بدون زيادة أو نقصان
    final rows = <_ReceiptRow>[
      _ReceiptRow(
        'رقم العملية',
        '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? '20019502790'}',
      ),
      _ReceiptRow(
        'التاريخ والوقت',
        _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-05-15T08:09:23'),
      ),
      _ReceiptRow(
        'نوع العملية',
        '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب آخر'}',
        arabicValue: true,
      ),
      _ReceiptRow(
        'المبلغ',
        _fmtMoney(d['amount'] ?? 40000.00),
      ),
      _ReceiptRow(
        'من',
        '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '0123 0302 4821 0001'}',
      ),
      _ReceiptRow(
        'إلى',
        '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0033 0443 6676 0001'}',
      ),
      _ReceiptRow(
        'الحالة',
        _statusAr(d['status'] ?? 'success'),
        arabicValue: true,
      ),
      _ReceiptRow(
        'إسم المرسل اليه',
        '${d['accountName'] ?? d['receiverName'] ?? 'نازك عبدالقادر الطيب عبدالقادر'}',
        arabicValue: true,
      ),
      _ReceiptRow(
        'التعليق',
        '${d['comment'] ?? d['note'] ?? 'N/A'}',
        arabicValue: true,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 1. شريط التطبيق الأحمر العلوي (AppBar)
            Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffff0000),
                    Color(0xffca1e24),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 30), // موازن أبعاد الهيدر
                    Image.asset(
                      'assets/img/white_logo_n.png',
                      width: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset('assets/img/bankak_logo_big.png', width: 90),
                    ),
                    Image.asset(
                      'assets/img/dehaze_24.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),

            // 2. شريط تفاصيل المعاملة الفرعي الأبيض مع زر العودة back.png في أقصى اليمين المتموضع بدقة كالصورة
            Container(
              height: 61,
              color: const Color(0xfff8f8f8),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'تفاصيل المعاملة',
                      style: TextStyle(
                        color: Color(0xff2b2b2b),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 11,
                    child: InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset(
                        'assets/img/back.png',
                        width: 70,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. مساحة حقول المعاملة مدمج بها صورة الخلفية الزخرفية bg.png
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xff9f9d99), width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: rows.asMap().entries.map((entry) {
                        final isLast = entry.key == rows.length - 1;
                        final r = entry.value;

                        return Container(
                          constraints: const BoxConstraints(minHeight: 39.5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: isLast
                                  ? BorderSide.none
                                  : const BorderSide(color: Color(0xff9f9d99), width: 1.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // اليمين: التسميات بالرمادي الداكن العريض
                              Text(
                                r.label,
                                style: const TextStyle(
                                  color: Color(0xff656565),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  fontFamily: 'Rubik',
                                ),
                              ),
                              const SizedBox(width: 12),
                              // اليسار: القيم المتغيرة محاذاة لليسار بالكامل كالتصميم تماماً
                              Expanded(
                                child: Directionality(
                                  textDirection: r.arabicValue ? TextDirection.rtl : TextDirection.ltr,
                                  child: Text(
                                    r.value.isEmpty ? 'N/A' : r.value,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: r.arabicValue ? TextAlign.right : TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xff626262),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13.5,
                                      fontFamily: 'Rubik',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            // 4. أزرار الأكشن التفاعلية الثنائية (تذكير على اليمين وتحويل خاطئ على اليسار كالصورة)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  // زر تحويل خاطئ (اليسار)
                  Expanded(
                    child: _ActionButton(
                      title: 'تحويل خاطئ',
                      icon: 'block_icon.png',
                      onTap: _showSoon,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // زر تذكير (اليمين)
                  Expanded(
                    child: _ActionButton(
                      title: 'تذكير',
                      icon: 'notification_white.png',
                      onTap: _showSoon,
                    ),
                  ),
                ],
              ),
            ),

            // 5. شريط الخيارات السفلي الثلاثي (مشاركة، طباعة، تحميل) المنظم بالأيقونات الرمادية المرفوعة
            Container(
              height: 33,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xffbcbcbc), width: 1),
                ),
              ),
              child: Row(
                children: [
                  _OptionItem(
                    title: 'مشاركة',
                    icon: 'sharegray.png',
                    onTap: () => _shareTx(d),
                  ),
                  const Text('|', style: TextStyle(color: Color(0xffdddddd))),
                  _OptionItem(
                    title: 'طباعة',
                    icon: 'printgray.png',
                    onTap: _showSoon,
                  ),
                  const Text('|', style: TextStyle(color: Color(0xffdddddd))),
                  _OptionItem(
                    title: 'تحميل',
                    icon: 'downloadgray.png',
                    onTap: _showSoon,
                  ),
                ],
              ),
            ),

            // 6. شريط حقوق بنك الخرطوم ذو التدرج الرمادي الملاصق تماماً للقاع السفلي
            Container(
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffd9dcde),
                    Color(0xffbfc3c6),
                    Color(0xffe4e5e6),
                  ],
                ),
              ),
              child: const Text(
                '© 2024 بنك الخرطوم|بنكك حساب',
                style: TextStyle(
                  color: Color(0xff222222),
                  fontSize: 12,
                  fontFamily: 'Rubik',
                ),
              ),
            ),

            // إشعار التنبيه العائم "قريباً..."
            if (showToast) _buildFloatingToast(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingToast() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 86,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffdddddd)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/img/notification_white.png', width: 18, height: 18, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('قريباً...', style: TextStyle(color: Color(0xff444444), fontSize: 14, fontFamily: 'Rubik')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow {
  final String label;
  final String value;
  final bool arabicValue;

  const _ReceiptRow(
    this.label,
    this.value, {
    this.arabicValue = false,
  });
}

// بناء الأزرار البيضاء ذات الإطار الأحمر مع تموضع الأيقونة على يسار النص تماماً كالصورة الأصلية
class _ActionButton extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xffd33234),
            width: 2.2,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xffd33234),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Rubik',
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/img/$icon',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

// خيارات التذييل الرمادية المنتظمة الأيقونة يميناً ثم النص يساراً بالتوالي المباشر
class _OptionItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _OptionItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/$icon',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff666666),
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                fontFamily: 'Rubik',
              ),
            ),
          ],
        ),
      ),
    );
  }
}