// ignore_for_file: unnecessary_import, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:nutridev/screens/historypage.dart';
import 'package:nutridev/screens/nutrition_details.dart';
import 'package:nutridev/screens/profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:nutridev/services/scan_history_service.dart';
import 'package:nutridev/widgets/add_food_dialog.dart';
import 'package:nutridev/widgets/nutrition_calculator_widget.dart';

class LanderClass extends StatefulWidget {
  const LanderClass({super.key});

  @override
  State<LanderClass> createState() => _LanderClassState();
}

class _LanderClassState extends State<LanderClass> {
  final RxString barcodeResult = ''.obs;
  final RxBool isScanning = false.obs;
  late final ScanHistoryService scanHistoryService;

  @override
  void initState() {
    super.initState();
    scanHistoryService = Get.put(ScanHistoryService());
  }

  Future<void> scanBarcode() async {
    isScanning.value = true;
    try {
      await Get.to(() => Scaffold(
            appBar: AppBar(
              title: Text('Scan Barcode', style: GoogleFonts.lexend()),
              backgroundColor: const Color(0xfff4f2f2),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
            ),
            body: Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    debugPrint('onDetect fired!');
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final String code = barcode.rawValue ?? '';
                      debugPrint('Barcode found! $code');

                      // Validate barcode format
                      if (_isValidBarcode(code)) {
                        final String gtin = _extractGTIN(code);

                        // Add to scan history (non-blocking)
                        scanHistoryService.addToHistory({
                          'barcode': gtin,
                          'name': 'Product $gtin',
                          'scannedAt': DateTime.now().toIso8601String(),
                        });

                        // Show success feedback with haptic
                        HapticFeedback.lightImpact();
                        Get.snackbar(
                          'Success!',
                          'Product scanned successfully',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );

                        // Navigate immediately
                        Get.back();
                        Get.to(() => NutritionDetailsPage(barcode: gtin));
                        return;
                      } else {
                        Get.snackbar(
                          'Invalid Barcode',
                          'Please scan a valid product barcode (EAN-13, UPC, etc.)',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                        debugPrint('Invalid barcode format: $code');
                      }
                    }
                  },
                ),
                // Scanning overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Container(
                        width: 250,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Position barcode here',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      Get.snackbar(
        'Scanning Error',
        'Failed to scan barcode. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isScanning.value = false;
    }
  }

  bool _isValidBarcode(String code) {
    if (code.isEmpty) return false;

    // Check for common barcode formats
    // EAN-13: 13 digits
    if (code.length == 13 && RegExp(r'^\d{13}$').hasMatch(code)) {
      return true;
    }

    // UPC-A: 12 digits
    if (code.length == 12 && RegExp(r'^\d{12}$').hasMatch(code)) {
      return true;
    }

    // UPC-E: 8 digits
    if (code.length == 8 && RegExp(r'^\d{8}$').hasMatch(code)) {
      return true;
    }

    // EAN-8: 8 digits
    if (code.length == 8 && RegExp(r'^\d{8}$').hasMatch(code)) {
      return true;
    }

    // Code 128, Code 39, etc. - allow alphanumeric with reasonable length
    if (code.length >= 8 && code.length <= 20) {
      return true;
    }

    return false;
  }

  String _extractGTIN(String code) {
    // For EAN-13, use the full code
    if (code.length == 13) {
      return code;
    }

    // For UPC-A, convert to EAN-13 by adding leading 0
    if (code.length == 12) {
      return '0$code';
    }

    // For other formats, use the code as is
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildHomePage(),
      ),
    );
  }

  Widget buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 69, left: 23, right: 23, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hello 👋🏻\nWelcome to nutridev',
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => Profile());
                  },
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                      radius: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 23),
                child: Text(
                  'Your Insights',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 2x2 Grid Layout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              children: [
                // First Row: Scan New and Add Food
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Scan New Widget
                    SizedBox(
                      height: 160,
                      width: 140,
                      child: Obx(() => GestureDetector(
                            onTap:
                                isScanning.value ? null : () => scanBarcode(),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'lib/asset/images/scan.png',
                                    height: 50,
                                    width: 50,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Scan New',
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                    // Add Food Widget
                    SizedBox(
                      height: 160,
                      width: 140,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await showDialog(
                            context: Get.context!,
                            barrierDismissible: false,
                            builder: (context) => AddFoodDialog(
                              onFoodAdded:
                                  (foodName, quantity, nutritionData) async {
                                await scanHistoryService.addToHistory({
                                  'name': foodName,
                                  'quantity': quantity,
                                  'nutrition': nutritionData,
                                  'manual': true,
                                  'scannedAt': DateTime.now().toIso8601String(),
                                });
                                Navigator.of(context)
                                    .pop(); // Close dialog properly
                              },
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 50,
                                color: Colors.green[600],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Add Food',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Second Row: History and BMI Calculator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // History Widget
                    SizedBox(
                      height: 160,
                      width: 140,
                      child: GestureDetector(
                        onTap: () => Get.to(() => const HistoryPage()),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/asset/images/history.png',
                                height: 50,
                                width: 50,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'History',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // BMI Calculator Widget
                    SizedBox(
                      height: 160,
                      width: 140,
                      child: GestureDetector(
                        onTap: () => _showNutritionCalculator(),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monitor_weight,
                                size: 50,
                                color: Colors.orange[600],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'BMI Calculator',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNutritionCalculator() {
    showDialog(
      context: Get.context!,
      builder: (context) => NutritionCalculatorWidget(),
    );
  }
}
