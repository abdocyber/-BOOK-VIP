import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  bool isProcessing = false;
  bool _showPrintSoonPopup = false;

  // جلب البيانات مع الحفاظ على منطق قواعد البيانات
  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    
    // بيانات افتراضية مطابقة للصورة للتجربة البصرية
    return const <String, dynamic>{
      'operationNumber': '20018909627',
      'createdAt': '23-Apr-2026 20:02:58',
      'operationType': 'تحويل إلى حساب آخر',
      'amount': 9900.00,
      'from': '0123 0302 4821 0001',
      'to': '0123 0252 2939 0001',
      'status': ' نجاح ',
      'accountName': 'احمد سليمان احمد محمود',
      'comment': 'كاش',
    };
  }

  String _fmtMoney(dynamic v) {
    final n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 9900.00;
    return n.toStringAsFixed(2);
  }

  bool _isNumericLike(String text) {
    return RegExp(r'^[0-9\s\-\.:/A-Za-z,]+$').hasMatch(text);
  }

  // دالة مخصصة لزر الطباعة تظهر التنبيه العائم الداكن
  void _handlePrintTap() {
    setState(() => _showPrintSoonPopup = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showPrintSoonPopup = false);
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
    final d = _data(context);

    final rows = <_ReceiptRow>[
      _ReceiptRow('رقم العملية', '${d['id'] ?? d['operationNumber'] ?? '20018909627'}'),
      _ReceiptRow('التاريخ والوقت', '${d['date'] ?? d['createdAt'] ?? '23-Apr-2026 20:02:58'}'),
      _ReceiptRow('نوع العملية', '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب آخر'}'),
      _ReceiptRow('المبلغ', '${_fmtMoney(d['amount'] ?? 9900.00)} SDG'),
      _ReceiptRow('من', '${d['from'] ?? d['accountFrom'] ?? '0123 0302 4821 0001'}'),
      _ReceiptRow('إلى', '${d['to'] ?? d['accountTo'] ?? '0123 0252 2939 0001'}'),
      _ReceiptRow('الحالة', '${d['status'] ?? 'نجاح'}'.trim()),
      _ReceiptRow('إسم المرسل اليه', '${d['accountName'] ?? d['receiverName'] ?? 'احمد سليمان احمد محمود'}'),
      _ReceiptRow('التعليق', '${d['comment'] ?? d['note'] ?? 'كاش'}'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white, // خلفية بيضاء نقية
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: RepaintBoundary(
                  key: _receiptKey,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildHeader(context),
                        _buildTitleBar(context),
                        const SizedBox(height: 14),
                        _buildTable(rows),
                        const SizedBox(height: 30),
                        _buildActionButtons(context),
                        const SizedBox(height: 30),
                        _buildBottomSection(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // التنبيه العائم المخصص (قريباً...)
            if (_showPrintSoonPopup)
              _buildPrintSoonPopup(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintSoonPopup() {
    return Positioned(
      bottom: 110, 
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xff2b2b2b),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'قريبا...',
                style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Rubik', fontWeight: FontWeight.w500),
              ),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 92,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffd33234), Color(0xffca1e24)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/img/white_logo_n.png',
                width: 132,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, color: Colors.white, size: 40),
              ),
            ),
            Positioned(
              right: 14,
              top: 18,
              child: InkWell(
                onTap: () => _showSnack('القائمة قريباً'),
                child: Image.asset(
                  'assets/img/dehaze_24.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.menu, color: Colors.white, size: 36),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 18,
              child: InkWell(
                onTap: () => _showSnack('تسجيل الخروج'),
                child: Image.asset(
                  'assets/img/power.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.power_settings_new, color: Colors.white, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 86,
      color: const Color(0xffececec),
      child: Stack(
        children: [
          const Center(
            child: Text(
              'تفاصيل المعاملة',
              style: TextStyle(color: Color(0xff2f2f2f), fontSize: 22, fontWeight: FontWeight.w400, fontFamily: 'Rubik'),
            ),
          ),
          Positioned(
            right: 12,
            top: 10,
            child: InkWell(
              onTap: () { if (Navigator.canPop(context)) Navigator.pop(context); },
              child: Image.asset(
                'assets/img/back.png',
                width: 82, height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<_ReceiptRow> rows) {
    const double unifiedBorderWidth = 1.2; 
    const TextStyle unifiedTextStyle = TextStyle(
      color: Color(0xff444444), // لون رمادي داكن موحد للجميع
      fontSize: 15.0,           
      fontWeight: FontWeight.w600, 
      fontFamily: 'Rubik',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffa5a5a5), width: unifiedBorderWidth),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            final row = entry.value;
            final bool numeric = _isNumericLike(row.value);
            
            // ارتفاع ملحوظ للصفوف ليتطابق مع الصورة
            final double rowHeight = (row.label == 'إسم المرسل اليه' && row.value.length > 25) ? 76.0 : 60.0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: rowHeight,
              decoration: BoxDecoration(
                color: const Color(0xfff6f6f6), 
                border: Border(
                  bottom: isLast ? BorderSide.none : const BorderSide(color: Color(0xffdcdcdc), width: unifiedBorderWidth),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Directionality(
                        textDirection: numeric ? TextDirection.ltr : TextDirection.rtl,
                        child: Text(
                          row.value.isEmpty ? 'N/A' : row.value,
                          textAlign: numeric ? TextAlign.left : TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: unifiedTextStyle, 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 140,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        row.label,
                        textAlign: TextAlign.right,
                        style: unifiedTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildOutlinedBtn(
              text: 'تحويل خاطئ',
              iconPath: 'assets/img/block_icon.png',
              onTap: () => _showSnack('خدمة التحويل الخاطئ قريباً'),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: _buildOutlinedBtn(
              text: 'تذكير',
              iconPath: 'assets/img/notification_white.png',
              onTap: () => _showSnack('خدمة التذكير قريباً'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedBtn({required String text, required String iconPath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffd33234), width: 2), 
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(color: Color(0xffd33234), fontSize: 16, fontFamily: 'Rubik', fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 10),
            Image.asset(
              iconPath,
              width: 22, height: 22,
              color: const Color(0xffd33234), 
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.error_outline, color: Color(0xffd33234), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xffefefef),
            border: Border(top: BorderSide(color: Color(0xffc7c7c7), width: 1)),
          ),
          child: Row(
            children: [
              _buildFooterBtn(text: 'مشاركة', iconPath: 'assets/img/sharegray.png', fallbackIcon: 'share.png', onTap: () => _showSnack('المشاركة قيد التجهيز')),
              _verticalDivider(),
              _buildFooterBtn(text: 'طباعة', iconPath: 'assets/img/printgray.png', fallbackIcon: 'print.png', onTap: _handlePrintTap),
              _verticalDivider(),
              _buildFooterBtn(text: 'تحميل', iconPath: 'assets/img/download.png', fallbackIcon: 'download.png', onTap: () => _showSnack('التحميل قيد التجهيز')),
            ],
          ),
        ),
        Container(
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xffd9dcde), Color(0xffbfc3c6), Color(0xffe4e5e6)],
            ),
          ),
          child: const Text(
            'بنك الخرطوم بنكك حساب 2024©',
            style: TextStyle(color: Color(0xff222222), fontSize: 12.5, fontFamily: 'Rubik', fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterBtn({required String text, required String iconPath, required String fallbackIcon, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(color: Color(0xff5c5c5c), fontSize: 16, fontFamily: 'Rubik', fontWeight: FontWeight.w400),
              ),
              const SizedBox(width: 6),
              Image.asset(
                iconPath,
                width: 22, height: 22,
                color: const Color(0xff5c5c5c),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/img/$fallbackIcon',
                  width: 22, height: 22, color: const Color(0xff5c5c5c),
                  errorBuilder: (___, ____, _____) => const Icon(Icons.image_outlined, color: Color(0xff5c5c5c), size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 26, color: const Color(0xffcfcfcf));
  }
}

class _ReceiptRow {
  final String label;
  final String value;
  const _ReceiptRow(this.label, this.value);
}
