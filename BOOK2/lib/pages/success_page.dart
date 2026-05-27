import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  final GlobalKey _receiptKey = GlobalKey();
  bool showPrintSoon = false;
  bool isProcessing = false;

  static const SystemUiOverlayStyle _successOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Color(0xff6ab62d),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_successOverlayStyle);
  }

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
          'from': dynamicArg.fromAccount ?? dynamicArg.accountFrom ?? dynamicArg.from,
          'fromAccount': dynamicArg.fromAccount ?? dynamicArg.accountFrom ?? dynamicArg.from,
          'accountFrom': dynamicArg.accountFrom ?? dynamicArg.fromAccount ?? dynamicArg.from,
          'to': dynamicArg.toAccount ?? dynamicArg.accountTo ?? dynamicArg.to,
          'toAccount': dynamicArg.toAccount ?? dynamicArg.accountTo ?? dynamicArg.to,
          'accountTo': dynamicArg.accountTo ?? dynamicArg.toAccount ?? dynamicArg.to,
          'receiverName': dynamicArg.receiverName ?? dynamicArg.accountName,
          'accountName': dynamicArg.accountName ?? dynamicArg.receiverName,
          'phone': dynamicArg.phone ?? dynamicArg.mobile,
          'mobile': dynamicArg.mobile ?? dynamicArg.phone,
          'note': dynamicArg.note ?? dynamicArg.comment,
          'comment': dynamicArg.comment ?? dynamicArg.note,
        };
      } catch (_) {}
    }

    return const <String, dynamic>{};
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = '$value'.trim();
      if (value != null && text.isNotEmpty && text != 'null') return text;
    }
    return '';
  }

  String _accountText(List<dynamic> values) {
    final raw = _firstNonEmpty(values);
    if (raw.isEmpty) return '';

    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length >= 16) {
      final account = digitsOnly.substring(0, 16);
      return account.replaceAllMapped(
        RegExp(r'.{4}'),
        (match) => '${match.group(0)} ',
      ).trim();
    }

    String padded = digitsOnly.padLeft(16, '0');
    if (!padded.startsWith('0123')) {
      padded = '0123' + padded.substring(4, 16);
    }
    return padded.replaceAllMapped(
      RegExp(r'.{4}'),
      (match) => '${match.group(0)} ',
    ).trim();
  }

  String _phoneText(List<dynamic> values) {
    final raw = _firstNonEmpty(values);
    if (raw.isEmpty) return 'N/A';

    final clean = raw.trim();

    if (clean == '249' || clean == '+249' || clean == '00249') {
      return 'N/A';
    }

    return clean;
  }

  String _formatAmount(dynamic v) {
    final double n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 0.00;
    final fixed = n.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$whole.${parts.last}';
  }

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
      ['رقم العملية', '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? ''}'],
      ['التاريخ و الزمن', '${d['createdAt'] ?? d['date'] ?? ''}'],
      ['من حساب', _accountText([d['fromAccount'], d['accountFrom'], d['from']])],
      ['الى حساب', _accountText([d['toAccount'], d['accountTo'], d['to']])],
      ['إسم المرسل اليه', '${d['receiverName'] ?? d['accountName'] ?? ''}'],
      ['رقم الموبايل', _phoneText([d['phone'], d['mobile']])],
      ['التعليق', '${d['note'] ?? d['comment'] ?? 'N/A'}'],
      ['المبلغ', _formatAmount(d['amount'] ?? 0)],
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _successOverlayStyle,
      child: Directionality(
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

                                Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(context, '/transfer');
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

                                const Spacer(),
                                const SizedBox(height: 30),

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
                        bottom: 74,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xff2b2b2b),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
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
                                  fontSize: 14,
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xffd33234),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  'assets/img/app_icon.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.account_balance,
                                    color: Colors.white,
                                    size: 16,
                                  ),
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
            Image.asset(
              'assets/img/$icon',
              width: 20,
              height: 20,
              color: Colors.white,
              errorBuilder: (_, __, ___) => Icon(
                fallback,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
