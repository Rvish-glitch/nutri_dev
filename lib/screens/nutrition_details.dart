import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutridev/services/nutrition_service.dart';
import 'package:nutridev/services/scan_history_service.dart';

class NutritionDetailsController extends GetxController {
  final String barcode;
  final NutritionService _nutritionService = NutritionService();
  final ScanHistoryService _scanHistoryService = Get.find<ScanHistoryService>();

  var nutritionData = <String, dynamic>{}.obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  NutritionDetailsController({required this.barcode});

  @override
  void onInit() {
    super.onInit();
    fetchNutritionData();
  }

  Future<void> fetchNutritionData() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final product = await _nutritionService.getProductByBarcode(barcode);

      if (product != null) {
        final nutritionInfo = _nutritionService.extractNutritionInfo(product);
        if (nutritionInfo != null) {
          nutritionData.value = nutritionInfo;

          // Update scan history with actual product name if it exists
          final existingIndex = _scanHistoryService.scanHistory.indexWhere(
            (item) => item['barcode'] == barcode,
          );
          if (existingIndex != -1) {
            _scanHistoryService.scanHistory[existingIndex]['name'] =
                nutritionInfo['name'] ?? 'Unknown Product';
            await _scanHistoryService.saveScanHistory();
          }
        } else {
          hasError.value = true;
          errorMessage.value =
              'Nutrition information not available for this product';
        }
      } else {
        hasError.value = true;
        errorMessage.value = 'Product not found in database';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to fetch product information';
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class NutritionDetailsPage extends StatelessWidget {
  final String barcode;

  const NutritionDetailsPage({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Details', style: GoogleFonts.lexend()),
        backgroundColor: const Color(0xfff4f2f2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<NutritionDetailsController>(
        init: NutritionDetailsController(barcode: barcode),
        builder: (controller) {
          return Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading nutrition information...'),
                  ],
                ),
              );
            }

            if (controller.hasError.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      style: GoogleFonts.lexend(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchNutritionData(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            final data = controller.nutritionData;
            final nutritionService = controller._nutritionService;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Product Image
                          if (data['image'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['image'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.fastfood,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.fastfood,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(width: 16),
                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Unknown Product',
                                  style: GoogleFonts.lexend(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['brand'] ?? 'Unknown Brand',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (data['nutrition_grade'] != null)
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(int.parse(
                                            nutritionService
                                                .getNutritionGradeColor(
                                                  data['nutrition_grade'],
                                                )
                                                .replaceAll('#', '0xFF'),
                                          )),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          data['nutrition_grade'].toUpperCase(),
                                          style: GoogleFonts.lexend(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        nutritionService.getNutritionGradeText(
                                          data['nutrition_grade'],
                                        ),
                                        style: GoogleFonts.lexend(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nutrition Facts
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nutrition Facts',
                            style: GoogleFonts.lexend(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildNutritionRow('Calories',
                              '${data['calories']?.toStringAsFixed(1) ?? '0'} kcal'),
                          _buildNutritionRow('Protein',
                              '${data['protein']?.toStringAsFixed(1) ?? '0'}g'),
                          _buildNutritionRow('Carbohydrates',
                              '${data['carbs']?.toStringAsFixed(1) ?? '0'}g'),
                          _buildNutritionRow('Fat',
                              '${data['fat']?.toStringAsFixed(1) ?? '0'}g'),
                          _buildNutritionRow('Fiber',
                              '${data['fiber']?.toStringAsFixed(1) ?? '0'}g'),
                          _buildNutritionRow('Sugar',
                              '${data['sugar']?.toStringAsFixed(1) ?? '0'}g'),
                          _buildNutritionRow('Salt',
                              '${data['salt']?.toStringAsFixed(1) ?? '0'}g'),
                          const Divider(),
                          Text(
                            'Serving Size: ${data['serving_size'] ?? '100g'}',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ingredients
                  if (data['ingredients'] != null &&
                      data['ingredients'] != 'No ingredients listed')
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingredients',
                              style: GoogleFonts.lexend(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data['ingredients'],
                              style: GoogleFonts.lexend(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Allergens
                  if (data['allergens'] != null &&
                      (data['allergens'] as List).isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Allergens',
                              style: GoogleFonts.lexend(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: (data['allergens'] as List)
                                  .map((allergen) => Chip(
                                        label: Text(
                                          allergen
                                              .toString()
                                              .replaceAll('en:', ''),
                                          style:
                                              GoogleFonts.lexend(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.red[100],
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
