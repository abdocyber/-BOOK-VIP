import 'package:flutter/material.dart';

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  bool showToast = false;

  // استقبال البيانات الحقيقية من الـ Firebase والخدمات الممررة عبر الـ Arguments
  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '05-May-2026 15:36:50'; // تم التعديل لمطابقة التاريخ في الصورة

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
        : double.tryParse('$v'.replaceAll(',', '')) ?? 100.00; // القيمة المطابقة للصورة
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
    final id = '${d['operationNumber'] ?? d['id'] ?? '20018909275'}';
    final amount = _fmtMoney(d['amount'] ?? 100.00);
    final to = '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '1113025957200001'}';

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

    // الـ 9 صفوف المطابقة للصورة المرجعية تماماً
    final rows = <_ReceiptRow>[
      _ReceiptRow('رقم العملية', '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? '20018909275'}'),
      _ReceiptRow('التاريخ والوقت', _fmtDate(d['createdAt'] ?? d['date'] ?? '05-May-2026 15:36:50')),
      _ReceiptRow('نوع العملية', '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب آخر'}', isArabic: true),
      _ReceiptRow('المبلغ', _fmtMoney(d['amount'] ?? 100.00)),
      _ReceiptRow('من', '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '1326253024820001'}'),
      _ReceiptRow('إلى', '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '1113025957200001'}'),
      _ReceiptRow('الحالة', _statusAr(d['status'] ?? 'success'), isArabic: true),
      _ReceiptRow('إسم المرسل اليه', '${d['accountName'] ?? d['receiverName'] ?? 'احمد عبد الرحمن حامد عز الدين'}', isArabic: true),
      _ReceiptRow('التعليق', '${d['comment'] ?? d['note'] ?? 'N/A'}'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // التوجيه الصحيح
      child: Scaffold(
        backgroundColor: Colors.white, //
        body: LayoutBuilder(
          builder: (context, constraints) {
            final appW = constraints.maxWidth.clamp(0.0, 430.0);
            final appH = constraints.maxHeight;
            final scale = (appW / 360.0).clamp(0.8, 1.2);
            double s(double value) => value * scale;

            return SizedBox(
              width: appW,
              height: appH,
              child: Column(
                children: [
                  // 1. شريط التطبيق الأحمر العلوي (AppBar) مع ضبط حجم الشعار الدقيق
                  Container(
                    height: s(65),
                    padding: EdgeInsets.symmetric(horizontal: s(16)),
                    color: const Color(0xFFE31E24), // لون أحمر صلب كالصورة
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // أيقونة القائمة الجانبية (همبرغر) في أقصى اليمين
                          Image.asset(
                            'assets/img/dehaze_24.png',
                            width: s(28),
                            height: s(28),
                            color: Colors.white,
                            fit: BoxFit.contain,
                          ),
                          // شعار بنكك محدد الارتفاع لمنع التمدد ومطابق للصورة الأصلية
                          Image.asset(
                            'assets/img/bankak_logo_big.png',
                            height: s(36), // تم الاعتماد على الارتفاع للحفاظ على نسبة العرض إلى الارتفاع
                            fit: BoxFit.contain,
                          ),
                          // مساحة فارغة لموازنة الشعار في المنتصف
                          SizedBox(width: s(28)), 
                        ],
                      ),
                    ),
                  ),

                  // 2. شريط تفاصيل المعاملة الأبيض وزر الرجوع المتموضع بدقة يميناً
                  Container(
                    height: s(58),
                    color: Colors.white, // أبيض كالصورة 1000069114.png
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            'تفاصيل المعاملة',
                            style: TextStyle(
                              color: const Color(0xff2b2b2b),
                              fontSize: s(16.5),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ),
                        Positioned(
                          right: s(16),
                          top: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            child: Center(
                              child: Image.asset(
                                'assets/img/back.png',
                                height: s(32), // ضبط مقاس زر رجوع المرفق
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. مساحة حقول المعاملة مع الخلفية والكرت المنحني الحواف (Table)
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/bg.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(16)),
                        child: Container(
                          // الكرت المجمع للحقول ذو الحواف المنحنية المميزة
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(s(12)), // حواف منحنية مطابقة
                            border: Border.all(color: const Color(0xffbcbcbc), width: 1.2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: rows.asMap().entries.map((entry) {
                              final isLast = entry.key == rows.length - 1;
                              final r = entry.value;

                              return Container(
                                constraints: BoxConstraints(minHeight: s(46)),
                                padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(12)),
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
                                    // جهة اليمين: التسميات بخط رمادي داكن
                                    Text(
                                      r.label,
                                      style: TextStyle(
                                        color: const Color(0xff444444), // لون داكن مطابق للصورة
                                        fontWeight: FontWeight.w600, // سمك موحد
                                        fontSize: s(14.5),
                                        fontFamily: 'Rubik',
                                      ),
                                    ),
                                    SizedBox(width: s(16)),
                                    // جهة اليسار: القيم محاذاة لليسار تماماً
                                    Expanded(
                                      child: Text(
                                        r.value.isEmpty ? 'N/A' : r.value,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left, // محاذاة يسارية دقيقة
                                        textDirection: r.isArabic ? TextDirection.rtl : TextDirection.ltr, // لضبط اتجاه الأرقام الانجليزية
                                        style: TextStyle(
                                          color: const Color(0xff222222), // لون أسود/رمادي غامق جداً
                                          fontWeight: FontWeight.w600, // سمك موحد مع التسميات كالصورة
                                          fontSize: s(14.5),
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

                  // 4. أزرار الأكشن التفاعلية الثنائية (تحويل خاطئ يمين، تذكير يسار)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(14)),
                    child: Row(
                      children: [
                        // زر تحويل خاطئ (يظهر في اليمين كالصورة الجديدة 1000069114.png)
                        Expanded(
                          child: _ActionButton(
                            title: 'تحويل خاطئ',
                            icon: 'block_icon.png',
                            scale: scale,
                            onTap: _showSoon,
                          ),
                        ),
                        SizedBox(width: s(14)),
                        // زر تذكير (يظهر في اليسار كالصورة الجديدة 1000069114.png)
                        Expanded(
                          child: _ActionButton(
                            title: 'تذكير',
                            icon: 'notification_white.png', // تأكد من استخدام أيقونة جرس تناسب اللون الأحمر
                            scale: scale,
                            onTap: _showSoon,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 5. شريط الخيارات السفلي (مشاركة، طباعة، تحميل)
                  Container(
                    height: s(40),
                    decoration: const BoxDecoration(
                      color: Color(0xfff8f8f8),
                      border: Border(
                        top: BorderSide(color: Color(0xffdcdcdc), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        _OptionItem(
                          title: 'مشاركة',
                          icon: 'sharegray.png',
                          scale: scale,
                          onTap: () => _shareTx(d),
                        ),
                        const Text('|', style: TextStyle(color: Color(0xffdddddd))),
                        _OptionItem(
                          title: 'طباعة',
                          icon: 'printgray.png',
                          scale: scale,
                          onTap: _showSoon,
                        ),
                        const Text('|', style: TextStyle(color: Color(0xffdddddd))),
                        _OptionItem(
                          title: 'تحميل',
                          icon: 'downloadgray.png',
                          scale: scale,
                          onTap: _showSoon,
                        ),
                      ],
                    ),
                  ),

                  // 6. شريط حقوق بنك الخرطوم السفلي
                  Container(
                    height: s(32),
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
                    child: Text(
                      '© 2024 بنك الخرطوم|بنكك حساب',
                      style: TextStyle(
                        color: const Color(0xff222222),
                        fontSize: s(12),
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  if (showToast) _buildFloatingToast(scale),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingToast(double scale) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: scale * 90,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: scale * 18, vertical: scale * 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffdddddd)),
            borderRadius: BorderRadius.circular(scale * 14),
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
              Icon(Icons.info_outline, color: Colors.grey, size: scale * 18),
              SizedBox(width: scale * 8),
              Text('قريباً...', style: TextStyle(color: const Color(0xff444444), fontSize: scale * 14, fontFamily: 'Rubik')),
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
  final bool isArabic;

  const _ReceiptRow(
    this.label,
    this.value, {
    this.isArabic = false,
  });
}

// الأزرار البيضاء السفلية (تحويل خاطئ وتذكير) بحواف مميزة ونصوص حمراء
class _ActionButton extends StatelessWidget {
  final String title;
  final String icon;
  final double scale;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(s(8)),
      child: Container(
        height: s(44),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xffd33234), // إطار أحمر كالصورة
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(s(8)), // حواف منحنية متناسقة
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color(0xffd33234), // نص أحمر
                fontSize: s(15),
                fontWeight: FontWeight.w500,
                fontFamily: 'Rubik',
              ),
            ),
            SizedBox(width: s(8)),
            Image.asset(
              'assets/img/$icon',
              width: s(18),
              height: s(18),
              color: const Color(0xffd33234), // تلوين الأيقونة بالأحمر
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.circle, size: s(10), color: const Color(0xffd33234)),
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
  final double scale;
  final VoidCallback onTap;

  const _OptionItem({
    required this.title,
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/$icon',
              width: s(16),
              height: s(16),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.share, size: s(14), color: Colors.grey),
            ),
            SizedBox(width: s(6)),
            Text(
              title,
              style: TextStyle(
                color: const Color(0xff555555),
                fontSize: s(13.5),
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
