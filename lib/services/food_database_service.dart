import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class FoodDatabaseService {
  static final Map<String, Map<String, dynamic>> _foodDatabase = {
    // Indian Foods
    'Rice (Cooked)': {
      'calories': 130.0,
      'protein': 2.7,
      'carbs': 28.0,
      'fat': 0.3,
      'fiber': 0.4,
      'sugar': 0.1,
      'salt': 0.0,
      'sodium': 1.0,
      'per': '100g',
    },
    'Roti/Chapati': {
      'calories': 264.0,
      'protein': 9.0,
      'carbs': 46.0,
      'fat': 4.0,
      'fiber': 4.0,
      'sugar': 0.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': '100g',
    },
    'Dal (Cooked)': {
      'calories': 116.0,
      'protein': 9.0,
      'carbs': 20.0,
      'fat': 0.4,
      'fiber': 7.0,
      'sugar': 0.0,
      'salt': 0.0,
      'sodium': 2.0,
      'per': '100g',
    },
    'Sabzi (Mixed Vegetables)': {
      'calories': 85.0,
      'protein': 3.0,
      'carbs': 15.0,
      'fat': 2.0,
      'fiber': 4.0,
      'sugar': 3.0,
      'salt': 0.0,
      'sodium': 5.0,
      'per': '100g',
    },
    'Curd/Yogurt': {
      'calories': 59.0,
      'protein': 10.0,
      'carbs': 3.6,
      'fat': 0.4,
      'fiber': 0.0,
      'sugar': 3.2,
      'salt': 0.0,
      'sodium': 36.0,
      'per': '100g',
    },
    'Paneer': {
      'calories': 265.0,
      'protein': 18.0,
      'carbs': 1.0,
      'fat': 20.0,
      'fiber': 0.0,
      'sugar': 0.0,
      'salt': 0.0,
      'sodium': 15.0,
      'per': '100g',
    },
    'Idli': {
      'calories': 39.0,
      'protein': 2.0,
      'carbs': 7.0,
      'fat': 0.2,
      'fiber': 0.5,
      'sugar': 0.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'piece',
    },
    'Dosa': {
      'calories': 133.0,
      'protein': 3.0,
      'carbs': 25.0,
      'fat': 2.0,
      'fiber': 1.0,
      'sugar': 0.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'piece',
    },
    'Samosa': {
      'calories': 262.0,
      'protein': 6.0,
      'carbs': 30.0,
      'fat': 14.0,
      'fiber': 2.0,
      'sugar': 1.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'piece',
    },
    'Pakora': {
      'calories': 200.0,
      'protein': 4.0,
      'carbs': 20.0,
      'fat': 12.0,
      'fiber': 2.0,
      'sugar': 1.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'piece',
    },

    // Fast Food
    'Pizza (Slice)': {
      'calories': 266.0,
      'protein': 11.0,
      'carbs': 33.0,
      'fat': 10.0,
      'fiber': 2.0,
      'sugar': 3.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'slice',
    },
    'Burger': {
      'calories': 295.0,
      'protein': 12.0,
      'carbs': 30.0,
      'fat': 14.0,
      'fiber': 2.0,
      'sugar': 5.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'piece',
    },
    'French Fries': {
      'calories': 365.0,
      'protein': 4.0,
      'carbs': 63.0,
      'fat': 17.0,
      'fiber': 4.0,
      'sugar': 0.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': '100g',
    },
    'Chicken Wings': {
      'calories': 290.0,
      'protein': 27.0,
      'carbs': 0.0,
      'fat': 19.0,
      'fiber': 0.0,
      'sugar': 0.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'piece',
    },
    'Noodles': {
      'calories': 138.0,
      'protein': 4.0,
      'carbs': 25.0,
      'fat': 2.0,
      'fiber': 1.0,
      'sugar': 0.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': '100g',
    },
    'Sandwich': {
      'calories': 250.0,
      'protein': 12.0,
      'carbs': 30.0,
      'fat': 10.0,
      'fiber': 2.0,
      'sugar': 3.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'piece',
    },
    'Ice Cream': {
      'calories': 207.0,
      'protein': 3.5,
      'carbs': 24.0,
      'fat': 11.0,
      'fiber': 0.0,
      'sugar': 21.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': '100g',
    },
    'Cake': {
      'calories': 257.0,
      'protein': 4.0,
      'carbs': 45.0,
      'fat': 6.0,
      'fiber': 1.0,
      'sugar': 25.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': '100g',
    },

    // Beverages
    'Tea (with milk)': {
      'calories': 30.0,
      'protein': 1.0,
      'carbs': 4.0,
      'fat': 1.0,
      'fiber': 0.0,
      'sugar': 3.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'cup',
    },
    'Coffee (with milk)': {
      'calories': 25.0,
      'protein': 1.0,
      'carbs': 3.0,
      'fat': 1.0,
      'fiber': 0.0,
      'sugar': 2.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': 'cup',
    },
    'Milk': {
      'calories': 42.0,
      'protein': 3.4,
      'carbs': 5.0,
      'fat': 1.0,
      'fiber': 0.0,
      'sugar': 5.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': '100ml',
    },
    'Juice (Orange)': {
      'calories': 45.0,
      'protein': 0.7,
      'carbs': 10.0,
      'fat': 0.2,
      'fiber': 0.2,
      'sugar': 9.0,
      'salt': 0.0,
      'sodium': 0.0,
      'per': '100ml',
    },
  };

  // --- Special (CSV) Foods ---
  static Map<String, List<Map<String, dynamic>>> _specialFoodsByCategory = {};
  static bool _specialLoaded = false;

  static Future<void> loadSpecialFoods() async {
    if (_specialLoaded) return;
    final csvString =
        await rootBundle.loadString('db/Indian_Food_Nutrition_Processed.csv');
    final rows =
        const CsvToListConverter(eol: '\n').convert(csvString, eol: '\n');
    if (rows.isEmpty) return;
    final header = rows[0] as List;
    final List<List<dynamic>> dataRows = rows.sublist(1);
    _specialFoodsByCategory.clear();
    for (final row in dataRows) {
      final food = Map<String, dynamic>.fromIterables(
        header.map((e) => e.toString()),
        row,
      );
      final name = (food['Dish Name'] ?? '').toString();
      final category = _categorizeSpecialFood(name);
      _specialFoodsByCategory.putIfAbsent(category, () => []).add(food);
    }
    _specialLoaded = true;
  }

  static List<String> getFoodCategories() {
    return ['Indian Foods', 'Fast Food', 'Beverages', 'Special'];
  }

  static List<String> getFoodsByCategory(String category) {
    switch (category) {
      case 'Indian Foods':
        return [
          'Rice (Cooked)',
          'Roti/Chapati',
          'Dal (Cooked)',
          'Sabzi (Mixed Vegetables)',
          'Curd/Yogurt',
          'Paneer',
          'Idli',
          'Dosa',
          'Samosa',
          'Pakora',
        ];
      case 'Fast Food':
        return [
          'Pizza (Slice)',
          'Burger',
          'French Fries',
          'Chicken Wings',
          'Noodles',
          'Sandwich',
          'Ice Cream',
          'Cake',
        ];
      case 'Beverages':
        return [
          'Tea (with milk)',
          'Coffee (with milk)',
          'Milk',
          'Juice (Orange)',
        ];
      default:
        return [];
    }
  }

  static List<String> getSpecialSubcategories() {
    return _specialFoodsByCategory.keys.toList();
  }

  static List<Map<String, dynamic>> getSpecialFoodsBySubcategory(
      String subcat) {
    return _specialFoodsByCategory[subcat] ?? [];
  }

  static Map<String, dynamic>? getFoodData(String foodName) {
    return _foodDatabase[foodName];
  }

  static Map<String, dynamic>? getSpecialFoodData(String name) {
    for (final foods in _specialFoodsByCategory.values) {
      for (final food in foods) {
        if (food['Dish Name'] == name) return food;
      }
    }
    return null;
  }

  static List<String> getAllFoodNames() {
    return _foodDatabase.keys.toList();
  }

  static String getFoodUnit(String foodName) {
    final data = _foodDatabase[foodName];
    final per = data?['per']?.toString().toLowerCase() ?? '100g';
    if (per.contains('ml') || per.contains('cup')) {
      return 'ml';
    } else if (per.contains('piece') ||
        per.contains('slice') ||
        per.contains('cup')) {
      return per;
    } else {
      return 'g';
    }
  }

  static Map<String, dynamic> calculateNutrition(
      String foodName, double quantity) {
    final foodData = _foodDatabase[foodName];
    if (foodData == null) return {};

    final per = foodData['per']?.toString().toLowerCase() ?? '100g';
    double baseAmount = 100.0;
    if (per.contains('ml')) {
      baseAmount = 100.0;
    } else if (per.contains('g')) {
      baseAmount = 100.0;
    } else if (per.contains('piece') ||
        per.contains('slice') ||
        per.contains('cup')) {
      baseAmount = 1.0;
    }
    final multiplier = quantity / baseAmount;

    return {
      'calories': (foodData['calories'] * multiplier).roundToDouble(),
      'protein': (foodData['protein'] * multiplier).roundToDouble(),
      'carbs': (foodData['carbs'] * multiplier).roundToDouble(),
      'fat': (foodData['fat'] * multiplier).roundToDouble(),
      'fiber': (foodData['fiber'] * multiplier).roundToDouble(),
      'sugar': (foodData['sugar'] * multiplier).roundToDouble(),
      'salt': (foodData['salt'] * multiplier).roundToDouble(),
      'sodium': (foodData['sodium'] * multiplier).roundToDouble(),
    };
  }

  static String _categorizeSpecialFood(String name) {
    final n = name.toLowerCase();
    if (n.contains('chai') ||
        n.contains('tea') ||
        n.contains('coffee') ||
        n.contains('drink') ||
        n.contains('milkshake') ||
        n.contains('lassi') ||
        n.contains('juice') ||
        n.contains('cocoa')) return 'Beverages';
    if (n.contains('paratha') ||
        n.contains('roti') ||
        n.contains('naan') ||
        n.contains('poori') ||
        n.contains('bread')) return 'Breads & Rotis';
    if (n.contains('rice') ||
        n.contains('pulao') ||
        n.contains('biryani') ||
        n.contains('chawal')) return 'Rice & Pulao';
    if (n.contains('dal') ||
        n.contains('sabzi') ||
        n.contains('curry') ||
        n.contains('kofta') ||
        n.contains('saag') ||
        n.contains('bhartha') ||
        n.contains('paneer') ||
        n.contains('mutton') ||
        n.contains('chicken') ||
        n.contains('fish') ||
        n.contains('egg') ||
        n.contains('keema')) return 'Curries & Sabzi';
    if (n.contains('pakora') ||
        n.contains('samosa') ||
        n.contains('cutlet') ||
        n.contains('vada') ||
        n.contains('kebab') ||
        n.contains('spring roll') ||
        n.contains('burger') ||
        n.contains('toast') ||
        n.contains('mathri') ||
        n.contains('kachori') ||
        n.contains('bonda')) return 'Snacks & Starters';
    if (n.contains('kheer') ||
        n.contains('halwa') ||
        n.contains('ice cream') ||
        n.contains('cake') ||
        n.contains('pudding') ||
        n.contains('burfi') ||
        n.contains('lado') ||
        n.contains('gulab jamun') ||
        n.contains('mal pua') ||
        n.contains('pastry') ||
        n.contains('cookie') ||
        n.contains('pie') ||
        n.contains('souffle') ||
        n.contains('mousse') ||
        n.contains('tart') ||
        n.contains('snowball') ||
        n.contains('kulfi') ||
        n.contains('custard') ||
        n.contains('sweet') ||
        n.contains('jam') ||
        n.contains('chikki')) return 'Sweets & Desserts';
    if (n.contains('salad')) return 'Salads';
    if (n.contains('raita')) return 'Raitas';
    if (n.contains('chutney')) return 'Chutneys';
    return 'Others';
  }

  // Helper: Get default unit for a food name (piece, bowl, cup, etc.)
  static String getDefaultUnit(String foodName) {
    final n = foodName.toLowerCase();
    // Piece-based foods
    if (n.contains('roti') ||
        n.contains('chapati') ||
        n.contains('paratha') ||
        n.contains('naan') ||
        n.contains('poori') ||
        n.contains('idli') ||
        n.contains('dosa') ||
        n.contains('samosa') ||
        n.contains('pakora') ||
        n.contains('cutlet') ||
        n.contains('vada') ||
        n.contains('kebab') ||
        n.contains('spring roll') ||
        n.contains('burger') ||
        n.contains('toast') ||
        n.contains('mathri') ||
        n.contains('kachori') ||
        n.contains('bonda') ||
        n.contains('pizza') ||
        n.contains('sandwich') ||
        n.contains('cake') ||
        n.contains('cookie') ||
        n.contains('lado') ||
        n.contains('gulab jamun')) {
      return 'piece';
    }
    // Bowl-based foods
    if (n.contains('dal') ||
        n.contains('sabzi') ||
        n.contains('curry') ||
        n.contains('kofta') ||
        n.contains('saag') ||
        n.contains('bhartha') ||
        n.contains('paneer') ||
        n.contains('mutton') ||
        n.contains('chicken') ||
        n.contains('fish') ||
        n.contains('egg') ||
        n.contains('keema') ||
        n.contains('rice') ||
        n.contains('pulao') ||
        n.contains('biryani') ||
        n.contains('chawal')) {
      return 'bowl';
    }
    // Cup-based foods
    if (n.contains('tea') ||
        n.contains('chai') ||
        n.contains('coffee') ||
        n.contains('milk') ||
        n.contains('lassi') ||
        n.contains('juice')) {
      return 'cup';
    }
    // Default fallback
    return 'g';
  }
}
