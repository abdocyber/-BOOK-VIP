import 'package:flutter/material.dart';
import '../services/session_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = SessionService.current?.fullName ?? 'مستخدم تجريبي';

    // استخدام صور الأزرار الأصلية الخاصة بك بشكل كامل
    final items = <_HomeItem>[
      const _HomeItem('grid_3.png', 'تحويلات', '/transfer'),
      const _HomeItem('grid_2.png', 'دفع\nفواتير', ''),
      const _HomeItem('grid_1.png', 'تفاصيل\nالحساب', '/account'),

      const _HomeItem('grid_6.png', 'طلب الودائع\nالاستثمارية', ''),
      const _HomeItem('grid_5.png', 'بنككPAY', ''),
      const _HomeItem('grid_4.png', 'سحب\nبدون بطاقة', ''),

      const _HomeItem('grid_9.png', 'إدارة\nالبطاقات', ''),
      const _HomeItem('grid_8.png', 'المعاملات\nالسابقة', '/transactions'),
      const _HomeItem('grid_7.png', 'إدارة\nالمستفيدين', ''),

      const _HomeItem('grid_12.png', 'الضبط', ''),
      const _HomeItem('grid_11.png', 'أمر دفع\nدائم', ''),
      const _HomeItem('grid_10.png', 'طلبات', ''),

      const _HomeItem('grid_14.png', 'خدمات\nالعملات الأجنبية', ''),
      const _HomeItem('grid_13.png', 'التجارة\nالإلكترونية', ''),
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // التوجيه الصحيح
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        body: LayoutBuilder(
          builder: (context, c) {
            final appW = c.maxWidth.clamp(0.0, 430.0);
            final appH = c.maxHeight;
            final scale = (appW / 360.0).clamp(0.8, 1.2);

            double s(double value) => value * scale;

            return Center(
              child: SizedBox(
                width: appW,
                height: appH,
                child: Column(
                  children: [
                    // 1. الشريط العلوي (الأيقونات كما في الصورة الجديدة 1000069040)
                    Container(
                      height: s(76),
                      padding: EdgeInsets.only(top: s(24), left: s(16), right: s(16)),
                      color: const Color(0xFFE31E24), // الأحمر المطابق
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // أيقونة جرس التنبيهات على اليمين في وضع الـ RTL
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/notify');
                              },
                              child: Icon(Icons.notifications_none, color: Colors.white, size: s(28)),
                            ),
                            // أيقونة إيقاف التشغيل على اليسار
                            InkWell(
                              onTap: () async {
                                await SessionService.logout();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                              },
                              child: Icon(Icons.power_settings_new, color: Colors.white, size: s(28)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. التحية
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: s(16), right: s(20), left: s(20), bottom: s(18)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'مساء الخير, ',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              color: const Color(0xFF333333),
                              fontSize: s(14.0),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                color: const Color(0xFF111111),
                                fontSize: s(14.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. شبكة الأزرار باستخدام صورك المرفوعة والمقاسات المطابقة
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: s(30)),
                        child: Column(
                          children: [
                            _buildRow([items[0], items[1], items[2]], scale),
                            _buildRow([items[3], items[4], items[5]], scale),
                            _buildRow([items[6], items[7], items[8]], scale),
                            _buildRow([items[9], items[10], items[11]], scale),
                            
                            // الصف الخامس مع الفراغ يميناً لدفع الأزرار لليسار لتطابق صورتك الجديدة
                            Padding(
                              padding: EdgeInsets.only(bottom: s(22)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: s(85)), // مساحة فارغة
                                  _GridItem(item: items[12], scale: scale),
                                  _GridItem(item: items[13], scale: scale),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildRow(List<_HomeItem> rowItems, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: scale * 22.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowItems.map((item) => _GridItem(item: item, scale: scale)).toList(),
      ),
    );
  }
}

// تصميم الزر الذي يستدعي الصور الأصلية بدون تدخل برمجي في التدرجات
class _GridItem extends StatelessWidget {
  final _HomeItem item;
  final double scale;

  const _GridItem({
    required this.item,
    required this.scale,
  });

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.route.isEmpty
          ? null
          : () {
              Navigator.pushNamed(context, item.route);
            },
      child: SizedBox(
        width: s(85), // مقاس يعطي مساحة للنصوص الطويلة
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // صورتك الأصلية (تحتوي على الزر الأحمر والظل والأيقونة)
            Image.asset(
              'assets/img/${item.icon}',
              width: s(76),
              height: s(62),
              fit: BoxFit.fill,
            ),

            SizedBox(height: s(8)),

            // النصوص أسفل الزر
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: s(13.0),
                fontWeight: FontWeight.w600,
                color: const Color(0xff222222), // لون رمادي غامق/أسود
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeItem {
  final String icon;
  final String title;
  final String route;

  const _HomeItem(
    this.icon,
    this.title,
    this.route,
  );
}
