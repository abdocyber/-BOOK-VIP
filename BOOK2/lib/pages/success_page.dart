import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  final GlobalKey _receiptKey = GlobalKey(); // مفتاح التقاط الشاشة للإيصال
  bool showPrintSoon = false;
  bool isProcessing = false;

  // جلب البيانات من الـ Route arguments (يدعم الخرائط والكائنات تلقائياً)
  Map<String, dynamic> _getTxData(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    
    if (arg != null) {
      try {
        final dynamic dynamicArg = arg;
        return {
  'operationNumber': dynamicArg.operationNumber ?? dynamicArg.id,
  'createdAt': dynamicArg.date ?? dynamicArg.createdAt,
  'amount': dynamicArg.amount,
  'from': dynamicArg.fromAccount ?? dynamicArg.from,
  'to': dynamicArg.toAccount ?? dynamicArg.accountTo ?? dynamicArg.to,
  'toAccount': dynamicArg.toAccount ?? dynamicArg.accountTo ?? dynamicArg.to,
  'accountTo': dynamicArg.accountTo ?? dynamicArg.toAccount ?? dynamicArg.to,
  'receiverName': dynamicArg.receiverName ?? dynamicArg.accountName,
  'phone': dynamicArg.phone ?? dynamicArg.mobile,
  'note': dynamicArg.note ?? dynamicArg.comment,
};
      } catch (_) {}
    }
    
    // بيانات افتراضية مطابقة للصورة لتسهيل التجربة في بيئة التطوير
    return const <String, dynamic>{
      'operationNumber': '20019741802',
      'createdAt': '21-May-2026 16:39:17',
      'amount': 15000.00,
      'from': '0123 0302 4821 0001',
      'to': '0033 0443 6676 0001',
      'receiverName': 'نازك عبدالقادر الطيب\nعبدالقادر',
      'phone': 'N/A',
      'note': 'N/A',
    };
  }

  // تنسيق المبلغ المالي بوضع الفواصل
  String _formatAmount(dynamic v) {
    final double n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 15000.00;
    final fixed = n.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$whole.${parts.last}';
  }

  // دالة التقاط الشاشة كصورة
  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  // تشغيل زر "مشاركة"
  Future<void> _shareReceiptImage() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);
    try {
      final Uint8List? imageBytes = await _capturePng();
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/bankak_receipt.png').create();
        await imagePath.writeAsBytes(imageBytes);
        await Share.shareXFiles([XFile(imagePath.path)], text: 'إشعار تحويل بنكك');
      }
    } catch (e) {
      _showCustomToast('تعذر المشاركة', Icons.error);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  // تشغيل زر "تحميل"
  Future<void> _downloadReceiptImage() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);
    try {
      final Uint8List? imageBytes = await _capturePng();
      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await imagePath.writeAsBytes(imageBytes);
        _showCustomToast('تم حفظ إشعار المعاملة في الجهاز بنجاح', Icons.check_circle);
      }
    } catch (e) {
      _showCustomToast('حدث خطأ أثناء حفظ الإشعار', Icons.error);
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

  void _showCustomToast(String msg, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(msg, style: const TextStyle(fontFamily: 'Rubik', fontSize: 13)),
          ],
        ),
        backgroundColor: const Color(0xff126815),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _getTxData(context);
    
    final screenW = MediaQuery.of(context).size.width;
    final okButtonWidth = screenW * 0.2555;
    final okButtonHeight = okButtonWidth * 0.62;

    final rows = [
      ['رقم العملية', '${d['operationNumber'] ?? '20019741802'}'],
      ['التاريخ و الزمن', '${d['createdAt'] ?? '21-May-2026 16:39:17'}'],
      ['من حساب', '${d['from'] ?? '0123 0302 4821 0001'}'],
      ['الى حساب', '${d['toAccount'] ?? d['accountTo'] ?? d['to'] ?? '0033 0443 6676 0001'}'],
      ['إسم المرسل اليه', '${d['receiverName'] ?? 'نازك عبدالقادر الطيب\nعبدالقادر'}'],
      ['رقم الموبايل', '${d['phone'] ?? 'N/A'}'],
      ['التعليق', '${d['note'] ?? 'N/A'}'],
      ['المبلغ', _formatAmount(d['amount'])],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xff2d8d1e),
        body: RepaintBoundary(
          key: _receiptKey,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff6ab62d), Color(0xff228014)],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                const SizedBox(height: 55),
                                
                                // علامة الصح البيضاء الدائرية
                                Container(
                                  width: 125,
                                  height: 125,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(24),
                                  child: Image.asset(
                                    'assets/img/sucesstick.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.check, color: Color(0xff1f982d), size: 70),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),

                                const Text(
                                  'تحويلات',
                                  style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
                                ),
                                
                                const SizedBox(height: 20),

                                // الجدول
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1.0),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    children: rows.asMap().entries.map((entry) {
                                      final isLast = entry.key == rows.length - 1;
                                      final row = entry.value;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: isLast ? BorderSide.none : const BorderSide(color: Colors.white, width: 0.8)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              row[0],
                                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Rubik'),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Directionality(
                                                  textDirection: TextDirection.ltr,
                                                  child: Text(
                                                    row[1],
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Rubik'),
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

                                // ======= تعديل زر موافق ليتطابق مع الـ CSS وتركيز النص في المنتصف بالملي =======
                                Padding(
  padding: const EdgeInsets.only(top: 40),
  child: Center(
    child: InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/sendto');
      },
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        width: okButtonWidth,
        height: okButtonHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/img/sucessbutton.png',
              width: okButtonWidth,
              height: okButtonHeight,
              fit: BoxFit.fill,
            ),
            const Text(
              'موافق',
              style: TextStyle(
                color: Color(0xffeef7ee),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Rubik',
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
                                // ===========================================================================

                                const Spacer(),
                                const SizedBox(height: 30),

                                // أزرار تحويل وإضافة السفلية
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildSubBtn(
                                        'تحويل',
                                        'newaddtransfernow.png',
                                        () => Navigator.pushReplacementNamed(context, '/transfer'),
                                      ),
                                      _buildSubBtn(
                                        'إضافة',
                                        'newaddbenf.png',
                                        () => Navigator.pushReplacementNamed(context, '/transactions'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // الأشرطة السفلية الثابتة
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 46,
                          decoration: const BoxDecoration(
                            color: Color(0xff126815),
                            border: Border(top: BorderSide(color: Colors.white, width: 1.0)),
                          ),
                          child: Row(
                            children: [
                              _buildFooterOpt('مشاركة', 'share.png', Icons.share, _shareReceiptImage),
                              Container(width: 1.2, height: 22, color: Colors.white),
                              _buildFooterOpt('طباعة', 'print.png', Icons.print, _triggerPrintSoon),
                              Container(width: 1.2, height: 22, color: Colors.white),
                              _buildFooterOpt('تحميل', 'download.png', Icons.download, _downloadReceiptImage),
                            ],
                          ),
                        ),
                        Container(
                          height: 28,
                          alignment: Alignment.center,
                          color: const Color(0xff0e4a0f),
                          child: const Text(
                            '© 2024 بنك الخرطوم|بنكك حساب',
                            style: TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Rubik', fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                    
                    if (showPrintSoon)
                      Positioned(
                        bottom: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xff2b2b2b),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(.28), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('قريباً...', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Rubik', fontWeight: FontWeight.w500)),
                              const SizedBox(width: 10),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(color: const Color(0xffd33234), borderRadius: BorderRadius.circular(6)),
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  'assets/img/white_logo_n.png', 
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubBtn(String title, String icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            'assets/img/$icon',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            color: Colors.white,
            errorBuilder: (_, __, ___) => const Icon(Icons.circle, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Rubik', fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterOpt(String title, String icon, IconData fallback, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w400, fontFamily: 'Rubik'),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/img/$icon',
              width: 18,
              height: 18,
              color: Colors.white,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(fallback, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
