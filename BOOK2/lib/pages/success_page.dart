import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/receipt.dart'; // تأكد من المسار الصحيح للـ Model

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  final GlobalKey _receiptKey = GlobalKey(); // مفتاح لالتقاط الشاشة
  bool showPrintSoon = false;
  bool isProcessing = false;

  // جلب البيانات أو استخدام بيانات وهمية (Fallback)
  ReceiptData _receipt(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ReceiptData) return arg;
    
    return const ReceiptData(
      operationNumber: '1779360902681',
      date: '21-May-2026 12:55:03',
      fromAccount: '0123030248210001',
      toAccount: '3024821',
      receiverName: 'مستلم',
      phone: '249',
      note: 'N/A',
      amount: 200.00,
    );
  }

  // تنسيق المبلغ المالي بوضع الفواصل
  String _formatAmount(double v) {
    final fixed = v.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$whole.${parts.last}';
  }

  // دالة التقاط الشاشة
  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // جودة عالية
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

  // تشغيل زر "طباعة"
  void _printSoon() {
    setState(() => showPrintSoon = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => showPrintSoon = false);
    });
  }

  // تنبيه بسيط
  void _showCustomToast(String msg, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(msg, style: const TextStyle(fontFamily: 'Rubik', fontSize: 14)),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xff126815),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _receipt(context);

    // تجهيز البيانات
    final rows = [
      ['رقم العملية', r.operationNumber],
      ['التاريخ و الزمن', r.date],
      ['من حساب', r.fromAccount],
      ['الى حساب', r.toAccount],
      ['إسم المرسل ...', r.receiverName], // تقصير الكلمة لتطابق الصورة
      ['رقم الموبايل', r.phone],
      ['التعليق', r.note],
      ['المبلغ', _formatAmount(r.amount)],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: RepaintBoundary(
          key: _receiptKey,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              // تدرج اللون الأخضر المطابق تماماً للصورة
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff67b533), Color(0xff228014)],
              ),
            ),
            child: Stack(
              children: [
                // 1. المحتوى القابل للتمرير
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      // ترك مساحة سفلية ثابتة للأشرطة (46 + 28 = 74)
                      padding: const EdgeInsets.only(bottom: 74),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight - 74),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              const SizedBox(height: 55),
                              
                              // الدائرة البيضاء بعلامة الصح
                              Container(
                                width: 130,
                                height: 130,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(28),
                                child: Image.asset(
                                  'assets/img/sucesstick.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.check, color: Color(0xff3fa027), size: 65),
                                ),
                              ),
                              
                              const SizedBox(height: 16),

                              // نص تحويلات
                              const Text(
                                'تحويلات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Rubik',
                                ),
                              ),
                              
                              const SizedBox(height: 20),

                              // الجدول (مستطيل بخط أبيض رفيع)
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
                                        border: Border(
                                          bottom: isLast ? BorderSide.none : const BorderSide(color: Colors.white, width: 0.8),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // العنوان: يمين
                                          Text(
                                            e[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Rubik',
                                            ),
                                          ),
                                          // القيمة: يسار (مع LTR للأرقام)
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Directionality(
                                                textDirection: TextDirection.ltr,
                                                child: Text(
                                                  e[1],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Rubik',
                                                  ),
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

                              const SizedBox(height: 30),

                              // زر "موافق" (كصورة)
                              InkWell(
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  }
                                },
                                child: Image.asset(
                                  'assets/img/sucessbutton.png',
                                  width: 160,
                                  height: 46,
                                  fit: BoxFit.fill,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 160,
                                    height: 46,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(10)),
                                    child: const Text('موافق', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),

                              const Spacer(), // لدفع الأزرار السفلية إلى الأسفل إذا كانت الشاشة طويلة
                              const SizedBox(height: 30),

                              // أزرار "إضافة" و "تحويل" الملاصقة للتذييل
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSubBtn('إضافة', 'newaddbenf.png', Icons.person_add_alt_1, () {}),
                                    _buildSubBtn('تحويل', 'newaddtransfernow.png', Icons.sync, () {}),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 2. الأشرطة السفلية الثابتة (لا تتحرك مع التمرير)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // شريط الخيارات: مشاركة | طباعة | تحميل
                      Container(
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xff126815),
                          border: Border(top: BorderSide(color: Colors.white, width: 1.0)),
                        ),
                        child: Row(
                          children: [
                            _buildFooterOpt('تحميل', 'download.png', Icons.arrow_circle_down, _downloadReceipt),
                            Container(width: 1.5, height: 20, color: Colors.white),
                            _buildFooterOpt('طباعة', 'print.png', Icons.print, _printSoon),
                            Container(width: 1.5, height: 20, color: Colors.white),
                            _buildFooterOpt('مشاركة', 'share.png', Icons.share, _shareReceipt),
                          ],
                        ),
                      ),
                      // شريط الحقوق
                      Container(
                        height: 28,
                        alignment: Alignment.center,
                        color: const Color(0xff0e4a0f),
                        child: const Text(
                          '© 2024 بنك الخرطوم|بنكك حساب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. رسالة (قريباً...) المخصصة للطباعة تظهر فوق كل شيء
                if (showPrintSoon)
                  Positioned(
                    bottom: 90, // تظهر فوق الأشرطة السفلية
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xffdddddd)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/img/bankak_logo_big.png', // أيقونة التطبيق المصغرة
                              width: 36,
                              height: 18,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.info, color: Colors.red),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'قريباً...',
                              style: TextStyle(color: Color(0xff444444), fontSize: 14, fontFamily: 'Rubik', fontWeight: FontWeight.bold),
                            ),
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
    );
  }

  // بناء أزرار "إضافة" و "تحويل"
  Widget _buildSubBtn(String title, String icon, IconData fallback, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            'assets/img/$icon',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(fallback, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Rubik'),
          ),
        ],
      ),
    );
  }

  // بناء خيارات الشريط السفلي الثابت (تحميل، طباعة، مشاركة)
  Widget _buildFooterOpt(String title, String icon, IconData fallback, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // النص باليمين والأيقونة باليسار كما في الصورة
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                fontFamily: 'Rubik',
              ),
            ),
            const SizedBox(width: 6),
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
