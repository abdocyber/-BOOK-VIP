import 'package:flutter/material.dart';

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  bool showToast = false;

  // استقبال البيانات من صفحة التحويل
  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '05-May-2026 15:36:50';
    final text = '$v';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String p(int n) => n.toString().padLeft(2, '0');

    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} ${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
  }

  String _fmtMoney(dynamic v) {
    final n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 100.00;
    return n.toStringAsFixed(2);
  }

  String _statusAr(dynamic v) {
    return '$v' == 'success' || '$v'.isEmpty ? 'نجاح' : '$v';
  }

  void _showSoon() {
    setState(() => showToast = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => showToast = false);
    });
  }

  void _shareTx(Map<String, dynamic> d) {
    final id = '${d['operationNumber'] ?? d['id'] ?? '20018909275'}';
    final amount = _fmtMoney(d['amount'] ?? 100.00);
    final to = '${d['to'] ?? d['accountTo'] ?? '1113025957200001'}';
    final text = 'تفاصيل المعاملة\nرقم العملية: $id\nالمبلغ: $amount\nإلى: $to';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, textAlign: TextAlign.center)));
  }

  @override
  Widget build(BuildContext context) {
    final d = _data(context);

    // ترتيب الصفوف بالضبط كما في الصورة المرجعية
    final rows = <_ReceiptRow>[
      _ReceiptRow('رقم العملية', '${d['operationNumber'] ?? d['id'] ?? '20018909275'}', false),
      _ReceiptRow('التاريخ والوقت', _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-05-05T15:36:50')),
      _ReceiptRow('نوع العملية', '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب آخر'}', true),
      _ReceiptRow('المبلغ', _fmtMoney(d['amount'] ?? 100.00)),
      _ReceiptRow('من', '${d['from'] ?? d['accountFrom'] ?? '1326253024820001'}'),
      _ReceiptRow('إلى', '${d['to'] ?? d['accountTo'] ?? '1113025957200001'}'),
      _ReceiptRow('الحالة', _statusAr(d['status'] ?? 'success'), true),
      _ReceiptRow('إسم المرسل اليه', '${d['accountName'] ?? d['receiverName'] ?? 'احمد عبد الرحمن حامد عز الدين'}', true),
      _ReceiptRow('التعليق', '${d['comment'] ?? d['note'] ?? 'N/A'}', true),
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // توجيه الواجهة بالكامل من اليمين لليسار
      child: Scaffold(
        backgroundColor: const Color(0xfff5f5f5), // لون الخلفية العام
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. الشريط العلوي (الأحمر)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffe31e24), Color(0xffb80006)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/img/dehaze_24.png', width: 28, height: 28, fit: BoxFit.contain),
                    Image.asset('assets/img/bankak_logo_big.png', width: 95, fit: BoxFit.contain),
                    const SizedBox(width: 28), // لموازنة الشعار في المنتصف
                  ],
                ),
              ),

              // 2. شريط تفاصيل المعاملة الفرعي
              Container(
                height: 50,
                color: const Color(0xfff8f8f8),
                child: Stack(
                  children: [
                    const Center(
                      child: Text(
                        'تفاصيل المعاملة',
                        style: TextStyle(
                          color: Color(0xff2b2b2b),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Rubik',
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          },
                          child: Image.asset('assets/img/back.png', height: 30, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. مساحة الجدول المزخرفة والمستطيلات المتلاصقة تماماً
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Column(
                      children: [
                        // الجدول: صندوق أبيض يحتوي على الصفوف المتلاصقة
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xff999999), width: 1.2),
                          ),
                          child: Column(
                            children: rows.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final _ReceiptRow r = entry.value;
                              final bool isLast = index == rows.length - 1;

                              return Container(
                                // تقليل الارتفاع والمسافات لتبدو الصفوف أصغر ومتلاصقة كالصورة
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: isLast ? BorderSide.none : const BorderSide(color: Color(0xffcccccc), width: 1.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // العناوين: اليمين
                                    Text(
                                      r.label,
                                      style: const TextStyle(
                                        color: Color(0xff555555),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Rubik',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // القيم: أقصى اليسار
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft, // دفع القيم لأقصى اليسار دائمًا
                                        child: Text(
                                          r.value,
                                          textAlign: r.isArabicValue ? TextAlign.right : TextAlign.left,
                                          textDirection: r.isArabicValue ? TextDirection.rtl : TextDirection.ltr,
                                          style: const TextStyle(
                                            color: Color(0xff333333),
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
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

                        const SizedBox(height: 25),

                        // 4. أزرار (تحويل خاطئ) و (تذكير) مطابقة تماماً
                        Row(
                          children: [
                            // زر تحويل خاطئ (في اليسار مع أيقونته)
                            Expanded(
                              child: _buildActionBtn(
                                title: 'تحويل خاطئ',
                                iconPath: 'assets/img/block_icon.png',
                                onTap: _showSoon,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // زر تذكير (في اليمين مع أيقونته)
                            Expanded(
                              child: _buildActionBtn(
                                title: 'تذكير',
                                iconPath: 'assets/img/notification_white.png', // استخدم أيقونة الجرس
                                onTap: _showSoon,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. شريط الخيارات السفلية (مشاركة - طباعة - تحميل)
              Container(
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xfff8f8f8),
                  border: Border(top: BorderSide(color: Color(0xffdcdcdc), width: 1.0)),
                ),
                child: Row(
                  children: [
                    _buildBottomOption(title: 'مشاركة', iconPath: 'assets/img/sharegray.png', onTap: () => _shareTx(d)),
                    Container(width: 1, height: 18, color: const Color(0xffcccccc)), // فاصل عمودي
                    _buildBottomOption(title: 'طباعة', iconPath: 'assets/img/printgray.png', onTap: _showSoon),
                    Container(width: 1, height: 18, color: const Color(0xffcccccc)), // فاصل عمودي
                    _buildBottomOption(title: 'تحميل', iconPath: 'assets/img/downloadgray.png', onTap: _showSoon),
                  ],
                ),
              ),

              // 6. تذييل حقوق بنك الخرطوم
              Container(
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffe0e3e5), Color(0xffc5c9cc), Color(0xffe4e5e6)],
                  ),
                ),
                child: const Text(
                  '© 2024 بنك الخرطوم|بنكك حساب',
                  style: TextStyle(
                    color: Color(0xff222222),
                    fontSize: 12,
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              
              // التنبيه العائم المؤقت
              if (showToast) _buildFloatingToast(),
            ],
          ),
        ),
      ),
    );
  }

  // بناء أزرار "تذكير" و "تحويل خاطئ" المفرغة بالإطار الأحمر
  Widget _buildActionBtn({required String title, required String iconPath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25), // حواف دائرية كبسولية
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffd33234), width: 1.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ترتيب الأيقونة والنص ليطابق الصورة
            Image.asset(
              iconPath,
              width: 18,
              height: 18,
              color: const Color(0xffd33234), // تلوين الأيقونة بالأحمر
              errorBuilder: (_, __, ___) => const Icon(Icons.circle, color: Color(0xffd33234), size: 12),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xffd33234),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Rubik',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء أزرار الشريط السفلي (مشاركة، طباعة، تحميل)
  Widget _buildBottomOption({required String title, required String iconPath, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // النص يمين والأيقونة يسار (في بيئة RTL يتم ترتيبها هكذا)
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff555555),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Rubik',
              ),
            ),
            const SizedBox(width: 5),
            Image.asset(
              iconPath,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.share, size: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت رسالة (قريباً...)
  Widget _buildFloatingToast() {
    return Positioned(
      bottom: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffdddddd)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 16),
            SizedBox(width: 6),
            Text('قريباً...', style: TextStyle(color: Color(0xff444444), fontSize: 13, fontFamily: 'Rubik')),
          ],
        ),
      ),
    );
  }
}

// كلاس مساعد لتنظيم الصفوف
class _ReceiptRow {
  final String label;
  final String value;
  final bool isArabicValue;

  const _ReceiptRow(this.label, this.value, [this.isArabicValue = false]);
}
