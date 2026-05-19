import 'package:flutter/material.dart';
import '../main.dart';
import '../services/firebase_service.dart';

class TransferBankPage extends StatefulWidget {
  const TransferBankPage({super.key});

  @override
  State<TransferBankPage> createState() => _TransferBankPageState();
}

class _TransferBankPageState extends State<TransferBankPage> {
  final accountNo = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    accountNo.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final acc = accountNo.text.replaceAll(RegExp(r'\D'), '');

    if (acc.isEmpty) {
      return toast('يرجى إدخال رقم الحساب');
    }

    setState(() => loading = true);

    try {
      final target = await FirebaseService.getAccount(acc);
      if (!mounted) return;

      if (target == null) {
        toast('الحساب غير موجود في قاعدة البيانات');
        return;
      }

      Navigator.pushNamed(context, '/sendto', arguments: target.accountNo);
    } catch (_) {
      if (mounted) toast('تعذر الاتصال بقاعدة البيانات');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void toast(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s, textAlign: TextAlign.center)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffededed),
        body: Center(
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth.clamp(0.0, 430.0);
              final isSmall = w <= 390;
              final isVerySmall = w <= 360;

              final headerHeight = isVerySmall ? 56.0 : (isSmall ? 60.0 : 66.0);
              final logoWidth = isSmall ? 145.0 : 200.0;

              final titleWrapHeight = isSmall ? 42.0 : 48.0;
              final pageTitleSize = isVerySmall ? 27.0 : (isSmall ? 18.0 : 22.0);
              final pageTitleRightPadding = isVerySmall ? 96.0 : (isSmall ? 102.0 : 112.0);

              final backWidth = isVerySmall ? 90.0 : (isSmall ? 80.0 : 85.0);
              final backHeight = isVerySmall ? 38.0 : (isSmall ? 42.0 : 40.0);

              final sectionHeight = isSmall ? 50.0 : 88.0;
              final sectionFont = isSmall ? 20.0 : 40.0;

              final sendPadding = isSmall
                  ? const EdgeInsets.fromLTRB(10, 10, 10, 72)
                  : const EdgeInsets.fromLTRB(12, 12, 12, 76);

              final inputHeight = isSmall ? 70.0 : 76.0;
              final inputIcon = isSmall ? 38.0 : 42.0;
              final inputFont = isSmall ? 17.0 : 16.0;

              final sendButtonWidth = isVerySmall ? 132.0 : (isSmall ? 106.0 : 156.0);
              final sendButtonHeight = isVerySmall ? 50.0 : (isSmall ? 48.0 : 58.0);
              final sendTextSize = isVerySmall ? 16.0 : (isSmall ? 17.0 : 12.0);

              return SizedBox(
                width: w,
                child: Stack(
                  children: [
                    Container(
                      width: w,
                      color: const Color(0xfff2f2f2),
                      padding: const EdgeInsets.only(bottom: 52),
                      child: Column(
                        children: [
                          Container(
                            height: headerHeight,
                            padding: EdgeInsets.only(bottom: isSmall ? 4 : 6),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xffff0b0b),
                                  Color(0xffc91c22),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Image.asset(
                                    'assets/img/bankak_logo_big.png',
                                    width: logoWidth,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  right: isSmall ? 10 : 14,
                                  bottom: isSmall ? 12 : 14,
                                  child: InkWell(
                                    onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                                    child: Transform.scale(
                                      scale: isSmall ? .88 : 1,
                                      alignment: Alignment.bottomRight,
                                      child: const _MenuIcon(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: titleWrapHeight,
                            child: Stack(
                              children: [
                                Positioned(
                                  right: isSmall ? 8 : 14,
                                  top: isSmall ? 6 : 8,
                                  child: InkWell(
                                    onTap: () => safeBack(context, '/transfer'),
                                    child: Image.asset(
                                      'assets/img/back.png',
                                      width: backWidth,
                                      height: backHeight,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      16,
                                      10,
                                      pageTitleRightPadding,
                                      2,
                                    ),
                                    child: Text(
                                      'تحويل لحسابات بنك الخرطوم',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: pageTitleSize,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: sectionHeight,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xffff0b0b),
                                  Color(0xffc8102e),
                                ],
                              ),
                            ),
                            child: Text(
                              'دفع مباشر',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: sectionFont,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          Padding(
                            padding: sendPadding,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: inputHeight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmall ? 18 : 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xffaaaaaa),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/img/slidscanandpay.png',
                                          width: inputIcon,
                                          height: inputIcon,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.account_balance,
                                            size: inputIcon,
                                          ),
                                        ),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: TextField(
                                            controller: accountNo,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.right,
                                            textDirection: TextDirection.rtl,
                                            style: TextStyle(
                                              color: const Color(0xff666666),
                                              fontSize: inputFont,
                                              fontFamily: 'Rubik',
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              hintText:
                                                  'أدخل رقم الحساب/الرقم المرجعي (16 رقم)',
                                              hintTextDirection: TextDirection.rtl,
                                              hintStyle: TextStyle(
                                                color: Color(0xff777777),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: loading ? null : submit,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/img/button.png',
                                              width: sendButtonWidth,
                                              height: sendButtonHeight,
                                              fit: BoxFit.fill,
                                            ),
                                            loading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    'إرسال',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: sendTextSize,
                                                      fontWeight: FontWeight.w700,
                                                      shadows: const [
                                                        Shadow(
                                                          color: Colors.black26,
                                                          offset: Offset(0, 1),
                                                          blurRadius: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _Footer(),
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
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 28,
      child: Stack(
        children: [
          Positioned(right: 0, top: 0, child: _bar()),
          Positioned(right: 0, top: 11, child: _bar()),
          Positioned(right: 0, top: 22, child: _bar()),
        ],
      ),
    );
  }

  Widget _bar() {
    return Container(
      width: 34,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xffdcdcdc),
        border: Border(
          top: BorderSide(
            color: Color(0xffcccccc),
            width: 1,
          ),
        ),
      ),
      child: const Text(
        '©2024 بنك الخرطوم | بنكك حساب',
        style: TextStyle(
          color: Color(0xff333333),
          fontSize: 13,
          fontFamily: 'Rubik',
        ),
        maxLines: 1,
      ),
    );
  }
}