import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v0/product';

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$barcode.json'),
        headers: {
          'User-Agent': 'nutridev/1.0 (Flutter App)',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1) {
          return data['product'];
        } else {
          print('Product not found: $barcode');
          return null;
        }
      } else {
        print('Failed to fetch product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Map<String, dynamic>? extractNutritionInfo(Map<String, dynamic> product) {
    try {
      final nutriments = product['nutriments'] as Map<String, dynamic>?;
      if (nutriments == null) return null;

      return {
        'name': product['product_name'] ??
            product['generic_name'] ??
            'Unknown Product',
        'brand': product['brands'] ?? 'Unknown Brand',
        'image': product['image_front_url'] ?? product['image_url'],
        'calories': nutriments['energy-kcal_100g']?.toDouble() ?? 0.0,
        'protein': nutriments['proteins_100g']?.toDouble() ?? 0.0,
        'carbs': nutriments['carbohydrates_100g']?.toDouble() ?? 0.0,
        'fat': nutriments['fat_100g']?.toDouble() ?? 0.0,
        'fiber': nutriments['fiber_100g']?.toDouble() ?? 0.0,
        'sugar': nutriments['sugars_100g']?.toDouble() ?? 0.0,
        'salt': nutriments['salt_100g']?.toDouble() ?? 0.0,
        'sodium': nutriments['sodium_100g']?.toDouble() ?? 0.0,
        'ingredients': product['ingredients_text'] ?? 'No ingredients listed',
        'allergens': product['allergens_tags'] ?? [],
        'nutrition_grade':
            product['nutrition_grade_fr'] ?? product['nutrition_grade'],
        'serving_size': product['serving_size'] ?? '100g',
      };
    } catch (e) {
      print('Error extracting nutrition info: $e');
      return null;
    }
  }

  String getNutritionGradeColor(String? grade) {
    switch (grade?.toLowerCase()) {
      case 'a':
        return '#4CAF50'; // Green
      case 'b':
        return '#8BC34A'; // Light Green
      case 'c':
        return '#FFC107'; // Yellow
      case 'd':
        return '#FF9800'; // Orange
      case 'e':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  String getNutritionGradeText(String? grade) {
    switch (grade?.toLowerCase()) {
      case 'a':
        return 'Excellent';
      case 'b':
        return 'Good';
      case 'c':
        return 'Average';
      case 'd':
        return 'Poor';
      case 'e':
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }
}
