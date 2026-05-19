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
    if (v == null) return '15-May-2026 08:09:23'; //

    final text = '$v';
    final parsed = DateTime.tryParse(text);

    if (parsed == null) return text;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    String p(int n) => n.toString().padLeft(2, '0');

    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} '
        '${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}'; //
  }

  String _fmtMoney(dynamic v) {
    final n = v is num
        ? v.toDouble()
        : double.tryParse('$v'.replaceAll(',', '')) ?? 40000.00; //

    return n.toStringAsFixed(2);
  }

  String _statusAr(dynamic v) {
    return '$v' == 'success' || '$v'.isEmpty ? 'نجاح' : '$v'; //
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
    final id = '${d['operationNumber'] ?? d['id'] ?? '20019502790'}'; //
    final amount = _fmtMoney(d['amount'] ?? 40000.00); //
    final to = '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0033 0443 6676 0001'}'; //

    final text = 'تفاصيل المعاملة\nرقم العملية: $id\nالمبلغ: $amount\nإلى: $to'; //

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _data(context);

    // الـ 9 صفوف المطابقة للصورة المرجعية تماماً
    final rows = <_ReceiptRow>[
      _ReceiptRow(
        'رقم العملية',
        '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? '20019502790'}', //
      ),
      _ReceiptRow(
        'التاريخ والوقت',
        _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-05-15T08:09:23'), //
      ),
      _ReceiptRow(
        'نوع العملية',
        '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب آخر'}', //
      ),
      _ReceiptRow(
        'المبلغ',
        _fmtMoney(d['amount'] ?? 40000.00), //
      ),
      _ReceiptRow(
        'من',
        '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '0123 0302 4821 0001'}', //
      ),
      _ReceiptRow(
        'إلى',
        '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0033 0443 6676 0001'}', //
      ),
      _ReceiptRow(
        'الحالة',
        _statusAr(d['status'] ?? 'success'), //
      ),
      _ReceiptRow(
        'إسم المرسل اليه',
        '${d['accountName'] ?? d['receiverName'] ?? 'نازك عبدالقادر الطيب عبدالقادر'}', //
      ),
      _ReceiptRow(
        'التعليق',
        '${d['comment'] ?? d['note'] ?? 'N/A'}', //
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // توجيه الواجهة بالكامل من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white, //
        body: Column(
          children: [
            // 1. شريط التطبيق الأحمر العلوي (AppBar) - مطابقة تامة لمواضع وترتيب الأيقونات والشعار
            Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffe31e24),
                    Color(0xffb80006),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر القائمة الجانبية (Hamburger Menu) في أقصى اليمين في وضع الـ RTL
                    Image.asset(
                      'assets/img/dehaze_24.png',
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                    // الشعار متمركز تماماً بالوسط
                    Image.asset(
                      'assets/img/bankak_logo_big.png',
                      width: 95,
                      fit: BoxFit.contain,
                    ),
                    // فراغ موازن أبعاد هندسي في اليسار ليحافظ على توسيط الشعار
                    const SizedBox(width: 26),
                  ],
                ),
              ),
            ),

            // 2. شريط تفاصيل المعاملة الفرعي الأبيض مع زر العودة المتموضع بدقة باليمين
            Container(
              height: 56,
              color: const Color(0xfff8f8f8),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'تفاصيل المعاملة',
                      style: TextStyle(
                        color: Color(0xff2b2b2b),
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 8,
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

            // 3. مساحة حقول المعاملة المحدثة بالمحاذاة اليسارية المطلقة للقيم (اليمين تسميات، اليسار قيم)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xffbcbcbc), width: 1.2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: rows.asMap().entries.map((entry) {
                        final isLast = entry.key == rows.length - 1;
                        final r = entry.value;

                        return Container(
                          constraints: const BoxConstraints(minHeight: 42),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: isLast
                                  ? BorderSide.none
                                  : const BorderSide(color: Color(0xffdcdcdc), width: 1.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // جهة اليمين: التسميات ثابتة عريضة باللون الرمادي الداكن
                              Text(
                                r.label,
                                style: const TextStyle(
                                  color: Color(0xff555555),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  fontFamily: 'Rubik',
                                ),
                              ),
                              const SizedBox(width: 16),
                              // جهة اليسار: محاذاة كل القيم (نصوص أو أرقام) لليسار تماماً كالتطبيق الأصلي
                              Expanded(
                                child: Text(
                                  r.value.isEmpty ? 'N/A' : r.value,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left, // محاذاة يسارية مطلقة
                                  style: const TextStyle(
                                    color: Color(0xff333333),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                    fontFamily: 'Rubik',
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

            // 4. أزرار الأكشن التفاعلية الثنائية - ترتيب هندسي صحيح (تذكير يمين، تحويل خاطئ يسار)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // زر تحويل خاطئ (يظهر في اليسار في وضع الـ RTL)
                  Expanded(
                    child: _ActionButton(
                      title: 'تحويل خاطئ',
                      icon: 'block_icon.png',
                      onTap: _showSoon,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // زر تذكير (يظهر في اليمين في وضع الـ RTL)
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

            // 5. شريط الخيارات السفلي الثلاثي المنتظم (مشاركة، طباعة، تحميل) بالتوالي المباشر
            Container(
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xffdcdcdc), width: 1),
                ),
              ),
              child: Row(
                children: [
                  _OptionItem(
                    title: 'مشاركة',
                    icon: 'sharegray.png',
                    onTap: () => _shareTx(d),
                  ),
                  const Text('|', style: TextStyle(color: Color(0xffe0e0e0))),
                  _OptionItem(
                    title: 'طباعة',
                    icon: 'printgray.png',
                    onTap: _showSoon,
                  ),
                  const Text('|', style: TextStyle(color: Color(0xffe0e0e0))),
                  _OptionItem(
                    title: 'تحميل',
                    icon: 'downloadgray.png',
                    onTap: _showSoon,
                  ),
                ],
              ),
            ),

            // 6. شريط حقوق بنك الخرطوم ذو التدرج الرمادي الملاصق تماماً للقاع السفلي للشاشة
            Container(
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffe0e3e5),
                    Color(0xffc5c9cc),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow {
  final String label;
  final String value;

  const _ReceiptRow(
    this.label,
    this.value,
  );
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xffd33234),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xffd33234),
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Rubik',
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/img/$icon',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.circle, size: 10, color: Color(0xffd33234)),
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
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.share, size: 14, color: Colors.grey),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff555555),
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                fontFamily: 'Rubik',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
