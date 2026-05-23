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
    if (v == null) return '23-Apr-2026 20:02:58';
    final text = '$v';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String p(int n) => n.toString().padLeft(2, '0');

    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} ${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
  }

  String _fmtMoney(dynamic v) {
    final n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 9900.00;
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
    final id = '${d['operationNumber'] ?? d['id'] ?? '20018909627'}';
    final amount = _fmtMoney(d['amount'] ?? 9900.00);
    final to = '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0123 0252 2939 0001'}';
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
      _ReceiptRow('رقم العملية', '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? '20018909627'}'),
      _ReceiptRow('التاريخ والوقت', _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-04-23T20:02:58')),
      _ReceiptRow('نوع العملية', '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب آخر'}'),
      _ReceiptRow('المبلغ', _fmtMoney(d['amount'] ?? 9900.00)),
      _ReceiptRow('من', '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '0123 0302 4821 0001'}'),
      _ReceiptRow('إلى', '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0123 0252 2939 0001'}'),
      _ReceiptRow('الحالة', _statusAr(d['status'] ?? 'success')),
      _ReceiptRow('إسم المرسل اليه', '${d['accountName'] ?? d['receiverName'] ?? 'احمد سليمان احمد محمود'}'),
      _ReceiptRow('التعليق', '${d['comment'] ?? d['note'] ?? 'كاش'}'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // شريط التطبيق العلوي (الأحمر)
            Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    Image.asset('assets/img/bankak_logo_big.png', width: 95, fit: BoxFit.contain),
                    const SizedBox(width: 26),
                  ],
                ),
              ),
            ),

            // شريط تفاصيل المعاملة وزر الرجوع (استخدام back.png)
            Container(
              height: 56,
              color: const Color(0xfff8f8f8),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'تفاصيل المعاملة',
                      style: TextStyle(color: Color(0xff2b2b2b), fontSize: 16.5, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
                    ),
                  ),
                  Positioned(
                    left: 14, // Adjusted to match typical back button position in RTL
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

            // الجدول الممتد لعرض الشاشة بالكامل
            Expanded(
              child: Container(
                color: const Color(0xFFF4F5F7),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xffbcbcbc), width: 0.5),
                        bottom: BorderSide(color: Color(0xffbcbcbc), width: 0.5),
                      ),
                    ),
                    child: Column(
                      children: rows.asMap().entries.map((entry) {
                        final isLast = entry.key == rows.length - 1;
                        final r = entry.value;

                        return Container(
                          constraints: const BoxConstraints(minHeight: 42),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            border: Border(bottom: isLast ? BorderSide.none : const BorderSide(color: Color(0xffdcdcdc), width: 0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.label,
                                style: const TextStyle(color: Color(0xff555555), fontWeight: FontWeight.bold, fontSize: 14.5, fontFamily: 'Rubik'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  r.value.isEmpty ? 'N/A' : r.value,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(color: Color(0xff333333), fontWeight: FontWeight.w600, fontSize: 14.0, fontFamily: 'Rubik'),
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
            ),

            // أزرار الإجراءات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(child: _ActionButton(title: 'تحويل خاطئ', icon: 'block_icon.png', onTap: _showSoon)),
                  const SizedBox(width: 14),
                  Expanded(child: _ActionButton(title: 'تذكير', icon: 'notification_white.png', onTap: _showSoon)),
                ],
              ),
            ),

            // شريط التذييل الثلاثي
            Container(
              height: 36,
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
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffe0e3e5), Color(0xffc5c9cc), Color(0xffe4e5e6)],
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
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffd33234), width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Color(0xffd33234), fontSize: 14.5, fontWeight: FontWeight.bold, fontFamily: 'Rubik')),
            const SizedBox(width: 8),
            Icon(_getIconForActionButton(icon), size: 18, color: const Color(0xffd33234)),
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
            Image.asset('assets/img/$icon', width: 16, height: 16, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.share, size: 16, color: Colors.grey)),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(color: Color(0xff666666), fontSize: 13, fontFamily: 'Rubik')),
          ],
        ),
      ),
    );
  }
}
