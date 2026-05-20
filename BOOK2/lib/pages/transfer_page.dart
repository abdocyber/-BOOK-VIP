import 'package:flutter/material.dart';
import '../main.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});
  @override
  Widget build(BuildContext context) {
    final opts = [
      ['ftothacc.png', 'تحويل لحسابات بنك الخرطوم', '/transfer_bank'],
      ['ftmobileacc.png', 'الدفع عبر الموبايل', ''],
      ['cardsupplementary.png', 'تحويل لبنك آخر باستخدام رقم البطاقة', ''],
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            color: const Color(0xfff4f4f4),
            child: Column(
              children: [
                Container(height: 88, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xffff0b0b), Color(0xffc91c22)])), child: Stack(children: [Center(child: Image.asset('assets/img/bankak_logo_big.png', width: 135)), Positioned(right: 18, bottom: 18, child: IconButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), icon: const Icon(Icons.menu, color: Colors.white, size: 36)))])),
                SizedBox(height: 72, child: Stack(children: [const Center(child: Text('تحويلات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500))), Positioned(right: 15, top: 13, child: InkWell(onTap: () => safeBack(context, '/home'), child: Image.asset('assets/img/back.png', width: 75, height: 40)))])),
                const SizedBox(height: 13),
                ...opts.map((o) => Padding(
                      padding: const EdgeInsets.fromLTRB(17, 0, 17, 16),
                      child: InkWell(
                        onTap: o[2].isEmpty ? null : () => Navigator.pushNamed(context, o[2]),
                        child: Container(
                          height: 67,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2), border: Border.all(color: const Color(0xffdddddd)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.13), blurRadius: 4, offset: const Offset(0, 2))]),
                          child: Row(children: [const SizedBox(width: 17), Image.asset('assets/img/${o[0]}', width: 43, height: 43), Expanded(child: Text(o[1], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.black))), Image.asset('assets/img/listarr.png', width: 28, height: 28), const SizedBox(width: 17)]),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
