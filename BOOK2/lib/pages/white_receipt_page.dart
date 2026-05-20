import 'package:flutter/material.dart';

class WhiteReceiptPage extends StatelessWidget {
  const WhiteReceiptPage({super.key});

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

    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(parsed.day)}-${m[parsed.month - 1]}-${parsed.year} ${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
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

  @override
  Widget build(BuildContext context) {
    final d = _data(context);

    final rows = <_ReceiptRow>[
      _ReceiptRow('رقم العملية', '${d['operationNumber'] ?? d['id'] ?? '20047360699'}'),
      _ReceiptRow('التاريخ والوقت', _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-04-30T21:09:01')),
      _ReceiptRow('نوع العملية', '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب اخر'}', arabicValue: true),
      _ReceiptRow('المبلغ', _fmtMoney(d['amount'] ?? 500000.00)),
      _ReceiptRow('من', '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '0263 1898 8440 0001'}'),
      _ReceiptRow('إلى', '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0038 5717 7730 001'}'),
      _ReceiptRow('الحالة', _statusAr(d['status'] ?? 'success'), arabicValue: true),
      _ReceiptRow('إسم المرسل\nاليه', '${d['accountName'] ?? d['receiverName'] ?? 'Maram Mohammed Ahmed Ali'}', arabicValue: true),
      _ReceiptRow('التعليق', '${d['comment'] ?? d['note'] ?? 'N/A'}'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffeeeeee),
        body: Column(
          children: [
            _topHeader(),
            _titleBar(context),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.055,
                      child: Image.asset(
                        'assets/img/bg.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    itemCount: rows.length,
                    itemBuilder: (_, i) => _receiptRow(rows[i]),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _bottomArea(context, d),
      ),
    );
  }

  Widget _topHeader() {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffff0000), Color(0xffc9182a)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/img/white_logo_n.png',
                width: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            Positioned(
              right: 15,
              top: 13,
              child: Image.asset(
                'assets/img/dehaze_24.png',
                width: 35,
                height: 35,
                color: Colors.white,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.menu, color: Colors.white, size: 35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleBar(BuildContext context) {
    return Container(
      height: 94,
      color: const Color(0xffeeeeee),
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 31,
            child: Text(
              'تفاصيل المعاملة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Color(0xff222222),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 18,
            child: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: Image.asset(
                'assets/img/back.png',
                width: 86,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 86,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffcf4c4c), width: 1.4),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 5,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'رجوع',
                    style: TextStyle(color: Color(0xffcf4c4c), fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(_ReceiptRow row) {
    return Container(
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 1.8),
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        border: Border.all(
          color: const Color(0xff4f4f4f),
          width: 1.15,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 142,
              child: Text(
                row.label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.05,
                  color: Color(0xff303030),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Directionality(
                textDirection: row.arabicValue ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  row.value.isEmpty ? 'N/A' : row.value,
                  textAlign: row.arabicValue ? TextAlign.right : TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    height: 1.05,
                    color: Color(0xff4a4a4a),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomArea(BuildContext context, Map<String, dynamic> d) {
    return Container(
      color: const Color(0xffeeeeee),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: _ActionButton(
                    title: 'تحويل خاطئ',
                    icon: 'block_icon.png',
                    onTap: () => _soon(context),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _ActionButton(
                    title: 'تذكير',
                    icon: 'notification_white.png',
                    onTap: () => _soon(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 51,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xff333333), width: 1),
            ),
            child: Row(
              children: [
                _BottomOption(title: 'مشاركة', icon: 'sharegray.png', onTap: () => _share(context, d)),
                _divider(),
                _BottomOption(title: 'طباعة', icon: 'printgray.png', onTap: () => _soon(context)),
                _divider(),
                _BottomOption(title: 'تحميل', icon: 'downloadgray.png', onTap: () => _soon(context)),
              ],
            ),
          ),
          Container(
            height: 36,
            alignment: Alignment.center,
            color: const Color(0xffcfcfcf),
            child: const Text(
              '© 2024 بنك الخرطوم | بنكك حساب',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: double.infinity,
      color: const Color(0xff333333),
    );
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 1100),
        content: Text('قريباً...', textAlign: TextAlign.center),
      ),
    );
  }

  void _share(BuildContext context, Map<String, dynamic> d) {
    final id = '${d['operationNumber'] ?? d['id'] ?? '20047360699'}';
    final amount = _fmtMoney(d['amount'] ?? 500000.00);
    final to = '${d['to'] ?? d['toAccount'] ?? '0038 5717 7730 001'}';

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تفاصيل المعاملة\nرقم العملية: $id\nالمبلغ: $amount\nإلى: $to',
          textAlign: TextAlign.center,
        ),
      ),
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
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffc73b3b), width: 2.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xffc73b3b),
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/img/$icon',
              width: 23,
              height: 23,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(width: 23, height: 23),
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
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(width: 22, height: 22),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff444444),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
