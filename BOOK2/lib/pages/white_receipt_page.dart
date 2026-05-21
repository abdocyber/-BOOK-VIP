import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ستحتاج لإضافة هذا الباكيج لتنسيق التاريخ والعملة

class WhiteReceiptPage extends StatefulWidget {
  // هنا يتم تمرير البيانات القادمة من قاعدة البيانات عبر الـ Constructor
  final Map<String, dynamic> transactionData;

  const WhiteReceiptPage({Key? key, required this.transactionData}) : super(key: key);

  @override
  State<WhiteReceiptPage> createState() => _WhiteReceiptPageState();
}

class _WhiteReceiptPageState extends State<WhiteReceiptPage> {
  // ألوان التصميم بناءً على الصورة
  final Color primaryRed = const Color(0xFFC62828);
  final Color goldColor = const Color(0xFFD4AF37);
  final Color greyTextColor = const Color(0xFF757575);
  final Color blackTextColor = const Color(0xFF212121);
  final Color dividerColor = const Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    // بفرض أن البيانات قادمة بهذا الشكل من قاعدة البيانات، نقوم بتهيئتها
    // في حال عدم وجود بيانات، نضع قيماً افتراضية (Mock Data) المطابقة للصورة للتجربة
    final String referenceNumber = widget.transactionData['ref_no'] ?? '20018909627';
    final DateTime transactionDate = widget.transactionData['date'] ?? DateTime.now();
    final String fromAccount = widget.transactionData['from_acc'] ?? '0123 0302 4821 0001';
    final String toAccount = widget.transactionData['to_acc'] ?? '0123 0252 2939 0001';
    final String recipientName = widget.transactionData['recipient_name'] ?? 'احمد سليمان احمد محمود';
    final String mobileNumber = widget.transactionData['mobile_no'] ?? '0912345678';
    final double amount = widget.transactionData['amount'] ?? 9900.00;
    final String comment = widget.transactionData['comment'] ?? 'كاش';
    final String status = widget.transactionData['status'] ?? 'نجاح';

    // تنسيق التاريخ والوقت
    String formattedDate = DateFormat('dd أبريل yyyy، HH:mm:ss', 'ar').format(transactionDate);
    // تنسيق المبلغ
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '');
    String formattedAmount = currencyFormatter.format(amount);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // ارتفاع الـ AppBar العلوي
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
            leading: const Icon(Icons.menu, color: Colors.white),
            title: Image.asset(
              'assets/images/bankak_logo.png', // تأكد من إضافة الشعار في المسار الصحيح
              height: 40,
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
        textDirection: TextDirection.rtl, // لضمان اتجاه النص العربي من اليمين لليسار
        child: Column(
          children: [
            // قسم التاريخ والوقت أسفل الـ AppBar
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
            
            // العنوان الرئيسي
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'تفاصيل المعاملة',
                style: TextStyle(
                  color: blackTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rubik', // تأكد من تعريف الخط في pubspec.yaml
                ),
              ),
            ),

            // البطاقة البيضاء التي تحتوي على التفاصيل (Container مع Shadow وبوردر خفيف)
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
                    physics: const NeverScrollableScrollPhysics(), // لمنع التمرير داخل البطاقة نفسها
                    children: [
                      // بناء الصفوف بناءً على التصميم
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
                      // ستايل خاص للمبلغ
                      _buildAmountRow('المبلغ', formattedAmount),
                      _buildDivider(),
                      _buildInfoRow('التعليق', comment),
                      _buildDivider(),
                      // ستايل خاص للحالة (لون أخضر)
                      _buildStatusRow('الحالة', status),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // الشريط السفلي الأحمر (Bottom Navigation Bar)
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
            _buildBottomActionButton('assets/images/ic_incorrect_trans.png', 'تحويل خاطئ'),
            _buildBottomActionButton('assets/images/ic_reminder.png', 'تذكير'),
            _buildBottomActionButton('assets/images/ic_print.png', 'طباعة'),
            _buildBottomActionButton('assets/images/ic_share.png', 'مشاركة'),
            _buildBottomActionButton('assets/images/ic_download.png', 'تحميل'),
          ],
        ),
      ),
    );
  }

  // ويجت لبناء الصف القياسي (مفتاح : قيمة)
  Widget _buildInfoRow(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          // التسمية (يمين)
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: greyTextColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          // القيمة (يسار)
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: blackTextColor,
                fontSize: 14,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.left, // محاذاة النص لليسار كما في الصورة
            ),
          ),
        ],
      ),
    );
  }

  // ويجت خاص بصف المبلغ لتلوين العملة وتضخيم الرقم
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
                    style: TextStyle(color: blackTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: 'SDG',
                    style: TextStyle(color: greyTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويجت خاص بصف الحالة لتلوين كلمة "نجاح" بالأخضر
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
                  color: Colors.green, // اللون الأخضر للحالة
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

  // ويجت لبناء الخط الفاصل بين الصفوف
  Widget _buildDivider() {
    return Divider(
      color: dividerColor,
      height: 1,
      thickness: 1,
      indent: 15, // بداية الخط بعد مسافة من اليمين
      endIndent: 15, // نهاية الخط قبل مسافة من اليسار
    );
  }

  // ويجت لبناء أزرار الحركة في الشريط السفلي
  Widget _buildBottomActionButton(String assetPath, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          assetPath, // تأكد من إضافة الأيقونات في المسار الصحيح
          height: 24,
          color: Colors.white, // تلوين الأيقونات باللون الأبيض
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }
}

// مثال لكيفية استدعاء هذه الصفحة وتمرير البيانات الحقيقية إليها
void navigateToReceipt(BuildContext context) {
  // هذه البيانات يفترض أن تأتي من نتيجة استعلام قاعدة البيانات بعد نجاح التحويل
  Map<String, dynamic> dbData = {
    'ref_no': '20018909627',
    'date': DateTime(2026, 4, 23, 20, 2, 58), // تاريخ حقيقي
    'from_acc': '0123 0302 4821 0001',
    'to_acc': '0123 0252 2939 0001',
    'recipient_name': 'احمد سليمان احمد محمود',
    'mobile_no': '0912345678',
    'amount': 9900.00,
    'comment': 'كاش',
    'status': 'نجاح',
  };

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WhiteReceiptPage(transactionData: dbData),
    ),
  );
}
