import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسح QR Code'),
        backgroundColor: const Color(0xffc91c22),
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return;
          
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null && code.isNotEmpty) {
              setState(() {
                _isScanned = true;
              });
              
              // العودة لصفحة التحويل مع رقم الحساب المقروء
              Navigator.pushReplacementNamed(
                context,
                '/sendto',
                arguments: code,
              );
              break;
            }
          }
        },
      ),
    );
  }
}
