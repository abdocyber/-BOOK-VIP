import 'package:flutter/material.dart';
import '../models/receipt.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  bool showPrintSoon = false;

  // استقبال ومعالجة البيانات الحقيقية من الـ Firebase والـ Services الخاصة بك
  ReceiptData _receipt(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;

    if (arg is ReceiptData) {
      return arg;
    }

    return const ReceiptData(
      operationNumber: '20018909627',
      date: '23-Apr-2026 20:02:58',
      fromAccount: '0123 0302 4821 0001',
      toAccount: '0123 0252 2939 0001',
      receiverName: 'احمد سليمان احمد محمود',
      phone: 'N/A',
      note: 'كاش',
      amount: 9900,
    );
  }

  void _printSoon() {
    setState(() => showPrintSoon = true);

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => showPrintSoon = false);
      }
    });
  }

  void _shareReceipt(ReceiptData r) {
    final text = 'إشعار تحويل ناجح\n'
        'رقم العملية: ${r.operationNumber}\n'
        'التاريخ: ${r.date}\n'
        'من حساب: ${r.fromAccount}\n'
        'الى حساب: ${r.toAccount}\n'
        'إسم المرسل اليه: ${r.receiverName}\n'
        'رقم الموبايل: ${r.phone}\n'
        'التعليق: ${r.note}\n'
        'المبلغ: ${_formatAmount(r.amount)}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _formatAmount(double v) {
    final fixed = v.toStringAsFixed(2);
    final parts = fixed.split('.');

    final whole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

    return '$whole.${parts.last}';
  }

  @override
  Widget build(BuildContext context) {
    final r = _receipt(context);

    // مصفوفة البيانات مطابقة تماماً للمسميات الموجودة في لقطة الشاشة الأصلية بالملي
    final rows = [
      ['رقم العملية', r.operationNumber],
      ['التاريخ و الزمن', r.date],
      ['من حساب', r.fromAccount],
      ['الى حساب', r.toAccount],
      ['إسم المرسل اليه', r.receiverName],
      ['رقم الموبايل', r.phone],
      ['التعليق', r.note],
      ['المبلغ', _formatAmount(r.amount)],
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth.clamp(0.0, 412.0);
              final isSmall = w <= 360;

              final appHeight = isSmall ? 800.0 : 852.0;
              final topPadding = isSmall ? 40.0 : 55.0;
              final iconSize = isSmall ? 130.0 : 145.0;
              final titleSize = isSmall ? 21.0 : 23.0;
              final tableWidth = w * (isSmall ? .90 : .88);
              final rowHeight = isSmall ? 32.0 : 35.0;
              final labelSize = isSmall ? 14.5 : 15.5;
              final valueSize = isSmall ? 14.0 : 15.0;
              final cellHPadding = isSmall ? 10.0 : 12.0;
              final okTop = isSmall ? 25.0 : 32.0;
              final midWidth = w * (isSmall ? .90 : .88);

              return Container(
                width: w,
                constraints: BoxConstraints(minHeight: appHeight),
                padding: EdgeInsets.only(
                  top: topPadding,
                  bottom: 10,
                ),
                // استخدام نفس اسم ملف الخلفية المرفوع تماماً لمطابقة التدرج البصري 100%
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/successscreenbg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    // 1. الدائرة البيضاء وبداخلها أيقونة الصح المرفقة (sucesstick.png)
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(iconSize * 0.24), 
                      child: Image.asset(
                        'assets/img/sucesstick.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. عنوان الإشعار "تحويلات"
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'تحويلات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          fontFamily: 'Rubik',
                        ),
                      ),
                    ),

                    // 3. جدول البيانات المتطابق (إطار أبيض ونصوص بيضاء بالكامل)
                    Container(
                      width: tableWidth,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1.3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: rows.asMap().entries.map((entry) {
                          final isLast = entry.key == rows.length - 1;
                          final e = entry.value;

                          return Container(
                            height: rowHeight,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: isLast
                                    ? BorderSide.none
                                    : const BorderSide(
                                        color: Colors.white,
                                        width: 1.1,
                                      ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // يمين الصف: عنوان الحقل باللون الأبيض الناصع
                                SizedBox(
                                  width: tableWidth * 0.35,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: cellHPadding),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        e[0],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: labelSize,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Rubik',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // يسار الصف: المعطيات مصفوفة يساراً (LTR) باللون الأبيض الناصع
                                Expanded(
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: cellHPadding),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          e[1],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: valueSize,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Rubik',
                                          ),
                                        ),
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

                    SizedBox(height: okTop),

                    // 4. زر موافق الأصلي المستطيل اللامع (sucessbutton.png)
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/sendto');
                        }
                      },
                      child: Container(
                        width: 145, 
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/sucessbutton.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'موافق',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(), // تمديد مرن لدفع الأزرار السفلية وشريط التذييل لقاع الشاشة بالملي

                    // 5. الأزرار الفرعية (تحويل يميناً وإضافة يساراً مطابقة تماماً لموضع لقطة الشاشة)
                    SizedBox(
                      width: midWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSmallIconBox(
                            img: 'newaddtransfernow.png',
                            title: 'تحويل',
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/transfer');
                            },
                          ),
                          _buildSmallIconBox(
                            img: 'newaddbenf.png',
                            title: 'إضافة',
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/transactions');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 6. شريط التذييل الثلاثي (مشاركة، طباعة، تحميل) بالأيقونات المرفوعة
                    SizedBox(
                      width: w,
                      height: 46,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFF146A12), 
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // تم مطابقة موضع الأيقونة لتظهر على يمين النص تماماً كالصورة المرفقة
                            _buildFooterItem(
                              title: 'مشاركة',
                              img: 'share.png',
                              fontSize: 12,
                              onTap: () => _shareReceipt(r),
                            ),
                            _buildFooterItem(
                              title: 'طباعة',
                              img: 'print.png',
                              fontSize: 12,
                              onTap: _printSoon,
                            ),
                            _buildFooterItem(
                              title: 'تحميل',
                              img: 'download.png',
                              fontSize: 12,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('قريباً', textAlign: TextAlign.center),
                                  ),
                                );
                              },
                              last: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 7. شريط الحقوق السفلي الملاصق للنهاية
                    const Text(
                      '© 2024 بنك الخرطوم|بنكك حساب',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSmallIconBox({required String img, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 60,
          child: Column(
            children: [
              Image.asset(
                'assets/img/$img',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.blur_circular, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Rubik',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterItem({required String title, required String img, required double fontSize, required VoidCallback onTap, bool last = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: last
                  ? BorderSide.none
                  : const BorderSide(
                      color: Colors.white,
                      width: 1.2,
                    ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // وضع صورة الأيقونة أولاً ثم مسافة ثم النص لكي تظهر الأيقونة على يمين الكلمة تحت نمط الـ RTL
              Image.asset(
                'assets/img/$img',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.extension, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Rubik',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}