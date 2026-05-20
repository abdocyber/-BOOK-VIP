import 'package:flutter/material.dart';

class WhiteReceiptPage extends StatelessWidget {
  const WhiteReceiptPage({super.key});

  Map<String, String> _normalize(dynamic args) {
    String fromMap(List<String> keys) {
      if (args is Map) {
        for (final k in keys) {
          final v = args[k];
          if (v != null && '$v'.trim().isNotEmpty) return '$v';
        }
      }
      return '';
    }

    String fromObject(String field) {
      try {
        final a = args as dynamic;
        switch (field) {
          case 'operationNumber':
            return '${a.operationNumber ?? ''}';
          case 'date':
            return '${a.date ?? ''}';
          case 'fromAccount':
            return '${a.fromAccount ?? ''}';
          case 'toAccount':
            return '${a.toAccount ?? ''}';
          case 'receiverName':
            return '${a.receiverName ?? ''}';
          case 'phone':
            return '${a.phone ?? ''}';
          case 'note':
            return '${a.note ?? ''}';
          case 'amount':
            return '${a.amount ?? ''}';
        }
      } catch (_) {}
      return '';
    }

    String pick(List<String> keys, String objField) {
      final m = fromMap(keys);
      if (m.isNotEmpty) return m;
      final o = fromObject(objField);
      return o;
    }

    final rawAmount = pick(['amount', 'المبلغ'], 'amount');
    final parsedAmount = double.tryParse(
          rawAmount.replaceAll(',', '').replaceAll('SDG', '').trim(),
        ) ??
        0.0;

    return {
      'operationNumber': pick(
        ['operationNumber', 'id', 'رقم العملية'],
        'operationNumber',
      ),
      'date': pick(
        ['date', 'createdAt', 'التاريخ', 'التاريخ والوقت'],
        'date',
      ),
      'type': pick(['type', 'نوع العملية'], 'type').isEmpty
          ? 'تحويل إلى حساب آخر'
          : pick(['type', 'نوع العملية'], 'type'),
      'amount': parsedAmount.toStringAsFixed(2),
      'from': _formatAccount(
        pick(['fromAccount', 'from', 'من'], 'fromAccount'),
      ),
      'to': _formatAccount(
        pick(['toAccount', 'to', 'إلى'], 'toAccount'),
      ),
      'status': pick(['status', 'الحالة'], 'status').isEmpty
          ? 'نجاح'
          : pick(['status', 'الحالة'], 'status'),
      'receiverName': pick(
        ['receiverName', 'name', 'fullName', 'اسم المرسل اليه'],
        'receiverName',
      ),
      'note': pick(['note', 'comment', 'التعليق'], 'note').isEmpty
          ? 'N/A'
          : pick(['note', 'comment', 'التعليق'], 'note'),
    };
  }

  static String _formatAccount(String value) {
    final clean = value.replaceAll(' ', '').trim();
    if (clean.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      buffer.write(clean[i]);
      final pos = i + 1;
      if (pos < clean.length && pos % 4 == 0) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  Widget _infoRow({
    required String label,
    required String value,
    bool multiLineValue = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      height: multiLineValue ? 76 : 74,
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f5),
        border: Border.all(color: const Color(0xff9d9d9d), width: 1.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  textAlign: TextAlign.left,
                  maxLines: multiLineValue ? 2 : 1,
                  overflow: multiLineValue ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.1,
                    color: Color(0xff585858),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  label,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xff555555),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlineAction({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 72,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xfff8f8f8),
            side: const BorderSide(color: Color(0xffcc3a3a), width: 2.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xffcc3a3a),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: const Color(0xffcc3a3a), size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomMiniAction({
    required String text,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: 52,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff666666),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: const Color(0xff666666), size: 26),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _normalize(ModalRoute.of(context)?.settings.arguments);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffefefef),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 112,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffdf1010), Color(0xffff1c1c)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/img/white_logo_n.png',
                        height: 72,
                        errorBuilder: (_, __, ___) => const Text(
                          'bankak',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 22,
                      child: Icon(Icons.menu, size: 46, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 112,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xfff8f8f8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xffcf4a4a),
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'رجوع>',
                              style: TextStyle(
                                color: Color(0xffd15353),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'تفاصيل المعاملة',
                        style: TextStyle(
                          fontSize: 27,
                          color: Color(0xff2d2d2d),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),

                      _infoRow(label: 'رقم العملية', value: d['operationNumber']!),
                      _infoRow(label: 'التاريخ والوقت', value: d['date']!),
                      _infoRow(label: 'نوع العملية', value: d['type']!),
                      _infoRow(label: 'المبلغ', value: d['amount']!),
                      _infoRow(label: 'من', value: d['from']!),
                      _infoRow(label: 'إلى', value: d['to']!),
                      _infoRow(label: 'الحالة', value: d['status']!),
                      _infoRow(
                        label: 'إسم المرسل اليه',
                        value: d['receiverName']!,
                        multiLineValue: true,
                      ),
                      _infoRow(label: 'التعليق', value: d['note']!),

                      const SizedBox(height: 64),

                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          children: [
                            _outlineAction(
                              text: 'تحويل خاطئ',
                              icon: Icons.do_not_disturb_on_outlined,
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            _outlineAction(
                              text: 'تذكير',
                              icon: Icons.notifications_none_outlined,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        height: 58,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xffd2d2d2), width: 1),
                            bottom: BorderSide(color: Color(0xffd2d2d2), width: 1),
                          ),
                        ),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            children: [
                              _bottomMiniAction(
                                text: 'تحميل',
                                icon: Icons.arrow_circle_down_outlined,
                              ),
                              Container(width: 1, height: 28, color: const Color(0xffd2d2d2)),
                              _bottomMiniAction(
                                text: 'طباعة',
                                icon: Icons.print_outlined,
                              ),
                              Container(width: 1, height: 28, color: const Color(0xffd2d2d2)),
                              _bottomMiniAction(
                                text: 'مشاركة',
                                icon: Icons.share_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        '2024 © بنك الخرطوم|بنكك حساب',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff303030),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
