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
import 'package:responsive_framework/responsive_framework.dart';

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
              title: Text('Scan Barcode', style: GoogleFonts.inter()),
              backgroundColor: Colors.white.withOpacity(0.95),
              foregroundColor: const Color(0xFF2C3E50),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: const Color(0xFF2C3E50)),
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
                          backgroundColor:
                              const Color(0xFF2C3E50).withOpacity(0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          borderRadius: 12,
                          margin: const EdgeInsets.all(16),
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
                          backgroundColor:
                              const Color(0xFFE74C3C).withOpacity(0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                          borderRadius: 12,
                          margin: const EdgeInsets.all(16),
                        );
                        debugPrint('Invalid barcode format: $code');
                      }
                    }
                  },
                ),
                // Classic Scanning Overlay
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final screenHeight = MediaQuery.of(context).size.height;
                      final isMobile =
                          ResponsiveBreakpoints.of(context).isMobile;
                      final isTablet =
                          ResponsiveBreakpoints.of(context).isTablet;
                      final fontSize = isMobile
                          ? 14.0
                          : isTablet
                              ? 16.0
                              : 18.0;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Container(
                            width: screenWidth * 0.7,
                            height: screenHeight * 0.2,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Position barcode here',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
        backgroundColor: const Color(0xFFE74C3C).withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
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
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FA),
              Colors.white.withOpacity(0.8),
              const Color(0xFFF1F3F4),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Center(
            child: buildHomePage(),
          ),
        ),
      ),
    );
  }

  Widget buildHomePage() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Responsive dimensions
    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
            ? 24.0
            : 32.0;
    final topMargin = isMobile
        ? 40.0
        : isTablet
            ? 50.0
            : 60.0;
    final cardHeight = isMobile
        ? 140.0
        : isTablet
            ? 160.0
            : 180.0;
    final cardWidth = isMobile
        ? 120.0
        : isTablet
            ? 140.0
            : 160.0;
    final iconSize = isMobile
        ? 28.0
        : isTablet
            ? 32.0
            : 36.0;
    final fontSize = isMobile
        ? 14.0
        : isTablet
            ? 16.0
            : 18.0;
    final headerFontSize = isMobile
        ? 20.0
        : isTablet
            ? 24.0
            : 28.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Premium Header Section
          Container(
            margin: EdgeInsets.only(
                top: topMargin,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 32),
            padding: EdgeInsets.all(horizontalPadding),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello 👋🏻',
                        style: GoogleFonts.inter(
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2C3E50).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome to NutriDev',
                        style: GoogleFonts.inter(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => Profile());
                  },
                  child: Container(
                    width: iconSize + 20,
                    height: iconSize + 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: const Color(0xFF2C3E50),
                      size: iconSize - 4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Section Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: fontSize + 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Insights',
                  style: GoogleFonts.inter(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 2x2 Grid Layout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                // First Row: Scan New and Add Food
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Scan New Widget
                    SizedBox(
                      height: cardHeight,
                      width: cardWidth,
                      child: Obx(() => GestureDetector(
                            onTap:
                                isScanning.value ? null : () => scanBarcode(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.05),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(iconSize / 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C3E50)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Image.asset(
                                      'lib/asset/images/scan.png',
                                      height: iconSize,
                                      width: iconSize,
                                    ),
                                  ),
                                  SizedBox(height: iconSize / 2),
                                  Text(
                                    'Scan New',
                                    style: GoogleFonts.inter(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                    // Add Food Widget
                    SizedBox(
                      height: cardHeight,
                      width: cardWidth,
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
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(iconSize / 3),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF34495E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.restaurant_outlined,
                                  size: iconSize,
                                  color: const Color(0xFF34495E),
                                ),
                              ),
                              SizedBox(height: iconSize / 2),
                              Text(
                                'Add Food',
                                style: GoogleFonts.inter(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
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
                      height: cardHeight,
                      width: cardWidth,
                      child: GestureDetector(
                        onTap: () => Get.to(() => const HistoryPage()),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(iconSize / 3),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFE74C3C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'lib/asset/images/history.png',
                                  height: iconSize,
                                  width: iconSize,
                                ),
                              ),
                              SizedBox(height: iconSize / 2),
                              Text(
                                'History',
                                style: GoogleFonts.inter(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // BMI Calculator Widget
                    SizedBox(
                      height: cardHeight,
                      width: cardWidth,
                      child: GestureDetector(
                        onTap: () => _showNutritionCalculator(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(iconSize / 3),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF2C3E50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.monitor_weight_outlined,
                                  size: iconSize,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              SizedBox(height: iconSize / 2),
                              Text(
                                'BMI Calculator',
                                style: GoogleFonts.inter(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
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
