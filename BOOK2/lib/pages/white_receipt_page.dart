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
    if (v == null) return '22-May-2026 20:28:42';
    final text = '$v';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String p(int n) => n.toString().padLeft(2, '0');

    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} ${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
  }

  String _fmtMoney(dynamic v) {
    final n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 2000.00;
    return n.toStringAsFixed(2);
  }

  String _statusAr(dynamic v) {
    return '$v' == 'success' || '$v'.isEmpty ? 'نجاح' : '$v';
  }

  void _showSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذه الميزة قريباً!', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Rubik')))
    );
  }

  void _shareTx(Map<String, dynamic> d) {
    final id = '${d['operationNumber'] ?? '20019787159'}';
    final amount = _fmtMoney(d['amount'] ?? 2000.00);
    final to = '${d['to'] ?? '0123 0305 3225 0001'}';
    final text = 'تفاصيل المعاملة\nرقم العملية: $id\nالمبلغ: $amount\nإلى: $to';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Rubik'))));
  }

  @override
  Widget build(BuildContext context) {
    final d = _data(context);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFE31E24),
      statusBarIconBrightness: Brightness.light,
    ));

    final rows = <_ReceiptRow>[
      _ReceiptRow('رقم العملية', '${d['operationNumber'] ?? '20019787159'}'),
      _ReceiptRow('التاريخ والوقت', _fmtDate(d['createdAt'])),
      _ReceiptRow('نوع العملية', '${d['operationType'] ?? 'تحويل إلى حساب آخر'}'),
      _ReceiptRow('المبلغ', _fmtMoney(d['amount'])),
      _ReceiptRow('من', '${d['from'] ?? '0123 0302 4821 0001'}'),
      _ReceiptRow('إلى', '${d['to'] ?? '0123 0305 3225 0001'}'),
      _ReceiptRow('الحالة', _statusAr(d['status'])),
      _ReceiptRow('إسم المرسل اليه', '${d['receiverName'] ?? 'صديق عبدالله بشر عبدالله'}'),
      _ReceiptRow('التعليق', '${d['comment'] ?? 'N/A'}'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: Column(
          children: [
            // AppBar
            Container(
              height: 90,
              padding: const EdgeInsets.only(top: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffe31e24), Color(0xffb80006)],
                ),
              ),
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.menu, color: Colors.white, size: 28),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('بنكك', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 0.9, fontFamily: 'Rubik')),
                        Text('bankak', style: TextStyle(color: Colors.yellow[600], fontSize: 14, fontWeight: FontWeight.w600, height: 0.8, fontFamily: 'Rubik')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Header Row (Transaction Details + Back Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 80), // Placeholder to balance the back button
                  const Text(
                    'تفاصيل المعاملة',
                    style: TextStyle(color: Color(0xff333333), fontSize: 19, fontWeight: FontWeight.w600, fontFamily: 'Rubik'),
                  ),
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Text('رجوع', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Rubik')),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // The Table
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFAAAAAA), width: 1.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: rows.asMap().entries.map((entry) {
                      final r = entry.value;
                      final isLast = entry.key == rows.length - 1;
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    r.value,
                                    style: const TextStyle(color: Color(0xff666666), fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Rubik'),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    r.label,
                                    style: const TextStyle(color: Color(0xff444444), fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast) const Divider(height: 1, color: Color(0xFFAAAAAA), thickness: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Action Buttons (Reminder / Wrong Transfer)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _buildActionButton('تحويل خاطئ', Icons.block, Colors.red)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionButton('تذكير', Icons.notifications_none, Colors.red)),
                ],
              ),
            ),

            // Bottom Options (Share, Print, Download)
            Container(
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xffe0e0e0)))),
              child: Row(
                children: [
                  _buildOption('تحميل', 'assets/img/download.png'), // Updated to download.png
                  _buildVerticalDivider(),
                  _buildOption('طباعة', 'assets/img/printgray.png'),
                  _buildVerticalDivider(),
                  _buildOption('مشاركة', 'assets/img/sharegray.png'),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xffdcdcdc),
              child: const Text(
                '© 2024 بنك الخرطوم|بنكك حساب',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500, fontFamily: 'Rubik'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Rubik')),
        ],
      ),
    );
  }

  Widget _buildOption(String title, String imagePath) {
    return Expanded(
      child: InkWell(
        onTap: _showSoon,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Color(0xff666666), fontSize: 14, fontFamily: 'Rubik')),
              const SizedBox(width: 6),
              Image.asset(imagePath, width: 18, height: 18, color: const Color(0xff666666)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() => Container(height: 20, width: 1, color: Colors.grey[300]);
}

class _ReceiptRow {
  final String label;
  final String value;
  const _ReceiptRow(this.label, this.value);
}
