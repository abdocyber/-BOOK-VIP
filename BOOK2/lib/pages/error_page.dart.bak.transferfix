import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is Map ? rawArgs : <String, dynamic>{};

    final message = '${args['message'] ?? 'لايوجد رصيد كافي لإجراء المعاملة'}';
    final retryRoute = '${args['retryRoute'] ?? '/sendto'}';
    final to = '${args['to'] ?? ''}';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffff0707),
                  Color(0xfff40408),
                  Color(0xffdd0012),
                  Color(0xffbd1421),
                ],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * .077),
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(.42),
                            blurRadius: 17,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xffd02b2b),
                        size: 92,
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      'خطأ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      height: 132,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white, fontSize: 25),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 72),
                    InkWell(
                      onTap: () {
                        if (retryRoute == '/sendto' && to.isNotEmpty) {
                          Navigator.pushReplacementNamed(context, '/sendto', arguments: to);
                        } else {
                          Navigator.pushReplacementNamed(context, retryRoute);
                        }
                      },
                      child: Container(
                        width: 184,
                        height: 82,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xffe43838),
                              Color(0xffef1515),
                              Color(0xffd50909),
                            ],
                          ),
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.45),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FooterRed(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FooterRed extends StatelessWidget {
  const FooterRed({super.key});

  @override
  Widget build(BuildContext c) => Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(.92), width: 2),
          ),
        ),
        child: const Text(
          '©2024 بنك الخرطوم|بنكك حساب',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      );
}
