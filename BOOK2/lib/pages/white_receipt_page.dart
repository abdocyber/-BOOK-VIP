import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart' hide TextDirection; // حجب التعارض البرمجي

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  final GlobalKey _receiptKey = GlobalKey(); // مفتاح التقاط الشاشة
  bool showPrintSoon = false;
  bool isProcessing = false;

  // دالة لجلب البيانات من الـ Route لدعم كافة أنواع الربط (Map أو Object)
  Map<String, dynamic> _getTxData(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    
    // بيانات احتياطية مطابقة للصورة تماماً كاحتياطي
    return const <String, dynamic>{
      'operationNumber': '20018909627',
      'createdAt': '2026-04-23T20:02:58',
      'operationType': 'تحويل إلى حساب آخر',
      'amount': 9900.00,
      'from': '0123 0302 4821 0001',
      'to': '0123 0252 2939 0001',
      'status': 'success',
      'receiverName': 'احمد سليمان احمد محمود',
      'note': 'كاش',
    };
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '23-Apr-2026 20:02:58';
    final text = '$v';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} ${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
  }

  String _fmtMoney(dynamic v) {
    final n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 9900.00;
    return n.toStringAsFixed(2);
  }

  // التقاط الشاشة والمشاركة
  Future<void> _shareReceiptImage() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);
    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/bankak_receipt.png').create();
        await imagePath.writeAsBytes(imageBytes);
        await Share.shareXFiles([XFile(imagePath.path)], text: 'إشعار تحويل بنكك');
      }
    } catch (_) {
      _showSnack('تعذر إتمام المشاركة');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  // حفظ صورة الإيصال
  Future<void> _downloadReceiptImage() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);
    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await imagePath.writeAsBytes(imageBytes);
        _showSnack('تم حفظ إشعار المعاملة في الجهاز بنجاح');
      }
    } catch (_) {
      _showSnack('حدث خطأ أثناء حفظ الإشعار');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _triggerPrintSoon() {
    setState(() => showPrintSoon = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => showPrintSoon = false);
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Rubik')),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _getTxData(context);

    final rows = [
      ['رقم العملية', '${d['operationNumber'] ?? '20018909627'}'],
      ['التاريخ والوقت', _fmtDate(d['createdAt'])],
      ['نوع العملية', '${d['operationType'] ?? 'تحويل إلى حساب آخر'}'],
      ['المبلغ', '${_fmtMoney(d['amount'])} SDG'],
      ['من', '${d['from'] ?? '0123 0302 4821 0001'}'],
      ['إلى', '${d['to'] ?? '0123 0252 2939 0001'}'],
      ['الحالة', '${d['status']}'.toLowerCase() == 'success' || '${d['status']}'.isEmpty ? 'نجاح' : '${d['status']}'],
      ['إسم المرسل اليه', '${d['receiverName'] ?? 'احمد سليمان احمد محمود'}'],
      ['التعليق', '${d['note'] ?? 'كاش'}'],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RepaintBoundary(
          key: _receiptKey,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 1. الشريط العلوي (الأحمر)
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xffe31e24), Color(0xffb80006)],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset('assets/img/white_logo_n.png', width: 95, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
                            ),
                            Positioned(
                              right: 14,
                              top: 16,
                              child: InkWell(
                                onTap: () => _showSnack('القائمة قريباً'),
                                child: Image.asset('assets/img/dehaze_24.png', width: 28, height: 28, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.menu, color: Colors.white, size: 28)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 2. شريط عنوان تفاصيل المعاملة الفرعي
                      Container(
                        width: double.infinity,
                        height: 52,
                        color: const Color(0xfff8f8f8),
                        child: Stack(
                          children: [
                            const Center(
                              child: Text('تفاصيل المعاملة', style: TextStyle(color: Color(0xff2b2b2b), fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Rubik')),
                            ),
                            Positioned(
                              right: 14,
                              top: 8,
                              child: InkWell(
                                onTap: () { if (Navigator.canPop(context)) Navigator.pop(context); },
                                child: Image.asset('assets/img/back.png', width: 70, height: 35, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 3. مساحة الجدول القابلة للتمرير مع الخلفية المزخرفة
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
                            padding: const EdgeInsets.only(top: 12, bottom: 20),
                            child: Padding(
                              // ملاصق تماماً للشاشة بهامش 0.2 بكسل فقط كما طلبت
                              padding: const EdgeInsets.symmetric(horizontal: 0.2),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xff999999), width: 1.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: rows.asMap().entries.map((entry) {
                                    final isLast = entry.key == rows.length - 1;
                                    final row = entry.value;
                                    final bool isSuccessStatus = row[0] == 'الحالة' && row[1] == 'نجاح';

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // 8px كما طلبت
                                      decoration: BoxDecoration(
                                        border: Border(bottom: isLast ? BorderSide.none : const BorderSide(color: Color(0xffcccccc), width: 0.8)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(row[0], style: const TextStyle(color: Color(0xff555555), fontSize: 14.5, fontWeight: FontWeight.bold, fontFamily: 'Rubik')),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                row[1].isEmpty ? 'N/A' : row[1],
                                                textAlign: TextAlign.left, // محاذاة لليسار
                                                style: TextStyle(
                                                  color: isSuccessStatus ? const Color(0xff2e7d32) : const Color(0xff333333), 
                                                  fontSize: 14.0, 
                                                  fontWeight: isSuccessStatus ? FontWeight.bold : FontWeight.w500, 
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
                      ),
                      
                      // 4. أزرار الأكشن السفلية
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildActionBtn(
                                text: 'تحويل خاطئ',
                                iconPath: 'assets/img/block_icon.png',
                                onTap: _triggerPrintSoon,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildActionBtn(
                                text: 'تذكير',
                                iconPath: 'assets/img/notification_white.png',
                                onTap: _triggerPrintSoon,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 5. شريط التذييل (مشاركة، طباعة، تحميل)
                      Container(
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xfff8f8f8),
                          border: Border(top: BorderSide(color: Color(0xffdcdcdc), width: 1)),
                        ),
                        child: Row(
                          children: [
                            _buildFooterBtn(text: 'مشاركة', iconPath: 'assets/img/sharegray.png', onTap: _shareReceiptImage),
                            _divider(),
                            _buildFooterBtn(text: 'طباعة', iconPath: 'assets/img/printgray.png', onTap: _triggerPrintSoon),
                            _divider(),
                            _buildFooterBtn(text: 'تحميل', iconPath: 'assets/img/downloadgray.png', onTap: _downloadReceiptImage),
                          ],
                        ),
                      ),
                      
                      // 6. شريط التذييل السفلي
                      Container(
                        height: 28,
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
                          style: TextStyle(color: Color(0xff222222), fontSize: 12.5, fontFamily: 'Rubik', fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),

                  // 7. التنبيه العائم المخصص لزر الطباعة (قريباً...)
                  if (showPrintSoon)
                    Positioned(
                      bottom: 86, 
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xff2b2b2b),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(.28), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: const Color(0xffd33234), borderRadius: BorderRadius.circular(6)),
                                child: Image.asset('assets/img/white_logo_n.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, color: Colors.white, size: 16)),
                              ),
                              const SizedBox(width: 10),
                              const Text('قريباً...', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Rubik', fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({required String text, required String iconPath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffd33234), width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 18, height: 18, color: const Color(0xffd33234), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.circle, color: Color(0xffd33234), size: 14)),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Color(0xffd33234), fontSize: 15.5, fontFamily: 'Rubik', fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBtn({required String text, required String iconPath, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(color: Color(0xff555555), fontSize: 14.0, fontFamily: 'Rubik', fontWeight: FontWeight.w400)),
            const SizedBox(width: 6),
            Image.asset(iconPath, width: 18, height: 18, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: Color(0xff5c5c5c), size: 18)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 20, color: const Color(0xffcccccc));
}

class _ReceiptRow {
  final String label;
  final String value;
  const _ReceiptRow(this.label, this.value);
}
