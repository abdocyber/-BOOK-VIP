import 'package:flutter/material.dart';

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '30-Apr-2026 21:09:01';

    final text = '$v';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    String p(int n) => n.toString().padLeft(2, '0');

    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} '
        '${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
  }

  String _fmtMoney(dynamic v) {
    final n = v is num
        ? v.toDouble()
        : double.tryParse('$v'.replaceAll(',', '')) ?? 500000.00;
    return n.toStringAsFixed(2);
  }

  String _statusAr(dynamic v) {
    final t = '$v'.trim().toLowerCase();
    if (t.isEmpty || t == 'success') return 'نجاح';
    return '$v';
  }

  void _showSoon() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 1200),
        content: Text(
          'قريباً...',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _shareTx(Map<String, dynamic> d) {
    final id = '${d['operationNumber'] ?? d['id'] ?? '20047360699'}';
    final amount = _fmtMoney(d['amount'] ?? 500000.00);
    final to = '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0038 5717 7730 001'}';

    final text = 'تفاصيل المعاملة\nرقم العملية: $id\nالمبلغ: $amount\nإلى: $to';

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _data(context);

    final rows = <_ReceiptRow>[
      _ReceiptRow(
        'رقم العملية',
        '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? '20047360699'}',
      ),
      _ReceiptRow(
        'التاريخ والوقت',
        _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-04-30T21:09:01'),
      ),
      _ReceiptRow(
        'نوع العملية',
        '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب اخر'}',
        arabicValue: true,
      ),
      _ReceiptRow(
        'المبلغ',
        _fmtMoney(d['amount'] ?? 500000.00),
      ),
      _ReceiptRow(
        'من',
        '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '0263 1898 8440 0001'}',
      ),
      _ReceiptRow(
        'إلى',
        '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0038 5717 7730 001'}',
      ),
      _ReceiptRow(
        'الحالة',
        _statusAr(d['status'] ?? 'success'),
        arabicValue: true,
      ),
      _ReceiptRow(
        'إسم المرسل\nاليه',
        '${d['accountName'] ?? d['receiverName'] ?? 'Maram Mohammed Ahmed Ali'}',
        arabicValue: true,
      ),
      _ReceiptRow(
        'التعليق',
        '${d['comment'] ?? d['note'] ?? 'N/A'}',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffefefef),
        body: Column(
          children: [
            _buildTopHeader(),
            _buildTitleBar(context),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset(
                        'assets/img/bg.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 12),
                    children: [
                      ...rows.map((r) => _buildReceiptBox(r)).toList(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: const Color(0xffefefef),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                      child: _ActionButton(
                        title: 'تحويل خاطئ',
                        icon: 'block_icon.png',
                        onTap: _showSoon,
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: _ActionButton(
                        title: 'تذكير',
                        icon: 'notification_white.png',
                        onTap: _showSoon,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xff4a4a4a), width: 1.0),
                ),
                child: Row(
                  children: [
                    _BottomOption(
                      title: 'مشاركة',
                      icon: 'sharegray.png',
                      onTap: () => _shareTx(d),
                    ),
                    _vDivider(),
                    _BottomOption(
                      title: 'طباعة',
                      icon: 'printgray.png',
                      onTap: _showSoon,
                    ),
                    _vDivider(),
                    _BottomOption(
                      title: 'تحميل',
                      icon: 'downloadgray.png',
                      onTap: _showSoon,
                    ),
                  ],
                ),
              ),
              Container(
                height: 34,
                alignment: Alignment.center,
                color: const Color(0xffd6d6d6),
                child: const Text(
                  '© 2024 بنك الخرطوم | بنكك حساب',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 66,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffff0000),
            Color(0xffcb1b2b),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/img/white_logo_n.png',
                  width: 74,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/img/dehaze_24.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.menu, color: Colors.white, size: 34),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Container(
      height: 92,
      color: const Color(0xffefefef),
      child: Stack(
        children: [
          const Center(
            child: Text(
              'تفاصيل المعاملة',
              style: TextStyle(
                color: Color(0xff222222),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 14,
            child: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Image.asset(
                'assets/img/back.png',
                width: 98,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 98,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffcc4a4a), width: 1.6),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'رجوع',
                    style: TextStyle(
                      color: Color(0xffcc4a4a),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptBox(_ReceiptRow row) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        border: Border.all(color: const Color(0xff666666), width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(minHeight: 70),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 142,
              child: Text(
                row.label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xff303030),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Directionality(
                textDirection:
                    row.arabicValue ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  row.value.isEmpty ? 'N/A' : row.value,
                  textAlign:
                      row.arabicValue ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xff3d3d3d),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: double.infinity,
      color: const Color(0xff4a4a4a),
    );
  }
}

class _ReceiptRow {
  final String label;
  final String value;
  final bool arabicValue;

  const _ReceiptRow(
    this.label,
    this.value, {
    this.arabicValue = false,
  });
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xffc93e3a),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xffc93e3a),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/img/$icon',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(width: 22, height: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomOption extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _BottomOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/$icon',
              width: 21,
              height: 21,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(width: 21, height: 21),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff444444),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
