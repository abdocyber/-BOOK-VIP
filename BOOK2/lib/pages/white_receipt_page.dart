import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Assuming these services are correctly implemented and available
// import '../services/firebase_service.dart';
// import '../services/session_service.dart';
// import '../services/app_state.dart';

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key});

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  bool showToast = false;

  // Placeholder for dynamic data, to be replaced by actual data from arguments
  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '23-Apr-2026 20:02:58'; // Default value from image
    final text = '$v';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String p(int n) => n.toString().padLeft(2, '0');

    return '${p(parsed.day)}-${months[parsed.month - 1]}-${parsed.year} ${p(parsed.hour)}:${p(parsed.minute)}:${p(parsed.second)}';
  }

  String _fmtMoney(dynamic v) {
    final n = v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '')) ?? 9900.00; // Default value from image
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
    // In a real app, this would trigger a toast or similar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('هذه الميزة قريباً!'))
    );
  }

  void _shareTx(Map<String, dynamic> d) {
    final id = '${d['operationNumber'] ?? d['id'] ?? '20018909627'}'; // Default value from image
    final amount = _fmtMoney(d['amount'] ?? 9900.00); // Default value from image
    final to = '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0123 0252 2939 0001'}'; // Default value from image
    final text = 'تفاصيل المعاملة\nرقم العملية: $id\nالمبلغ: $amount\nإلى: $to';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, textAlign: TextAlign.center)));
    // In a real app, this would use a sharing package like share_plus
  }

  @override
  Widget build(BuildContext context) {
    final d = _data(context);

    // Set status bar color to match the app bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFE31E24), // Red color from the design
      statusBarIconBrightness: Brightness.light, // For light icons on dark background
      statusBarBrightness: Brightness.dark, // For iOS
    ));

    final rows = <_ReceiptRow>[
      _ReceiptRow('رقم العملية', '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? '20018909627'}'),
      _ReceiptRow('التاريخ والوقت', _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-04-23T20:02:58')), // Default from image
      _ReceiptRow('نوع العملية', '${d['operationType'] ?? d['title'] ?? 'تحويل إلى حساب آخر'}'),
      _ReceiptRow('المبلغ', _fmtMoney(d['amount'] ?? 9900.00)),
      _ReceiptRow('من', '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '0123 0302 4821 0001'}'),
      _ReceiptRow('إلى', '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '0123 0252 2939 0001'}'),
      _ReceiptRow('الحالة', _statusAr(d['status'] ?? 'success')), // Default from image
      _ReceiptRow('إسم المرسل اليه', '${d['accountName'] ?? d['receiverName'] ?? 'احمد سليمان احمد محمود'}'), // Default from image
      _ReceiptRow('التعليق', '${d['comment'] ?? d['note'] ?? 'كاش'}'), // Default from image
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white, // Overall background is white
        body: Column(
          children: [
            // شريط التطبيق العلوي (الأحمر)
            Container(
              height: 68, // Height from visual estimation
              padding: const EdgeInsets.symmetric(horizontal: 16), // Padding from visual estimation
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffe31e24), Color(0xffb80006)], // Colors from image analysis
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu icon
                    // Using a placeholder Icon for now, replace with actual asset if available
                    const Icon(Icons.menu, color: Colors.white, size: 26),
                    // Image.asset('assets/img/dehaze_24.png', width: 26, height: 26, fit: BoxFit.contain),
                    // Bankak logo
                    Image.asset('assets/img/bankak_logo_big.png', width: 95, fit: BoxFit.contain), // Placeholder
                    const SizedBox(width: 26), // To balance the menu icon on the left
                  ],
                ),
              ),
            ),

            // شريط تفاصيل المعاملة الفرعي (الرمادي الفاتح) وزر الرجوع
            Container(
              height: 56, // Height from visual estimation
              color: const Color(0xfff8f8f8), // Background color from image analysis
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'تفاصيل المعاملة',
                      style: TextStyle(color: Color(0xff2b2b2b), fontSize: 16.5, fontWeight: FontWeight.bold, fontFamily: 'Rubik'), // Font style from image analysis
                    ),
                  ),
                  Positioned(
                    right: 14, // Position from visual estimation
                    top: 8, // Position from visual estimation
                    child: InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      // Using a placeholder Icon for now, replace with actual asset if available
                      child: Container(
                        width: 70, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'رجوع >',
                            style: TextStyle(color: Color(0xFFE31E24), fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Image.asset('assets/img/back.png', width: 70, height: 40, fit: BoxFit.contain), // Placeholder
                    ),
                  ),
                ],
              ),
            ),

            // المستطيل الأبيض الرئيسي للجدول
            Expanded(
              child: Container(
                color: const Color(0xFFF4F5F7), // Light gray background for the area outside the white box
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // White background for the table itself
                      borderRadius: BorderRadius.circular(6), // Border radius from image analysis
                      border: Border.all(color: const Color(0xffbcbcbc), width: 1.2), // Border from image analysis
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: rows.asMap().entries.map((entry) {
                        final isLast = entry.key == rows.length - 1;
                        final r = entry.value;

                        return Container(
                          constraints: const BoxConstraints(minHeight: 42), // Row height from visual estimation
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), // Padding from visual estimation
                          decoration: BoxDecoration(
                            border: Border(bottom: isLast ? BorderSide.none : const BorderSide(color: Color(0xffdcdcdc), width: 1.0)), // Separator color and width
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.label,
                                style: const TextStyle(color: Color(0xff555555), fontWeight: FontWeight.bold, fontSize: 14.5, fontFamily: 'Rubik'), // Font style from image analysis
                              ),
                              const SizedBox(width: 16), // Spacing between label and value
                              Expanded(
                                child: Text(
                                  r.value.isEmpty ? 'N/A' : r.value,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left, // Values are left-aligned in RTL
                                  style: const TextStyle(color: Color(0xff333333), fontWeight: FontWeight.w600, fontSize: 14.0, fontFamily: 'Rubik'), // Font style from image analysis
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

            // أزرار الإجراءات (تحويل خاطئ، تذكير)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Padding from visual estimation
              child: Row(
                children: [
                  Expanded(child: _ActionButton(title: 'تحويل خاطئ', icon: 'block_icon.png', onTap: _showSoon)), // Placeholder
                  const SizedBox(width: 14), // Spacing between buttons
                  Expanded(child: _ActionButton(title: 'تذكير', icon: 'notification_white.png', onTap: _showSoon)), // Placeholder
                ],
              ),
            ),

            // شريط التذييل الثلاثي (مشاركة، طباعة، تحميل)
            Container(
              height: 36, // Height from visual estimation
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xffdcdcdc), width: 1))), // Border and background color
              child: Row(
                children: [
                  _OptionItem(title: 'مشاركة', icon: 'sharegray.png', onTap: () => _shareTx(d)), // Placeholder
                  const Text('|', style: TextStyle(color: Color(0xffe0e0e0))), // Separator color
                  _OptionItem(title: 'طباعة', icon: 'printgray.png', onTap: _showSoon), // Placeholder
                  const Text('|', style: TextStyle(color: Color(0xffe0e0e0))), // Separator color
                  _OptionItem(title: 'تحميل', icon: 'downloadgray.png', onTap: _showSoon), // Placeholder
                ],
              ),
            ),

            // شريط الحقوق السفلي
            Container(
              height: 30, // Height from visual estimation
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffe0e3e5), Color(0xffc5c9cc), Color(0xffe4e5e6)], // Gradient colors from image analysis
                ),
              ),
              child: const Text(
                '© 2024 بنك الخرطوم|بنكك حساب',
                style: TextStyle(color: Color(0xff222222), fontSize: 12, fontFamily: 'Rubik', fontWeight: FontWeight.w500), // Font style from image analysis
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
      borderRadius: BorderRadius.circular(12), // Border radius from image analysis
      child: Container(
        height: 42, // Height from visual estimation
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffd33234), width: 2.0), // Border color and width from image analysis
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Color(0xffd33234), fontSize: 14.5, fontWeight: FontWeight.bold, fontFamily: 'Rubik')), // Font style from image analysis
            const SizedBox(width: 8), // Spacing between text and icon
            // Using a placeholder Icon for now, replace with actual asset if available
            // Image.asset('assets/img/$icon', width: 18, height: 18, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.circle, size: 10, color: Color(0xffd33234))),
            Icon(_getIconForActionButton(icon), size: 18, color: const Color(0xffd33234)),
          ],
        ),
      ),
    );
  }

  IconData _getIconForActionButton(String iconName) {
    switch (iconName) {
      case 'block_icon.png':
        return Icons.block;
      case 'notification_white.png':
        return Icons.notifications;
      default:
        return Icons.error;
    }
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
            // Using a placeholder Icon for now, replace with actual asset if available
            // Image.asset('assets/img/$icon', width: 16, height: 16, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.share, size: 14, color: Colors.grey)),
            Icon(_getIconForOptionItem(icon), size: 16, color: Colors.grey),
            const SizedBox(width: 6), // Spacing between icon and text
            Text(title, style: const TextStyle(color: Color(0xff555555), fontSize: 13.0, fontWeight: FontWeight.w500, fontFamily: 'Rubik')), // Font style from image analysis
          ],
        ),
      ),
    );
  }

  IconData _getIconForOptionItem(String iconName) {
    switch (iconName) {
      case 'sharegray.png':
        return Icons.share;
      case 'printgray.png':
        return Icons.print;
      case 'downloadgray.png':
        return Icons.download;
      default:
        return Icons.error;
    }
  }
}
