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
    return '$v' == 'success' || '$v'.isEmpty ? 'ظ†ط¬ط§ط­' : '$v';
  }

  void _showSoon() {
    setState(() => showToast = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => showToast = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ظ‡ط°ظ‡ ط§ظ„ظ…ظٹط²ط© ظ‚ط±ظٹط¨ط§ظ‹!'))
    );
  }

  void _shareTx(Map<String, dynamic> d) {
    final id = '${d['operationNumber'] ?? d['id'] ?? '20018909275'}';
    final amount = _fmtMoney(d['amount'] ?? 100.00);
    final to = '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '1113025957200001'}';
    final text = 'طھظپط§طµظٹظ„ ط§ظ„ظ…ط¹ط§ظ…ظ„ط©\nط±ظ‚ظ… ط§ظ„ط¹ظ…ظ„ظٹط©: $id\nط§ظ„ظ…ط¨ظ„ط؛: $amount\nط¥ظ„ظ‰: $to';
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
      _ReceiptRow('ط±ظ‚ظ… ط§ظ„ط¹ظ…ظ„ظٹط©', '${d['operationNumber'] ?? d['id'] ?? d['transactionId'] ?? '20018909275'}'),
      _ReceiptRow('ط§ظ„طھط§ط±ظٹط® ظˆط§ظ„ظˆظ‚طھ', _fmtDate(d['createdAt'] ?? d['date'] ?? '2026-05-24T15:36:50')),
      _ReceiptRow('ظ†ظˆط¹ ط§ظ„ط¹ظ…ظ„ظٹط©', '${d['operationType'] ?? d['title'] ?? 'طھط­ظˆظٹظ„ ط¥ظ„ظ‰ ط­ط³ط§ط¨ ط¢ط®ط±'}'),
      _ReceiptRow('ط§ظ„ظ…ط¨ظ„ط؛', _fmtMoney(d['amount'] ?? 100.00)),
      _ReceiptRow('ظ…ظ†', '${d['from'] ?? d['accountFrom'] ?? d['fromAccount'] ?? '1326253024820001'}'),
      _ReceiptRow('ط¥ظ„ظ‰', '${d['to'] ?? d['accountTo'] ?? d['toAccount'] ?? '1113025957200001'}'),
      _ReceiptRow('ط§ظ„ط­ط§ظ„ط©', _statusAr(d['status'] ?? 'success')),
      _ReceiptRow('ط¥ط³ظ… ط§ظ„ظ…ط±ط³ظ„ ط§ظ„ظٹظ‡', '${d['accountName'] ?? d['receiverName'] ?? 'ط§ط­ظ…ط¯ ط¹ط¨ط¯ ط§ظ„ط±ط­ظ…ظ† ط­ط§ظ…ط¯ ط¹ط² ط§ظ„ط¯ظٹظ†'}'),
      _ReceiptRow('ط§ظ„طھط¹ظ„ظٹظ‚', '${d['comment'] ?? d['note'] ?? 'N/A'}'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
           // ط´ط±ظٹط· ط§ظ„طھط·ط¨ظٹظ‚ ط§ظ„ط¹ظ„ظˆظٹ
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

            // ط´ط±ظٹط· طھظپط§طµظٹظ„ ط§ظ„ظ…ط¹ط§ظ…ظ„ط© ظˆط²ط± ط§ظ„ط±ط¬ظˆط¹
            Container(
              height: 56,
              color: const Color(0xfff8f8f8),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'طھظپط§طµظٹظ„ ط§ظ„ظ…ط¹ط§ظ…ظ„ط©',
                      style: TextStyle(color: Color(0xff2b2b2b), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
                    ),
                  ),
                  Positioned(
                    right: 14, // ط²ط± ط§ظ„ط±ط¬ظˆط¹ ط¹ظ„ظ‰ ط§ظ„ظٹظ…ظٹظ†
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
            // ط§ظ„ط¬ط¯ظˆظ„ ط§ظ„ظ…ظ…طھط¯ ظ„ط¹ط±ط¶ ط§ظ„ط´ط§ط´ط© ط¨ط§ظ„ظƒط§ظ…ظ„ ط¨ظ†ظپط³ ط£ط¨ط¹ط§ط¯ ظˆط­ظˆط§ظپ ط§ظ„طµظˆط±ط© ط§ظ„ظ…ط±ط¬ط¹ظٹط©
Expanded(
  child: Container(
    color: const Color(0xFFF4F5F7),
    child: SingleChildScrollView(
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final r = entry.value;
          final isTallRow = r.label == 'ط¥ط³ظ… ط§ظ„ظ…ط±ط³ظ„ ط§ظ„ظٹظ‡';

          return Container(
            height: isTallRow ? 48 : 42,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xff9d9d9d),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  r.label,
                  style: const TextStyle(
                    color: Color(0xff666666),
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    fontFamily: 'Rubik',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    r.value.isEmpty ? 'N/A' : r.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Color(0xff666666),
                      fontWeight: FontWeight.w500,
                      fontSize: 15.0,
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

            // ط£ط²ط±ط§ط± ط§ظ„ط¥ط¬ط±ط§ط،ط§طھ ظ…ط¹ ط²ظٹط§ط¯ط© ط³ظ…ظƒ ط§ظ„ط¥ط·ط§ط±
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(child: _ActionButton(title: 'طھط°ظƒظٹط±', icon: 'notification_white.png', onTap: _showSoon)),
                  const SizedBox(width: 14),
                  Expanded(child: _ActionButton(title: 'طھط­ظˆظٹظ„ ط®ط§ط·ط¦', icon: 'block_icon.png', onTap: _showSoon)),
                ],
              ),
            ),

            // ط´ط±ظٹط· ط§ظ„طھط°ظٹظٹظ„ ط§ظ„ط«ظ„ط§ط«ظٹ
            Container(
              height: 40,
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xffdcdcdc), width: 1))),
              child: Row(
                children: [
                  _OptionItem(title: 'ظ…ط´ط§ط±ظƒط©', icon: 'sharegray.png', onTap: () => _shareTx(d)),
                  const Text('|', style: TextStyle(color: Color(0xffe0e0e0))),
                  _OptionItem(title: 'ط·ط¨ط§ط¹ط©', icon: 'printgray.png', onTap: _showSoon),
                  const Text('|', style: TextStyle(color: Color(0xffe0e0e0))),
                  _OptionItem(title: 'طھط­ظ…ظٹظ„', icon: 'downloadgray.png', onTap: _showSoon),
                ],
              ),
            ),

            // ط´ط±ظٹط· ط§ظ„ط­ظ‚ظˆظ‚ ط§ظ„ط³ظپظ„ظٹ
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
                'آ© 2024 ط¨ظ†ظƒ ط§ظ„ط®ط±ط·ظˆظ…|ط¨ظ†ظƒظƒ ط­ط³ط§ط¨',
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
          border: Border.all(color: const Color(0xffd33234), width: 2.5), // ط²ظٹط§ط¯ط© ط³ظ…ظƒ ط§ظ„ظ…ط±ط¨ط¹
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForActionButton(icon), size: 18, color: const Color(0xffd33234)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Color(0xffd33234), fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Rubik')),
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
