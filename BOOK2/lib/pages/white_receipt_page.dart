import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection; // تم إخفاء التعارض هنا

class WhiteReceiptPage extends StatefulWidget {
  const WhiteReceiptPage({super.key}); // تم إرجاع الـ Constructor لشكله الأصلي لكي لا يضرب في main.dart

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  // ألوان التصميم
  final Color primaryRed = const Color(0xFFC62828);
  final Color goldColor = const Color(0xFFD4AF37);
  final Color greyTextColor = const Color(0xFF757575);
  final Color blackTextColor = const Color(0xFF212121);
  final Color dividerColor = const Color(0xFFEEEEEE);

  // دالة لجلب البيانات من الـ Route (تحافظ على منطق قاعدة البيانات الخاص بك)
  Map<String, dynamic> _data(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) return arg.cast<String, dynamic>();
    // إذا كنت تمرر Object من نوع ReceiptData، يمكنك استخراج بياناته هنا
    return const <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final dbData = _data(context);

    // جلب البيانات مع توفير قيم افتراضية للمطابقة
    final String referenceNumber = '${dbData['ref_no'] ?? dbData['operationNumber'] ?? dbData['id'] ?? '20018909627'}';
    final String rawDate = '${dbData['createdAt'] ?? dbData['date'] ?? DateTime.now().toString()}';
    final String fromAccount = '${dbData['from'] ?? dbData['accountFrom'] ?? '0123 0302 4821 0001'}';
    final String toAccount = '${dbData['to'] ?? dbData['accountTo'] ?? '0123 0252 2939 0001'}';
    final String recipientName = '${dbData['accountName'] ?? dbData['receiverName'] ?? 'احمد سليمان احمد محمود'}';
    final String mobileNumber = '${dbData['mobile'] ?? dbData['phone'] ?? '0912345678'}';
    final double amount = (dbData['amount'] is num) ? (dbData['amount'] as num).toDouble() : (double.tryParse('${dbData['amount']}'.replaceAll(',', '')) ?? 9900.00);
    final String comment = '${dbData['comment'] ?? dbData['note'] ?? 'كاش'}';
    final String rawStatus = '${dbData['status'] ?? 'نجاح'}';

    // تنسيق التاريخ والوقت
    DateTime transactionDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    // يجب تعيين locale إلى ar إذا كنت تستخدم intl package لدعم اللغة العربية
    String formattedDate = DateFormat('dd أبريل yyyy، HH:mm:ss', 'ar').format(transactionDate);

    // تنسيق المبلغ
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '');
    String formattedAmount = currencyFormatter.format(amount);

    // تنسيق الحالة
    String status = (rawStatus.toLowerCase() == 'success' || rawStatus.isEmpty) ? 'نجاح' : rawStatus;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryRed,
                primaryRed.withOpacity(0.8),
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: const Icon(Icons.menu, color: Colors.white),
            ),
            title: Image.asset(
              'assets/images/bankak_logo.png', // تأكد من مسار الشعار
              height: 40,
              errorBuilder: (_, __, ___) => const Text('بنكك', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            centerTitle: true,
            actions: const [
              Icon(Icons.power_settings_new, color: Colors.white),
              SizedBox(width: 15),
            ],
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // تحديد اتجاه النص العربي من اليمين لليسار
        child: Column(
          children: [
            // تاريخ ووقت المعاملة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              color: Colors.white,
              child: Text(
                'تاريخ/وقت المعاملة: $formattedDate',
                style: TextStyle(color: blackTextColor, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            
            // عنوان تفاصيل المعاملة
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'تفاصيل المعاملة',
                style: TextStyle(
                  color: blackTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rubik',
                ),
              ),
            ),

            // البطاقة التي تحتوي على البيانات
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildInfoRow('الرقم المرجعي', referenceNumber, isBoldValue: true),
                      _buildDivider(),
                      _buildInfoRow('من حساب', fromAccount),
                      _buildDivider(),
                      _buildInfoRow('إلى حساب', toAccount),
                      _buildDivider(),
                      _buildInfoRow('اسم المستلم', recipientName),
                      _buildDivider(),
                      _buildInfoRow('رقم الموبايل', mobileNumber),
                      _buildDivider(),
                      _buildAmountRow('المبلغ', formattedAmount),
                      _buildDivider(),
                      _buildInfoRow('التعليق', comment),
                      _buildDivider(),
                      _buildStatusRow('الحالة', status),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // الشريط السفلي للعمليات
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: primaryRed,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomActionButton('assets/images/ic_incorrect_trans.png', Icons.block, 'تحويل خاطئ'),
            _buildBottomActionButton('assets/images/ic_reminder.png', Icons.notifications_active, 'تذكير'),
            _buildBottomActionButton('assets/images/ic_print.png', Icons.print, 'طباعة'),
            _buildBottomActionButton('assets/images/ic_share.png', Icons.share, 'مشاركة'),
            _buildBottomActionButton('assets/images/ic_download.png', Icons.file_download, 'تحميل'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: greyTextColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: blackTextColor,
                fontSize: 14,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.left, // محاذاة لليسار
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: greyTextColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(color: blackTextColor, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: 'SDG',
                    style: TextStyle(color: greyTextColor, fontSize: 12, fontFamily: 'Rubik'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: greyTextColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: dividerColor,
      height: 1,
      thickness: 1,
      indent: 15,
      endIndent: 15,
    );
  }

  Widget _buildBottomActionButton(String assetPath, IconData fallbackIcon, String label) {
    return InkWell(
      onTap: () {
        // يمكنك إضافة الأوامر (مثل التقاط الشاشة والمشاركة) هنا لاحقاً
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الضغط على $label', textAlign: TextAlign.center)));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            height: 24,
            color: Colors.white,
            errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
