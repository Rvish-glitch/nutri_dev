import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutridev/services/food_database_service.dart';
import 'dart:async';

class AddFoodDialog extends StatefulWidget {
  final Function(
          String foodName, double quantity, Map<String, dynamic> nutritionData)
      onFoodAdded;

  const AddFoodDialog({
    super.key,
    required this.onFoodAdded,
  });

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  String _selectedCategory = 'Indian Foods';
  String? _selectedFood;
  String? _selectedSpecialSubcategory;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pieceWeightController =
      TextEditingController(text: '100');
  String _searchQuery = '';
  Map<String, dynamic>? _nutritionPreview;
  List<String> _specialSubcategories = [];
  List<Map<String, dynamic>> _specialFoods = [];
  bool _specialLoading = false;
  String _currentUnit = 'g';

  @override
  void initState() {
    super.initState();
    _quantityController.text = '100';
    _updateNutritionPreview();
    _initSpecial();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _initSpecial() async {
    setState(() {
      _specialLoading = true;
    });
    await FoodDatabaseService.loadSpecialFoods();
    setState(() {
      _specialSubcategories = FoodDatabaseService.getSpecialSubcategories();
      _selectedSpecialSubcategory =
          _specialSubcategories.isNotEmpty ? _specialSubcategories[0] : null;
      _specialFoods = _selectedSpecialSubcategory != null
          ? FoodDatabaseService.getSpecialFoodsBySubcategory(
              _selectedSpecialSubcategory!)
          : [];
      _specialLoading = false;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _searchController.dispose();
    _pieceWeightController.dispose();
    super.dispose();
  }

  void _updateNutritionPreview() {
    if (_selectedCategory == 'Special') {
      if (_selectedFood != null) {
        final food = FoodDatabaseService.getSpecialFoodData(_selectedFood!);
        final quantity = double.tryParse(_quantityController.text) ?? 0.0;
        if (food != null && quantity > 0) {
          setState(() {
            _nutritionPreview = _calcSpecialNutrition(food, quantity);
          });
        }
      }
    } else if (_selectedFood != null) {
      final quantity = double.tryParse(_quantityController.text) ?? 0.0;
      if (quantity > 0) {
        setState(() {
          _nutritionPreview =
              FoodDatabaseService.calculateNutrition(_selectedFood!, quantity);
        });
      }
    }
  }

  void _updateDefaultQuantityForUnit() {
    String unit = 'g';
    if (_selectedFood != null) {
      unit = FoodDatabaseService.getDefaultUnit(_selectedFood!);
    }
    _currentUnit = unit;
    if (unit == 'piece' || unit == 'slice' || unit == 'cup' || unit == 'bowl') {
      _quantityController.text = '1';
      _pieceWeightController.text =
          unit == 'piece' ? '40' : (unit == 'bowl' ? '200' : '100');
    } else {
      _quantityController.text = '100';
    }
  }

  Map<String, dynamic> _calcSpecialNutrition(
      Map<String, dynamic> food, double quantity) {
    // All values are per 100g unless otherwise specified
    double factor = quantity / 100.0;
    return {
      'calories':
          (double.tryParse(food['Calories (kcal)'].toString()) ?? 0.0) * factor,
      'protein':
          (double.tryParse(food['Protein (g)'].toString()) ?? 0.0) * factor,
      'carbs': (double.tryParse(food['Carbohydrates (g)'].toString()) ?? 0.0) *
          factor,
      'fat': (double.tryParse(food['Fats (g)'].toString()) ?? 0.0) * factor,
      'fiber': (double.tryParse(food['Fibre (g)'].toString()) ?? 0.0) * factor,
      'sugar':
          (double.tryParse(food['Free Sugar (g)'].toString()) ?? 0.0) * factor,
      'salt': 0.0, // Not available
      'sodium': (double.tryParse(food['Sodium (mg)'].toString()) ?? 0.0) *
          factor /
          1000.0, // mg to g
    };
  }

  @override
  Widget build(BuildContext context) {
    final categories = FoodDatabaseService.getFoodCategories();
    final allFoods = _selectedCategory == 'Special'
        ? (_specialFoods
            .map((f) => f['Dish Name'].toString())
            .toSet()
            .toList()) // remove duplicates
        : FoodDatabaseService.getFoodsByCategory(_selectedCategory)
            .toSet()
            .toList(); // remove duplicates
    final foods = _searchQuery.isEmpty
        ? allFoods
        : allFoods
            .where((food) => food.toLowerCase().contains(_searchQuery))
            .toList();

    // Fix: If selected food is not in the filtered foods, reset it
    if (_selectedFood != null && !foods.contains(_selectedFood)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedFood = null;
          _nutritionPreview = null;
        });
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Add Food',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection
                    Text(
                      'Category',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child:
                                Text(category, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedCategory = value!;
                            _selectedFood = null;
                            _nutritionPreview = null;
                          });
                          if (value == 'Special') {
                            await _initSpecial();
                          }
                        },
                      ),
                    ),

                    if (_selectedCategory == 'Special') ...[
                      const SizedBox(height: 16),
                      Text(
                        'Subcategory',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedSpecialSubcategory,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: _specialSubcategories.map((subcat) {
                            return DropdownMenuItem(
                              value: subcat,
                              child:
                                  Text(subcat, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecialSubcategory = value;
                              _selectedFood = null;
                              _nutritionPreview = null;
                              _specialFoods = value != null
                                  ? FoodDatabaseService
                                      .getSpecialFoodsBySubcategory(value)
                                  : [];
                            });
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search food...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Food Selection
                    Text(
                      'Food Item',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedFood,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Select a food item',
                        ),
                        items: foods.map((food) {
                          final unit = _selectedCategory == 'Special'
                              ? '100g'
                              : FoodDatabaseService.getFoodUnit(food);
                          return DropdownMenuItem(
                            value: food,
                            child: Text(
                              '$food ($unit)',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFood = value;
                            _updateDefaultQuantityForUnit();
                            _updateNutritionPreview();
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quantity Input
                    Text(
                      'Quantity',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Enter quantity',
                        suffixText: _selectedFood != null
                            ? (_selectedCategory == 'Special'
                                ? 'g'
                                : FoodDatabaseService.getFoodUnit(
                                    _selectedFood!))
                            : 'g',
                      ),
                      onChanged: (value) => _updateNutritionPreview(),
                    ),
                    if (_currentUnit == 'piece' ||
                        _currentUnit == 'slice' ||
                        _currentUnit == 'cup' ||
                        _currentUnit == 'bowl') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pieceWeightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: 'Approx. weight per ${_currentUnit}',
                                suffixText: 'g',
                              ),
                              onChanged: (value) => _updateNutritionPreview(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('per ${_currentUnit} (default: 100g)',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Nutrition Preview
                    if (_nutritionPreview != null) ...[
                      Text(
                        'Nutrition Preview',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildNutritionRow('Calories',
                                '${_nutritionPreview!['calories']?.toStringAsFixed(0) ?? '0'} kcal'),
                            _buildNutritionRow('Protein',
                                '${_nutritionPreview!['protein']?.toStringAsFixed(1) ?? '0'}g'),
                            _buildNutritionRow('Carbs',
                                '${_nutritionPreview!['carbs']?.toStringAsFixed(1) ?? '0'}g'),
                            _buildNutritionRow('Fat',
                                '${_nutritionPreview!['fat']?.toStringAsFixed(1) ?? '0'}g'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedFood != null &&
                              _nutritionPreview != null
                          ? () {
                              final quantity =
                                  double.tryParse(_quantityController.text) ??
                                      0.0;
                              if (quantity > 0) {
                                widget.onFoodAdded(_selectedFood!, quantity,
                                    _nutritionPreview!);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Food'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
