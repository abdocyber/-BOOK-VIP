import 'package:flutter/material.dart';
import '../services/session_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // الألوان الرسمية المعتمدة والمطابقة تماماً للصورة المرجعية
  static const Color pageBg = Color(0xfff5f5f5); // الخلفية الرمادية الفاتحة والناعمة للتطبيق
  static const Color titleText = Color(0xff1a1a1a); // تعديل لون الخط إلى الأسود الداكن المطابق للأصل
  static const Color greetingText = Color(0xff2b2b2b); // لون نص الترحيب العلوي
  static const Color headerTop = Color(0xffe31e24); // اللون الأحمر الصافي المشرق بأعلى الهيدر
  static const Color headerBottom = Color(0xffb80006); // اللون الأحمر الداكن بأسفل الهيدر لتأثير التدرج

  @override
  Widget build(BuildContext context) {
    // جلب اسم المستخدم من الـ Session الخاص بك ليعمل بدون مشاكل
    final name = SessionService.current?.fullName ?? 'Abdelrahman Hydar'; //

    // مصفوفة العناصر مع الحفاظ على نفس أسماء أيقونات الـ grid والمسارات الخاصة بك
    final items = <_HomeItem>[
      const _HomeItem('grid_3.png', 'تحويلات', '/transfer'), //
      const _HomeItem('grid_2.png', 'دفع\nفواتير', ''), //
      const _HomeItem('grid_1.png', 'تفاصيل\nالحساب', '/account'), //

      const _HomeItem('grid_6.png', 'طلب الودائع\nالإستثمارية', ''), //
      const _HomeItem('grid_5.png', 'بنككPAY', ''), //
      const _HomeItem('grid_4.png', 'سحب\nبدون بطاقة', ''), //

      const _HomeItem('grid_9.png', 'إدارة البطاقات', ''), //
      const _HomeItem('grid_8.png', 'المعاملات\nالسابقة', '/transactions'), //
      const _HomeItem('grid_7.png', 'إدارة\nالمستفيدين', ''), //

      const _HomeItem('grid_12.png', 'الضبط', ''), //
      const _HomeItem('grid_11.png', 'أمر دفع دائم', ''), //
      const _HomeItem('grid_10.png', 'طلبات', ''), //

      const _HomeItem('grid_13.png', 'التجارة الإلكترونية', ''), //
      const _HomeItem('grid_14.png', 'خدمات العملات\nالأجنبية', ''), //
    ];

    return Directionality(
      textDirection: TextDirection.rtl, //
      child: Scaffold(
        backgroundColor: pageBg, //
        body: LayoutBuilder(
          builder: (context, c) {
            // معالجة الأبعاد وعوامل القياس لتناسب شاشات الأجهزة بالملي كالأصل تماماً
            final appW = c.maxWidth.clamp(0.0, 430.0); //
            final appH = c.maxHeight; //
            final scale = appW / 360.0; //

            double s(double value) => value * scale; //

            return Center(
              child: SizedBox(
                width: appW, //
                height: appH, //
                child: Column(
                  children: [
                    // 1. الهيدر العلوي المحدث بالترتيب الصحيح (الجرس يمين، الطاقة يسار)
                    Container(
                      height: s(78), // ارتفاع الهيدر المتناسق لاحتواء الأيقونات والشعار
                      padding: EdgeInsets.symmetric(horizontal: s(16)), //
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [headerTop, headerBottom], //
                        ),
                      ),
                      child: SafeArea(
                        bottom: false, //
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, //
                          children: [
                            // في بيئة RTL: أول عنصر في الـ Row يظهر في أقصى اليمين (جرس الإشعارات)
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/notify'); //
                              },
                              child: Image.asset(
                                'assets/img/notification_icon.png', //
                                width: s(26), //
                                height: s(26), //
                                fit: BoxFit.contain, //
                              ),
                            ),
                            
                            // شعار بنكك الرئيسي متمركز بالمنتصف تماماً
                            Image.asset(
                              'assets/img/bankak_logo_big.png', //
                              width: s(105), //
                              height: s(48), //
                              fit: BoxFit.contain, //
                            ),
                            
                            // في بيئة RTL: آخر عنصر في الـ Row يظهر في أقصى اليسار (زر تسجيل الخروج/الطاقة)
                            InkWell(
                              onTap: () async {
                                await SessionService.logout(); //
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/login'); //
                                }
                              },
                              child: Image.asset(
                                'assets/img/logout_icon.png', //
                                width: s(26), //
                                height: s(26), //
                                fit: BoxFit.contain, //
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. شريط التحية الفرعي
                    Container(
                      width: double.infinity, //
                      padding: EdgeInsets.only(top: s(14), right: s(16), left: s(16), bottom: s(8)), //
                      color: pageBg, //
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start, //
                        crossAxisAlignment: CrossAxisAlignment.center, //
                        children: [
                          Text(
                            'مساء الخير، ', //
                            style: TextStyle(
                              fontFamily: 'Rubik', //
                              color: greetingText, //
                              fontSize: s(14.0), //
                              fontWeight: FontWeight.w400, //
                            ),
                          ),
                          Flexible(
                            child: Text(
                              name, //
                              maxLines: 1, //
                              overflow: TextOverflow.ellipsis, //
                              textDirection: TextDirection.ltr, //
                              style: TextStyle(
                                fontFamily: 'Rubik', //
                                color: greetingText, //
                                fontSize: s(15.0), //
                                fontWeight: FontWeight.bold, //
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. شبكة الأيقونات المتطابقة هندسياً بالبكسل مع الأبعاد الجديدة المربعة للزر
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(), //
                        padding: EdgeInsets.only(bottom: s(20)), //
                        child: SizedBox(
                          height: s(580), //
                          child: Stack(
                            children: [
                              // الصف الأول
                              _buildSymmetricalItem(context, items[0], s(268), s(10), scale), //
                              _buildSymmetricalItem(context, items[1], s(148), s(10), scale), //
                              _buildSymmetricalItem(context, items[2], s(28), s(10), scale), //

                              // الصف الثاني
                              _buildSymmetricalItem(context, items[3], s(268), s(124), scale), //
                              _buildSymmetricalItem(context, items[4], s(148), s(124), scale), //
                              _buildSymmetricalItem(context, items[5], s(28), s(124), scale), //

                              // الصف الثالث
                              _buildSymmetricalItem(context, items[6], s(268), s(238), scale), //
                              _buildSymmetricalItem(context, items[7], s(148), s(238), scale), //
                              _buildSymmetricalItem(context, items[8], s(28), s(238), scale), //

                              // الصف الرابع
                              _buildSymmetricalItem(context, items[9], s(268), s(352), scale), //
                              _buildSymmetricalItem(context, items[10], s(148), s(352), scale), //
                              _buildSymmetricalItem(context, items[11], s(28), s(352), scale), //

                              // الصف الخامس (تموضع دقيق لليسار والمنتصف كالأصل)
                              _buildSymmetricalItem(context, items[12], s(28), s(466), scale), //
                              _buildSymmetricalItem(context, items[13], s(148), s(466), scale), //
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSymmetricalItem(BuildContext context, _HomeItem item, double left, double top, double scale) {
    return Positioned(
      left: left, //
      top: top, //
      child: _GridItem(
        item: item, //
        scale: scale, //
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final _HomeItem item;
  final double scale;

  const _GridItem({
    required this.item,
    required this.scale,
  });

  double s(double value) => value * scale; //

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.route.isEmpty
          ? null
          : () {
              Navigator.pushNamed(context, item.route); //
            },
      borderRadius: BorderRadius.circular(12), //
      child: SizedBox(
        width: s(76), //
        child: Column(
          mainAxisSize: MainAxisSize.min, //
          crossAxisAlignment: CrossAxisAlignment.center, //
          children: [
            // تعديل أبعاد صورة الأيقونة لتصبح مربعة تماماً (الطول = الارتفاع = 64)
            Image.asset(
              'assets/img/${item.icon}', //
              width: s(76), // العرض الحالي
              height: s(76), // زيادة الارتفاع ليتطابق مع العرض تماماً ويصبح مربعاً
              fit: BoxFit.fill, //
            ),

            SizedBox(height: s(7)), // تباعد متناسق بين الأيقونة والنص

            // النص التوضيحي المكتوب أسفل الأزرار بالخط والحجم واللون الأسود الداكن المطابق تماماً
            SizedBox(
              width: s(96), //
              child: Text(
                item.title, //
                textAlign: TextAlign.center, //
                maxLines: 3, //
                overflow: TextOverflow.visible, //
                style: TextStyle(
                  fontFamily: 'Rubik', //
                  fontSize: s(13.8), //
                  fontWeight: FontWeight.w500, // خط أقل سماكة
                  color: HomePage.titleText, // تطبيق اللون الأسود الداكن الجديد
                  height: 1.15, //
                  letterSpacing: 0, //
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeItem {
  final String icon; //
  final String title; //
  final String route; //

  const _HomeItem(
    this.icon, //
    this.title, //
    this.route, //
  );
}
