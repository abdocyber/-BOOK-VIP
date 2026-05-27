import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  final TextEditingController _accountController = TextEditingController();
  bool _isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final BarcodeCapture? result = await controller.analyzeImage(image.path);
      final String? code = result?.barcodes.isNotEmpty == true
          ? result!.barcodes.first.rawValue
          : null;

      if (code != null && code.isNotEmpty) {
        _navigateToTransfer(code);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على رمز QR في الصورة')),
        );
      }
    }
  }

  void _navigateToTransfer(String code) {
    if (_isScanned) return;
    setState(() => _isScanned = true);
    Navigator.pushReplacementNamed(
      context,
      '/sendto',
      arguments: code.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanArea = size.width * 0.7;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'بنكك',
                          style: TextStyle(
                            color: Color(0xffe31e24),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'PAY',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffe31e24)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'رجوع',
                              style: TextStyle(color: Color(0xffe31e24), fontSize: 16),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Color(0xffe31e24), size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Camera and Controls
              Expanded(
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            _navigateToTransfer(barcode.rawValue!);
                            break;
                          }
                        }
                      },
                    ),
                    
                    // Custom Scan Overlay (Red Frame)
                    Center(
                      child: Container(
                        width: scanArea,
                        height: scanArea,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Stack(
                          children: [
                            // Top-left corner
                            Positioned(
                              top: 0, left: 0,
                              child: Container(width: 40, height: 40, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.red, width: 4), left: BorderSide(color: Colors.red, width: 4)))),
                            ),
                            // Top-right corner
                            Positioned(
                              top: 0, right: 0,
                              child: Container(width: 40, height: 40, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.red, width: 4), right: BorderSide(color: Colors.red, width: 4)))),
                            ),
                            // Bottom-left corner
                            Positioned(
                              bottom: 0, left: 0,
                              child: Container(width: 40, height: 40, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.red, width: 4), left: BorderSide(color: Colors.red, width: 4)))),
                            ),
                            // Bottom-right corner
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(width: 40, height: 40, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.red, width: 4), right: BorderSide(color: Colors.red, width: 4)))),
                            ),
                            // Scanning Line
                            const _ScanningLine(),
                          ],
                        ),
                      ),
                    ),

                    // Side Buttons (Flash, Gallery, Book)
                    Positioned(
                      left: 16,
                      top: size.height * 0.15,
                      child: Column(
                        children: [
                          _CircularButton(
                            icon: Icons.flash_on,
                            onTap: () => controller.toggleTorch(),
                          ),
                          const SizedBox(height: 16),
                          _CircularButton(
                            icon: Icons.image,
                            onTap: _pickImage,
                          ),
                          const SizedBox(height: 16),
                          _CircularButton(
                            icon: Icons.menu_book,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // "أو" Circle
                    Positioned(
                      bottom: -20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xff28a745),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'أو',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. Input and Submit
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _accountController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'أدخل رقم الحساب/الرقم المرجعي (16 رقم)',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        if (_accountController.text.isNotEmpty) {
                          _navigateToTransfer(_accountController.text);
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xfff50c0c), Color(0xffd71920)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'إرسال',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircularButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Icon(icon, color: const Color(0xffe31e24), size: 24),
      ),
    );
  }
}

class _ScanningLine extends StatefulWidget {
  const _ScanningLine();

  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: _animationController.value * (MediaQuery.of(context).size.width * 0.7 - 2),
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
}
