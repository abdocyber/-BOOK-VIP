import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  bool showToast = false;

  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    return const <String, dynamic>{};
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

  void _showSoon() {
    setState(() => showToast = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => showToast = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذه الميزة قريباً!'))
    );
  }

  void _shareTx(Map<String, dynamic> d) {
    final id = '${d['operationNumber'] ?? d['id'] ?? '20018909275'}';
    final amount = _fmtMoney(d['amount'] ?? 100.00);
    final to = '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '1113025957200001'}';
    final text = 'تفاصيل المعاملة\nرقم العملية: $id\nالمبلغ: $amount\nإلى: $to';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, textAlign: TextAlign.center)));
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
      _ReceiptRow('من', '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '1326253024820001'}'),
      _ReceiptRow('إلى', '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '1113025957200001'}'),
      _ReceiptRow('الحالة', _statusAr(d['status'] ?? 'success')),
      _ReceiptRow('إسم المرسل اليه', '${d['accountName'] ?? d['receiverName'] ?? 'احمد عبد الرحمن حامد عز الدين'}'),
      _ReceiptRow('التعليق', '${d['comment'] ?? d['note'] ?? 'N/A'}'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
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
          width: 140,
          height: 50,
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
                      style: TextStyle(color: Color(0xff2b2b2b), fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Rubik'),
                    ),
                  ),
                  Positioned(
                    right: 14, // زر الرجوع على اليمين
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
            // الجدول الممتد لعرض الشاشة بالكامل بنفس أبعاد وحواف الصورة المرجعية
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
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
                      fontWeight: FontWeight.w500,
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

            // أزرار الإجراءات مع زيادة سمك الإطار
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
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xffdcdcdc), width: 1))),
              child: Row(
                children: [
                  _OptionItem(title: 'مشاركة', icon: 'sharegray.png', onTap: () => _shareTx(d)),
                  const Text('|', style: TextStyle(color: Color(0xffe0e0e0))),
                  _OptionItem(title: 'طباعة', icon: 'printgray.png', onTap: _showSoon),
                  const Text('|', style: TextStyle(color: Color(0xffe0e0e0))),
                  _OptionItem(title: 'تحميل', icon: 'downloadgray.png', onTap: _showSoon),
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
          border: Border.all(color: const Color(0xffd33234), width: 2.5), // زيادة سمك المربع
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForActionButton(icon), size: 18, color: const Color(0xffd33234)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Color(0xffd33234), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Rubik')),
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

class _OptionItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  const _OptionItem({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/$icon', width: 18, height: 18, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.share, size: 18, color: Colors.grey)),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(color: Color(0xff666666), fontSize: 14, fontFamily: 'Rubik')),
          ],
        ),
      ),
    );
  }
}
