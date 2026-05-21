import 'package:flutter/material.dart';
import '../models/receipt.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  ReceiptData _receipt(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ReceiptData) return arg;

    return const ReceiptData(
      operationNumber: '20019741802',
      date: '21-May-2026 16:39:17',
      fromAccount: '0123 0302 4821 0001',
      toAccount: '0033 0443 6676 0001',
      receiverName: 'مستلم',
      phone: 'N/A',
      note: 'N/A',
      amount: 0.00,
    );
  }

  void _showSoon() {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        right: 0,
        bottom: 92,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xff3b2f2f),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'قريباً...',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/img/icon.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/img/white_logo_n.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.apps,
                          color: Color(0xffed1c24),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _receipt(context);

    final rows = [
      ['رقم العملية', r.operationNumber],
      ['التاريخ والوقت', r.date],
      ['من حساب', r.fromAccount],
      ['الى حساب', r.toAccount],
      ['إسم المرسل اليه', r.receiverName],
      ['رقم الموبايل', r.phone],
      ['التعليق', r.note],
      ['المبلغ', '${r.amount.toStringAsFixed(2)} SDG'],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff68b835), Color(0xff248316)],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xff248316),
                          size: 70,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'تحويلات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: rows.map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SizedBox(
                                    width: 155,
                                    child: Text(
                                      e[0],
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        e[1],
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      InkWell(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/home'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'موافق',
                            style: TextStyle(
                              color: Color(0xff248316),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconBtn('إضافة', Icons.person_add, () {}),
                    _iconBtn('تحويل', Icons.currency_exchange, () {}),
                  ],
                ),
              ),

              Container(
                height: 45,
                color: const Color(0xff126815),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _footerBtn('مشاركة', Icons.share, () {}),
                    _footerBtn('طباعة', Icons.print, _showSoon),
                    _footerBtn('تحميل', Icons.download, () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(String t, IconData i, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Column(
        children: [
          Icon(i, color: Colors.white, size: 30),
          Text(t, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _footerBtn(String t, IconData i, VoidCallback tap) {
    String? assetIcon;

    if (t == 'مشاركة') {
      assetIcon = 'sharegray.png';
    } else if (t == 'طباعة') {
      assetIcon = 'printgray.png';
    } else if (t == 'تحميل') {
      assetIcon = 'downloadgray.png';
    }

    return InkWell(
      onTap: tap,
      child: Row(
        children: [
          Text(
            t,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          if (assetIcon != null)
            Image.asset(
              'assets/img/$assetIcon',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(i, color: Colors.white, size: 24),
            )
          else
            Icon(i, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
