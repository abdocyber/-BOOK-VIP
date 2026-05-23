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

  @override
  Widget build(BuildContext context) {
    final d = _data(context);
    final appW = MediaQuery.of(context).size.width.clamp(0.0, 430.0);
    final scale = appW / 360.0;
    double s(double value) => value * scale;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFE31E24),
      statusBarIconBrightness: Brightness.light,
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
            // 1. الهيدر الأحمر العلوي
            Container(
              height: s(75),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffe31e24), Color(0xffb80006)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: s(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/img/logout_icon.png', width: s(26), height: s(26), color: Colors.white),
                      Image.asset('assets/img/bankak_logo_big.png', width: s(105), fit: BoxFit.contain),
                      SizedBox(width: s(26)), 
                    ],
                  ),
                ),
              ),
            ),

            // 2. شريط تفاصيل المعاملة وزر رجوع
            Container(
              height: s(56),
              color: const Color(0xfff5f5f5),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'تفاصيل المعاملة',
                      style: TextStyle(color: const Color(0xff1a1a1a), fontSize: s(17.5), fontWeight: FontWeight.w400, fontFamily: 'Rubik'),
                    ),
                  ),
                  Positioned(
                    left: s(10),
                    top: s(9),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/img/back.png', width: s(72), height: s(40), fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),

            // 3. الجدول بتفاصيل المعاملة (Full Width)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xffcccccc), width: 0.2),
                    ),
                  ),
                  child: Column(
                    children: rows.map((r) => Container(
                      height: s(46),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xffcccccc), width: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: EdgeInsets.only(left: s(15)),
                              child: Text(
                                r.value,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black, 
                                  fontSize: s(14.5), 
                                  fontWeight: FontWeight.w400, 
                                  fontFamily: 'Rubik'
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.only(right: s(15)),
                              child: Text(
                                r.label,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: const Color(0xff666666), 
                                  fontSize: s(14.5), 
                                  fontWeight: FontWeight.w500, 
                                  fontFamily: 'Rubik'
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),

            // 4. أزرار الإجراءات باستخدام الأيقونات الأصلية
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(12)),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      title: 'تذكير',
                      icon: 'assets/img/notify_bg.png', // Placeholder for actual icon if found, else use Icon
                      iconData: Icons.notifications_none,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: s(12)),
                  Expanded(
                    child: _ActionButton(
                      title: 'تحويل خاطئ',
                      icon: 'assets/img/block_icon.png',
                      iconData: Icons.block,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            // 5. خيارات المشاركة باستخدام الأيقونات الأصلية
            Container(
              height: s(40),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xffeeeeee), width: 1)),
              ),
              child: Row(
                children: [
                  _FooterOpt(title: 'مشاركة', iconAsset: 'assets/img/sharegray.png', onTap: () {}),
                  _vLine(),
                  _FooterOpt(title: 'طباعة', iconAsset: 'assets/img/printgray.png', onTap: () {}),
                  _vLine(),
                  _FooterOpt(title: 'تحميل', iconAsset: 'assets/img/downloadgray.png', onTap: () {}),
                ],
              ),
            ),

            // 6. التذييل
            Container(
              height: s(32),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffe0e3e5), Color(0xffc5c9cc)],
                ),
              ),
              child: Text(
                '© 2024 بنك الخرطوم|بنكك حساب',
                style: TextStyle(
                  color: const Color(0xff444444), 
                  fontSize: s(12.5), 
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vLine() => Container(width: 1, height: 20, color: const Color(0xffeeeeee));
}

class _ReceiptRow {
  final String label;
  final String value;
  const _ReceiptRow(this.label, this.value);
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String? icon;
  final IconData iconData;
  final VoidCallback onTap;
  const _ActionButton({required this.title, this.icon, required this.iconData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width.clamp(0.0, 430.0) / 360.0;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffd33234), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && icon!.contains('block'))
              Image.asset(icon!, width: 20 * scale, height: 20 * scale, color: const Color(0xffd33234))
            else
              Icon(iconData, color: const Color(0xffd33234), size: 20 * scale),
            const SizedBox(width: 8),
            Text(
              title, 
              style: TextStyle(
                color: const Color(0xffd33234), 
                fontSize: 15 * scale, 
                fontWeight: FontWeight.w500, 
                fontFamily: 'Rubik'
              )
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterOpt extends StatelessWidget {
  final String title;
  final String iconAsset;
  final VoidCallback onTap;
  const _FooterOpt({required this.title, required this.iconAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width.clamp(0.0, 430.0) / 360.0;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconAsset, width: 18 * scale, height: 18 * scale, fit: BoxFit.contain),
            const SizedBox(width: 6),
            Text(
              title, 
              style: TextStyle(
                color: Colors.grey.shade600, 
                fontSize: 13 * scale, 
                fontFamily: 'Rubik'
              )
            ),
          ],
        ),
      ),
    );
  }
}
