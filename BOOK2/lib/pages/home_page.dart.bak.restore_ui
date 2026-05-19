import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // التوجيه الصحيح للواجهة
      child: Scaffold(
        backgroundColor: const Color(0xfff4f5f7), // درجة الرمادي الفاتح المطابقة للخلفية
        body: Column(
          children: [
            // 1. الشريط العلوي (App Bar) - مطابق للون الأحمر وشعار بنكك
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 12,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xffd32f2f), // الأحمر الرسمي
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الأيقونة الأولى في الـ Row (في بيئة RTL تظهر في أقصى اليمين) - جرس التنبيهات
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    onPressed: () {
                      // مسار التنبيهات
                    },
                  ),
                  // الشعار في المنتصف
                  Image.asset(
                    'assets/img/logo.png', // تأكد من مسار واسم ملف الشعار
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  // الأيقونة الأخيرة في الـ Row (في بيئة RTL تظهر في أقصى اليسار) - زر إيقاف التشغيل
                  IconButton(
                    icon: const Icon(Icons.power_settings_new, color: Colors.white, size: 28),
                    onPressed: () {
                      // مسار تسجيل الخروج
                    },
                  ),
                ],
              ),
            ),

            // 2. نص الترحيب
            Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 24.0, bottom: 24.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 15.5,
                      color: Colors.black87,
                      fontFamily: 'Tajawal', // تأكد من إضافة خط مشابه
                    ),
                    children: [
                      TextSpan(text: 'مساء الخير, '),
                      TextSpan(
                        text: 'مستخدم تجريبي', // يمكن استبدالها بمتغير حساب المستخدم
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. شبكة الأزرار الدقيقة
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // الصف الأول
                    _buildGridRow([
                      _buildAppButton(title: 'تحويلات', icon: Icons.autorenew, onTap: () {}),
                      _buildAppButton(title: 'دفع\nفواتير', icon: Icons.receipt_long, onTap: () {}),
                      _buildAppButton(title: 'تفاصيل\nالحساب', icon: Icons.contact_page_outlined, onTap: () {}),
                    ]),
                    
                    // الصف الثاني
                    _buildGridRow([
                      _buildAppButton(title: 'طلب الودائع\nالاستثمارية', icon: Icons.savings_outlined, onTap: () {}),
                      _buildAppButton(title: 'بنككPAY', icon: Icons.qr_code_scanner, onTap: () {}),
                      _buildAppButton(title: 'سحب\nبدون بطاقة', icon: Icons.atm, onTap: () {}),
                    ]),

                    // الصف الثالث
                    _buildGridRow([
                      _buildAppButton(title: 'إدارة\nالبطاقات', icon: Icons.credit_card, onTap: () {}),
                      _buildAppButton(title: 'المعاملات\nالسابقة', icon: Icons.calendar_month_outlined, onTap: () {}),
                      _buildAppButton(title: 'إدارة\nالمستفيدين', icon: Icons.person_add_alt_1, onTap: () {}),
                    ]),

                    // الصف الرابع
                    _buildGridRow([
                      _buildAppButton(title: 'الضبط', icon: Icons.settings, onTap: () {}),
                      _buildAppButton(title: 'أمر دفع\nدائم', icon: Icons.fact_check_outlined, onTap: () {}),
                      _buildAppButton(title: 'طلبات', icon: Icons.edit_document, onTap: () {}),
                    ]),

                    // الصف الخامس (يحتوي على فراغ في اليمين لمطابقة الترتيب الأصلي)
                    _buildGridRow([
                      const SizedBox(width: 88), // مساحة تعادل عرض زر واحد لدفع الأزرار لليسار
                      _buildAppButton(title: 'خدمات\nالعملات الأجنبية', icon: Icons.currency_exchange, onTap: () {}),
                      _buildAppButton(title: 'التجارة\nالإلكترونية', icon: Icons.shopping_cart_outlined, onTap: () {}),
                    ]),
                    
                    const SizedBox(height: 40), // مساحة أسفل الشاشة
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لضبط المسافات بين الأزرار في كل صف
  Widget _buildGridRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0), // المسافة العمودية بين الصفوف
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // التصميم الدقيق للأزرار (حجم، أبعاد، أيقونات، وتأثير زجاجي)
  Widget _buildAppButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 88, // العرض الكلي للزر مضافاً إليه مساحة النص
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شكل الزر المستطيل
            Container(
              width: 86, // عرض الزر الأحمر (مطابق للأصل العريض)
              height: 62, // ارتفاع الزر الأحمر
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // حواف دائرية خفيفة
                gradient: const LinearGradient(
                  colors: [Color(0xffe53935), Color(0xffb71c1c)], // التدرج الأحمر
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: const Color(0xff8e0000), width: 1.2), // الإطار الداكن
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    offset: Offset(0, 3), // الظل السفلي
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الطبقة الزجاجية العلوية (Gel Effect) - سر المطابقة التصميمية!
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 31, // تغطي النصف العلوي فقط
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8.5)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.4), // لمعان قوي في الأعلى
                            Colors.white.withOpacity(0.0), // يختفي في المنتصف
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // الأيقونة (بحجم كبير ومطابق للصورة الأصلية)
                  Icon(icon, color: Colors.white, size: 36), 
                ],
              ),
            ),
            const SizedBox(height: 8),
            // النص أسفل الزر
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 13.0, // حجم خط متناسق جداً
                fontWeight: FontWeight.w600, // خط شبه عريض ليكون واضحاً
                color: Color(0xff333333),
                height: 1.25, // المسافة بين السطرين في الكلمات المزدوجة
              ),
            ),
          ],
        ),
      ),
    );
  }
}
