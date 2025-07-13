import 'package:nutridev/services/nutrition_service.dart';
import 'package:nutridev/services/scan_history_service.dart';
import 'package:get/get.dart';

class NutritionSummaryService {
  final NutritionService _nutritionService = NutritionService();

  Future<Map<String, dynamic>> getNutritionSummary() async {
    // Get the scan history service instance from GetX
    final scanHistoryService = Get.find<ScanHistoryService>();
    final history = scanHistoryService.getHistory();
    print('DEBUG: Processing ${history.length} products for nutrition summary');
    print('DEBUG: History items: $history');

    final summary = <String, dynamic>{
      'totalProducts': history.length,
      'productsWithData': 0,
      'totalCalories': 0.0,
      'totalProtein': 0.0,
      'totalCarbs': 0.0,
      'totalFat': 0.0,
      'totalFiber': 0.0,
      'totalSugar': 0.0,
      'totalSalt': 0.0,
      'totalSodium': 0.0,
      'minCalories': double.infinity,
      'maxCalories': 0.0,
      'vitamins': <String, double>{},
      'minerals': <String, double>{},
      'otherNutrients': <String, double>{},
      'ingredientsNutrients': <String, double>{},
      'nutritionData': <Map<String, dynamic>>[],
    };

    for (final item in history) {
      try {
        // Check if this is a manual food entry first
        final isManual = item['manual'] == true;

        if (isManual) {
          // Handle manual food entry
          final nutritionData = item['nutrition'] as Map<String, dynamic>?;
          if (nutritionData != null) {
            summary['productsWithData'] =
                (summary['productsWithData'] as int) + 1;

            print(
                'DEBUG: Found manual nutrition data for ${item['name']} - Calories: ${nutritionData['calories']}');

            // Store nutrition data for totaling
            final nutritionDataList =
                summary['nutritionData'] as List<Map<String, dynamic>>;
            nutritionDataList.add(nutritionData);

            // Track min/max calories
            final calories = nutritionData['calories'] ?? 0.0;
            if (calories > 0) {
              final currentMax = summary['maxCalories'] as double;
              final currentMin = summary['minCalories'] as double;
              summary['maxCalories'] =
                  currentMax < calories ? calories : currentMax;
              summary['minCalories'] =
                  currentMin > calories ? calories : currentMin;
            }

            // Sum totals
            final currentCalories = summary['totalCalories'] as double;
            final currentProtein = summary['totalProtein'] as double;
            final currentCarbs = summary['totalCarbs'] as double;
            final currentFat = summary['totalFat'] as double;
            final currentFiber = summary['totalFiber'] as double;
            final currentSugar = summary['totalSugar'] as double;
            final currentSalt = summary['totalSalt'] as double;
            final currentSodium = summary['totalSodium'] as double;

            summary['totalCalories'] =
                currentCalories + (nutritionData['calories'] ?? 0.0);
            summary['totalProtein'] =
                currentProtein + (nutritionData['protein'] ?? 0.0);
            summary['totalCarbs'] =
                currentCarbs + (nutritionData['carbs'] ?? 0.0);
            summary['totalFat'] = currentFat + (nutritionData['fat'] ?? 0.0);
            summary['totalFiber'] =
                currentFiber + (nutritionData['fiber'] ?? 0.0);
            summary['totalSugar'] =
                currentSugar + (nutritionData['sugar'] ?? 0.0);
            summary['totalSalt'] = currentSalt + (nutritionData['salt'] ?? 0.0);
            summary['totalSodium'] =
                currentSodium + (nutritionData['sodium'] ?? 0.0);
          }
        } else {
          // Handle scanned product - check if barcode exists
          final barcode = item['barcode'] ?? '';
          if (barcode.isNotEmpty) {
            final product =
                await _nutritionService.getProductByBarcode(barcode);
            if (product != null) {
              final nutritionInfo =
                  _nutritionService.extractNutritionInfo(product);
              if (nutritionInfo != null) {
                summary['productsWithData'] =
                    (summary['productsWithData'] as int) + 1;

                print(
                    'DEBUG: Found nutrition data for $barcode - Calories: ${nutritionInfo['calories']}');

                // Store nutrition data for totaling
                final nutritionData =
                    summary['nutritionData'] as List<Map<String, dynamic>>;
                nutritionData.add(nutritionInfo);

                // Track min/max calories
                final calories = nutritionInfo['calories'] ?? 0.0;
                if (calories > 0) {
                  final currentMax = summary['maxCalories'] as double;
                  final currentMin = summary['minCalories'] as double;
                  summary['maxCalories'] =
                      currentMax < calories ? calories : currentMax;
                  summary['minCalories'] =
                      currentMin > calories ? calories : currentMin;
                }

                // Sum totals
                final currentCalories = summary['totalCalories'] as double;
                final currentProtein = summary['totalProtein'] as double;
                final currentCarbs = summary['totalCarbs'] as double;
                final currentFat = summary['totalFat'] as double;
                final currentFiber = summary['totalFiber'] as double;
                final currentSugar = summary['totalSugar'] as double;
                final currentSalt = summary['totalSalt'] as double;
                final currentSodium = summary['totalSodium'] as double;

                summary['totalCalories'] =
                    currentCalories + (nutritionInfo['calories'] ?? 0.0);
                summary['totalProtein'] =
                    currentProtein + (nutritionInfo['protein'] ?? 0.0);
                summary['totalCarbs'] =
                    currentCarbs + (nutritionInfo['carbs'] ?? 0.0);
                summary['totalFat'] =
                    currentFat + (nutritionInfo['fat'] ?? 0.0);
                summary['totalFiber'] =
                    currentFiber + (nutritionInfo['fiber'] ?? 0.0);
                summary['totalSugar'] =
                    currentSugar + (nutritionInfo['sugar'] ?? 0.0);
                summary['totalSalt'] =
                    currentSalt + (nutritionInfo['salt'] ?? 0.0);
                summary['totalSodium'] =
                    currentSodium + (nutritionInfo['sodium'] ?? 0.0);

                // Extract vitamins and minerals from nutriments
                _extractVitaminsAndMinerals(product, summary);

                // Extract nutrients from ingredients
                _extractNutrientsFromIngredients(product, summary);
              } else {
                print('DEBUG: No nutrition info found for $barcode');
              }
            }
          }
        }
      } catch (e) {
        final barcode = item['barcode'] ?? 'manual';
        print('Error processing product $barcode: $e');
      }
    }

    // Calculate totals (no averages needed)
    _calculateTotals(summary);

    print(
        'DEBUG: Final summary - Products with data: ${summary['productsWithData']}, Total calories: ${summary['totalCalories']}');

    return summary;
  }

  void _calculateTotals(Map<String, dynamic> summary) {
    // No-op, kept for compatibility if needed in future
    // All totals are already summed in the main loop
    if (summary['minCalories'] == double.infinity) {
      summary['minCalories'] = 0.0;
    }
  }

  void _extractVitaminsAndMinerals(
      Map<String, dynamic> product, Map<String, dynamic> summary) {
    final nutriments = product['nutriments'] as Map<String, dynamic>?;
    if (nutriments == null) return;

    // Vitamins
    final vitamins = [
      'vitamin-a',
      'vitamin-b1',
      'vitamin-b2',
      'vitamin-b3',
      'vitamin-b5',
      'vitamin-b6',
      'vitamin-b9',
      'vitamin-b12',
      'vitamin-c',
      'vitamin-d',
      'vitamin-e',
      'vitamin-k',
      'biotin',
      'choline'
    ];

    // Minerals
    final minerals = [
      'calcium',
      'iron',
      'magnesium',
      'phosphorus',
      'potassium',
      'zinc',
      'copper',
      'manganese',
      'selenium',
      'chromium',
      'molybdenum',
      'iodine',
      'fluoride',
      'chloride'
    ];

    // Other nutrients
    final otherNutrients = [
      'omega-3',
      'omega-6',
      'omega-9',
      'trans-fat',
      'saturated-fat',
      'monounsaturated-fat',
      'polyunsaturated-fat',
      'cholesterol',
      'starch',
      'alcohol',
      'caffeine',
      'taurine',
      'creatine'
    ];

    for (final vitamin in vitamins) {
      final value = nutriments['${vitamin}_100g']?.toDouble();
      if (value != null && value > 0) {
        final vitaminsMap = summary['vitamins'] as Map<String, double>;
        vitaminsMap[vitamin] = (vitaminsMap[vitamin] ?? 0.0) + value;
      }
    }

    for (final mineral in minerals) {
      final value = nutriments['${mineral}_100g']?.toDouble();
      if (value != null && value > 0) {
        final mineralsMap = summary['minerals'] as Map<String, double>;
        mineralsMap[mineral] = (mineralsMap[mineral] ?? 0.0) + value;
      }
    }

    for (final nutrient in otherNutrients) {
      final value = nutriments['${nutrient}_100g']?.toDouble();
      if (value != null && value > 0) {
        final otherNutrientsMap =
            summary['otherNutrients'] as Map<String, double>;
        otherNutrientsMap[nutrient] =
            (otherNutrientsMap[nutrient] ?? 0.0) + value;
      }
    }
  }

  void _extractNutrientsFromIngredients(
      Map<String, dynamic> product, Map<String, dynamic> summary) {
    final ingredients =
        product['ingredients_text']?.toString().toLowerCase() ?? '';
    if (ingredients.isEmpty) return;

    // Common nutrients found in ingredients
    final nutrientKeywords = {
      'vitamin a': 'vitamin-a',
      'vitamin b1': 'vitamin-b1',
      'vitamin b2': 'vitamin-b2',
      'vitamin b3': 'vitamin-b3',
      'vitamin b5': 'vitamin-b5',
      'vitamin b6': 'vitamin-b6',
      'vitamin b9': 'vitamin-b9',
      'vitamin b12': 'vitamin-b12',
      'vitamin c': 'vitamin-c',
      'vitamin d': 'vitamin-d',
      'vitamin e': 'vitamin-e',
      'vitamin k': 'vitamin-k',
      'calcium': 'calcium',
      'iron': 'iron',
      'magnesium': 'magnesium',
      'phosphorus': 'phosphorus',
      'potassium': 'potassium',
      'zinc': 'zinc',
      'copper': 'copper',
      'manganese': 'manganese',
      'selenium': 'selenium',
      'omega-3': 'omega-3',
      'omega-6': 'omega-6',
      'omega-9': 'omega-9',
      'fiber': 'fiber',
      'protein': 'protein',
      'antioxidants': 'antioxidants',
      'probiotics': 'probiotics',
      'enzymes': 'enzymes',
    };

    for (final entry in nutrientKeywords.entries) {
      if (ingredients.contains(entry.key)) {
        final ingredientsMap =
            summary['ingredientsNutrients'] as Map<String, double>;
        ingredientsMap[entry.value] =
            (ingredientsMap[entry.value] ?? 0.0) + 1.0; // Count occurrences
      }
    }
  }

  String formatNutrientName(String name) {
    return name
        .split('-')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  String getNutrientUnit(String nutrient) {
    if (nutrient.startsWith('vitamin')) return 'mg';
    if ([
      'calcium',
      'iron',
      'magnesium',
      'phosphorus',
      'potassium',
      'zinc',
      'copper',
      'manganese',
      'selenium'
    ].contains(nutrient)) {
      return 'mg';
    }
    if (['sodium', 'salt'].contains(nutrient)) return 'g';
    if (['protein', 'carbs', 'fat', 'fiber', 'sugar'].contains(nutrient))
      return 'g';
    if (['calories'].contains(nutrient)) return 'kcal';
    return 'mg';
  }
}
