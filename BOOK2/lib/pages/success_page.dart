import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart' hide TextDirection; // لمنع أي تعارض في البناء

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  final GlobalKey _receiptKey = GlobalKey(); // مفتاح التقاط الشاشة
  bool showPrintSoon = false;
  bool isProcessing = false;

  // جلب البيانات مع الحفاظ على منطق قواعد البيانات والربط
  Map<String, dynamic> _getTxData(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    
    // دعم استقبال البيانات كـ Object إذا كنت تستخدم Model
    if (arg != null) {
      try {
        final dynamic dynamicArg = arg;
        return {
          'operationNumber': dynamicArg.operationNumber ?? dynamicArg.id,
          'createdAt': dynamicArg.date ?? dynamicArg.createdAt,
          'amount': dynamicArg.amount,
          'from': dynamicArg.fromAccount ?? dynamicArg.from,
          'to': dynamicArg.toAccount ?? dynamicArg.to,
          'receiverName': dynamicArg.receiverName ?? dynamicArg.accountName,
          'phone': dynamicArg.phone ?? dynamicArg.mobile,
          'note': dynamicArg.note ?? dynamicArg.comment,
        };
      } catch (_) {}
    }
    
    // بيانات افتراضية مطابقة للصورة لتسهيل التجربة
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

  // تنسيق التاريخ
  String _fmtDate(dynamic v) {
    if (v == null) return '21-May-2026 16:39:17';
    final text = '$v';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} ${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
  }

  // تنسيق المبلغ 
  String _formatAmount(dynamic v) {
    final double n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 15000.00;
    final fixed = n.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$whole.${parts.last}';
  }

  // دالة التقاط الشاشة
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
  Future<void> _shareReceipt() async {
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
  Future<void> _downloadReceipt() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);
    try {
      final Uint8List? imageBytes = await _capturePng();
      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await imagePath.writeAsBytes(imageBytes);
        _showCustomToast('تم تحميل الإشعار بنجاح في الجهاز', Icons.check_circle);
      }
    } catch (e) {
      _showCustomToast('تعذر حفظ الصورة', Icons.error);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  // تشغيل زر "طباعة" (يعرض التنبيه الداكن المخصص)
  void _printSoon() {
    setState(() => showPrintSoon = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => showPrintSoon = false);
    });
  }

  // تنبيهات عامة
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

    // بناء الجدول بنفس الترتيب والمسميات
    final rows = [
      ['رقم العملية', '${d['operationNumber'] ?? '20019741802'}'],
      ['التاريخ و الزمن', _fmtDate(d['createdAt'])],
      ['من حساب', '${d['from'] ?? '0123 0302 4821 0001'}'],
      ['الى حساب', '${d['to'] ?? '0033 0443 6676 0001'}'],
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
          key: _receiptKey, // تغليف الواجهة للالتقاط
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              // تدرج اللون الأخضر المطابق تماماً للصورة
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
                                
                                // علامة الصح الدائرية
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

                                // الجدول بإطار أبيض رقيق ومطابق بالملي
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1.0),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    children: rows.asMap().entries.map((entry) {
                                      final isLast = entry.key == rows.length - 1;
                                      final e = entry.value;

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
                                              e[0],
                                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Rubik'),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Directionality(
                                                  textDirection: TextDirection.ltr,
                                                  child: Text(
                                                    e[1],
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

                                // ======= إصلاح زر موافق المطابق للـ CSS تماماً =======
                                Center(
                                  child: InkWell(
                                    onTap: () {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.pushReplacementNamed(context, '/home');
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(9),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 40), // margin: 40px auto 0
                                      width: 96, // width: 96px
                                      height: 44, // height: 44px
                                      alignment: Alignment.center, // الكلمة في المنتصف تماماً (justify-content: center; align-items: center;)
                                      decoration: BoxDecoration(
                                        // تم استخدام التدرج الأخضر ليطابق شكل الزر في الصورة
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Color(0xff57a82b), Color(0xff398b14)],
                                        ),
                                        border: Border.all(color: const Color(0xffd8f0dc), width: 1.3), // border: 1.3px solid #d8f0dc;
                                        borderRadius: BorderRadius.circular(9), // border-radius: 9px;
                                      ),
                                      child: const Text(
                                        'موافق',
                                        style: TextStyle(
                                          color: Color(0xffeef7ee), // color: #eef7ee;
                                          fontSize: 15, // font-size: 15px;
                                          fontWeight: FontWeight.w700, // font-weight: 700;
                                          fontFamily: 'Rubik', // متوافق مع باقي التطبيق
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // ======================================================

                                const Spacer(),
                                const SizedBox(height: 30),

                                // أزرار (تحويل - إضافة) السفلية
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildSubBtn('تحويل', 'newaddtransfernow.png', () => Navigator.pushReplacementNamed(context, '/transfer')),
                                      _buildSubBtn('إضافة', 'newaddbenf.png', () => Navigator.pushReplacementNamed(context, '/transactions')),
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
                        // شريط (مشاركة - طباعة - تحميل)
                        Container(
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xff126815),
                            border: Border(top: BorderSide(color: Colors.white, width: 1.0)),
                          ),
                          child: Row(
                            children: [
                              _buildFooterOpt('مشاركة', 'share.png', _shareReceipt),
                              Container(width: 1.2, height: 22, color: Colors.white),
                              _buildFooterOpt('طباعة', 'print.png', _printSoon),
                              Container(width: 1.2, height: 22, color: Colors.white),
                              _buildFooterOpt('تحميل', 'download.png', _downloadReceipt),
                            ],
                          ),
                        ),
                        // تذييل الحقوق
                        Container(
                          height: 26,
                          alignment: Alignment.center,
                          color: const Color(0xff0e4a0f),
                          child: const Text(
                            '© 2024 بنك الخرطوم|بنكك حساب',
                            style: TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Rubik', fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                    
                    // التنبيه العائم المخصص لزر الطباعة (قريباً...)
                    if (showPrintSoon)
                      Positioned(
                        bottom: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xff333333), // اللون الداكن
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.3), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('قريباً...', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Rubik', fontWeight: FontWeight.w500)),
                              const SizedBox(width: 10),
                              // المربع الأحمر بداخله الأيقونة البيضاء
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

  // بناء أزرار (إضافة - تحويل)
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

  // بناء أزرار الشريط السفلي (مشاركة - طباعة - تحميل)
  Widget _buildFooterOpt(String title, String icon, VoidCallback onTap) {
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
              errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
