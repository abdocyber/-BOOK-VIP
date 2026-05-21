import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/receipt.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  final GlobalKey _receiptKey = GlobalKey();
  bool isProcessing = false;

  // استلام البيانات الممررة من صفحة التحويل
  ReceiptData _receipt(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ReceiptData) return arg;
    return const ReceiptData(
      operationNumber: '20019741802',
      date: '21-May-2026 16:39:17',
      fromAccount: '0123 0302 4821 0001',
      toAccount: '0033 0443 6676 0001',
      receiverName: 'نازك عبدالقادر الطيب',
      phone: 'N/A',
      note: 'N/A',
      amount: 15000.00,
    );
  }

  // التقاط الشاشة كصورة
  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) { return null; }
  }

  // زر المشاركة
  Future<void> _shareReceipt() async {
    setState(() => isProcessing = true);
    final bytes = await _capturePng();
    if (bytes != null) {
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/receipt.png').create();
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'إشعار تحويل بنكك');
    }
    setState(() => isProcessing = false);
  }

  // زر التحميل
  Future<void> _downloadReceipt() async {
    setState(() => isProcessing = true);
    final bytes = await _capturePng();
    if (bytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final file = await File('${dir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الصورة في الجهاز', textAlign: TextAlign.center)));
    }
    setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = _receipt(context);
    final rows = [
      ['رقم العملية', r.operationNumber],
      ['التاريخ والوقت', r.date],
      ['من حساب', r.fromAccount],
      ['الى حساب', r.toAccount],
      ['إسم المرسل اليه', r.receiverName],
      ['رقم الموبايل', r.phone],
      ['التعليق', r.note],
      ['المبلغ', '${r.amount.toStringAsFixed(2)} SDG'],
    ];

    return Scaffold(
      body: RepaintBoundary(
        key: _receiptKey,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff68b835), Color(0xff248316)]),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      Container(width: 120, height: 120, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.check, color: Color(0xff248316), size: 70)),
                      const SizedBox(height: 15),
                      const Text('تحويلات', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1), borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          children: rows.map((e) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 0.5))),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(e[0], style: const TextStyle(color: Colors.white, fontSize: 14)),
                              Text(e[1], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            ]),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      InkWell(
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Text('موافق', style: TextStyle(color: Color(0xff248316), fontWeight: FontWeight.bold))),
                      ),
                    ],
                  ),
                ),
              ),
              // الأزرار السفلية
              Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _iconBtn('إضافة', Icons.person_add, () {}),
                _iconBtn('تحويل', Icons.currency_exchange, () {}),
              ])),
              Container(height: 45, color: const Color(0xff126815), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _footerBtn('مشاركة', Icons.share, _shareReceipt),
                _footerBtn('طباعة', Icons.print, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً...')))),
                _footerBtn('تحميل', Icons.download, _downloadReceipt),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(String t, IconData i, VoidCallback tap) => InkWell(onTap: tap, child: Column(children: [Icon(i, color: Colors.white, size: 30), Text(t, style: const TextStyle(color: Colors.white))]));
  Widget _footerBtn(String t, IconData i, VoidCallback tap) => InkWell(onTap: tap, child: Row(children: [Text(t, style: const TextStyle(color: Colors.white)), const SizedBox(width: 5), Icon(i, color: Colors.white, size: 18)]));
}
