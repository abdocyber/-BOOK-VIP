import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  final GlobalKey _receiptKey = GlobalKey();
  bool showToast = false;
  bool isProcessing = false;

  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  // ====== دالة تنسيق رقم الحساب ======
  String _formatAccountNumber(String account) {
    final digitsOnly = account.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length >= 16) {
      final acc16 = digitsOnly.substring(0, 16);
      return acc16.replaceAllMapped(
        RegExp(r'.{4}'),
        (match) => '${match.group(0)} ',
      ).trim();
    }
    return account;
  }

  String _fmtDate(dynamic v) {
    if (v == null) return 'May-2026 15:36:50-05';
    final text = '$v';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String p(int n) => n.toString().padLeft(2, '0');

    return '${months[parsed.month - 1]}-${parsed.year} ${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}-05';
  }

  String _fmtMoney(dynamic v) {
    final n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 100.00;
    return n.toStringAsFixed(2);
  }

  String _statusAr(dynamic v) {
    return '$v' == 'success' || '$v'.isEmpty ? 'نجاح' : '$v';
  }

  void _showCustomToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        backgroundColor: const Color(0xff126815),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPrintSoon() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xff2b2b2b),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'قريباً...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/img/white_logo_n.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_balance,
                      color: Color(0xffd33234),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 1600), () {
      overlayEntry.remove();
    });
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

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
      _showCustomToast('تعذر المشاركة');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _downloadReceipt() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);
    try {
      final Uint8List? imageBytes = await _capturePng();
      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await imagePath.writeAsBytes(imageBytes);
        _showCustomToast('تم حفظ الإشعار بنجاح');
      }
    } catch (e) {
      _showCustomToast('تعذر التحميل');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showSoon() {
    setState(() => showToast = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => showToast = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذه الميزة قريباً!'))
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _data(context);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFE31E24),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    final rows = <_ReceiptRow>[
      _ReceiptRow('رقم العملية', '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? '20018909275'}'),
      _ReceiptRow('التاريخ والوقت', _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-05-24T15:36:50')),
      _ReceiptRow('نوع العملية', '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب آخر'}'),
      _ReceiptRow('المبلغ', _fmtMoney(d['amount'] ?? 100.00)),
      // ====== تنسيق أرقام الحسابات ======
      _ReceiptRow('من', _formatAccountNumber('${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '1326253024820001'}')),
      _ReceiptRow('إلى', _formatAccountNumber('${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '1113025957200001'}')),
      _ReceiptRow('الحالة', _statusAr(d['status'] ?? 'success')),
      _ReceiptRow('إسم المرسل اليه', '${d['accountName'] ?? d['receiverName'] ?? 'احمد عبد الرحمن حامد عز الدين'}'),
      _ReceiptRow('التعليق', '${d['comment'] ?? d['note'] ?? 'N/A'}'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RepaintBoundary(
        key: _receiptKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // شريط التطبيق العلوي
              Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffe31e24), Color(0xffb80006)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.menu, color: Colors.white, size: 26),
                      Image.asset(
                        'assets/img/white_logo_n.png',
                        width: 160,
                        height: 55,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 26),
                    ],
                  ),
                ),
              ),

              // شريط تفاصيل المعاملة وزر الرجوع
              Container(
                height: 56,
                color: const Color(0xfff8f8f8),
                child: Stack(
                  children: [
                    const Center(
                      child: Text(
                        'تفاصيل المعاملة',
                        style: TextStyle(color: Color(0xff2b2b2b), fontSize: 18, fontWeight: FontWeight.w300, fontFamily: 'Rubik'),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      top: 8,
                      child: InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
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

              // الجدول الممتد
              Expanded(
                child: Container(
                  color: const Color(0xFFF4F5F7),
                  child: SingleChildScrollView(
                    child: Column(
                      children: rows.asMap().entries.map((entry) {
                        final r = entry.value;
                        final isTallRow = r.label == 'إسم المرسل اليه';

                        return Container(
                          height: isTallRow ? 52 : 44,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xff989793),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                r.label,
                                style: const TextStyle(
                                  color: Color(0xff666666),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                  fontFamily: 'Rubik',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  r.value.isEmpty ? 'N/A' : r.value,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Color(0xff666666),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.0,
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

              // أزرار الإجراءات
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(child: _ActionButton(title: 'تذكير', icon: 'notification_white.png', onTap: _showSoon)),
                    const SizedBox(width: 14),
                    Expanded(child: _ActionButton(title: 'تحويل خاطئ', icon: 'block_icon.png', onTap: _showSoon)),
                  ],
                ),
              ),

              // شريط التذييل الثلاثي
              Container(
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xffdcdcdc), width: 1)),
                ),
                child: Row(
                  children: [
                    _FooterOption(title: 'مشاركة', icon: 'sharegray.png', onTap: _shareReceipt),
                    Container(width: 1, height: 20, color: const Color(0xffe0e0e0)),
                    _FooterOption(title: 'طباعة', icon: 'printgray.png', onTap: _showPrintSoon),
                    Container(width: 1, height: 20, color: const Color(0xffe0e0e0)),
                    _FooterOption(title: 'تحميل', icon: 'downloadgray.png', onTap: _downloadReceipt),
                  ],
                ),
              ),

              // شريط الحقوق السفلي
              Container(
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffe0e3e5), Color(0xffc5c9cc)],
                  ),
                ),
                child: const Text(
                  '© 2024 بنك الخرطوم|بنكك حساب',
                  style: TextStyle(color: Color(0xff222222), fontSize: 12, fontFamily: 'Rubik', fontWeight: FontWeight.w500),
                ),
              ),
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
  const _ReceiptRow(this.label, this.value);
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  const _ActionButton({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffd33234), width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/$icon',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: const Color(0xffd33234),
              errorBuilder: (_, __, ___) => Icon(
                _getIconForActionButton(icon),
                size: 20,
                color: const Color(0xffd33234),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xffd33234),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Rubik',
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForActionButton(String iconName) {
    if (iconName.contains('block')) return Icons.block;
    return Icons.notifications_none;
  }
}

class _FooterOption extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  const _FooterOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff666666),
                fontSize: 14,
                fontFamily: 'Rubik',
              ),
            ),
            const SizedBox(width: 6),
            Image.asset(
              'assets/img/$icon',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.share, size: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
