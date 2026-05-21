import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/receipt.dart';

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  final GlobalKey _receiptKey = GlobalKey();
  bool isProcessing = false;

  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    return const <String, dynamic>{
      'operationNumber': '20018909275',
      'createdAt': '2026-05-05T15:36:50',
      'amount': 100.00,
      'from': '1326253024820001',
      'to': '1113025957200001',
      'receiverName': 'احمد سليمان احمد محمود',
      'mobile': 'N/A',
      'comment': 'كاش',
      'status': 'success',
      'operationType': 'تحويل إلى حساب آخر'
    };
  }

  // الدوال المساعدة للربط
  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) { return null; }
  }

  Future<void> _shareReceipt() async {
    if (isProcessing) return;
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

  @override
  Widget build(BuildContext context) {
    final d = _data(context);
    final rows = [
      ['رقم العملية', d['operationNumber']],
      ['التاريخ والوقت', d['createdAt']],
      ['نوع العملية', d['operationType']],
      ['المبلغ', '${d['amount']} SDG'],
      ['من', d['from']],
      ['إلى', d['to']],
      ['الحالة', d['status'] == 'success' ? 'نجاح' : d['status']],
      ['إسم المرسل اليه', d['receiverName']],
      ['التعليق', d['comment']],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RepaintBoundary(
          key: _receiptKey,
          child: Column(
            children: [
              // 1. الشريط العلوي
              Container(
                height: 65,
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xffe31e24), Color(0xffb80006)])),
                child: SafeArea(child: Stack(children: [
                  Center(child: Image.asset('assets/img/white_logo_n.png', width: 95)),
                  Positioned(right: 10, top: 18, child: Image.asset('assets/img/dehaze_24.png', width: 28))
                ])),
              ),
              // العنوان
              Container(height: 50, alignment: Alignment.center, color: const Color(0xfff8f8f8), 
                child: const Text('تفاصيل المعاملة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              
              // 2. الجدول: ملاصق للحواف (هامش 0.2px)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 8, left: 0.2, right: 0.2),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xff999999), width: 1.0)),
                    child: Column(
                      children: rows.map((e) => Container(
                        // الارتفاع المضبوط لـ 8px padding عمودي
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffcccccc), width: 0.5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e[0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff555555))),
                            Expanded(child: Text('${e[1]}', textAlign: TextAlign.left, style: const TextStyle(fontSize: 14, color: Color(0xff333333)))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ),

              // 3. الأزرار السفلية المشغلة
              Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                Expanded(child: _btn('تحويل خاطئ', 'block_icon.png')),
                const SizedBox(width: 10),
                Expanded(child: _btn('تذكير', 'notification_white.png')),
              ])),
              
              Container(height: 40, color: const Color(0xfff8f8f8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _opt('مشاركة', 'sharegray.png', _shareReceipt),
                _opt('طباعة', 'printgray.png', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً...')))),
                _opt('تحميل', 'downloadgray.png', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً...')))),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(String t, String i) => Container(height: 40, decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(20)), 
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(t, style: const TextStyle(color: Colors.red)), const SizedBox(width: 5), Image.asset('assets/img/$i', width: 16, color: Colors.red)]));
  
  Widget _opt(String t, String i, VoidCallback tap) => InkWell(onTap: tap, child: Row(children: [Text(t, style: const TextStyle(fontSize: 12)), const SizedBox(width: 4), Image.asset('assets/img/$i', width: 16)]));
}
