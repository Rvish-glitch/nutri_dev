import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutridev/services/food_database_service.dart';

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
  final TextEditingController _quantityController = TextEditingController();
  Map<String, dynamic>? _nutritionPreview;

  @override
  void initState() {
    super.initState();
    _quantityController.text = '100';
    _updateNutritionPreview();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateNutritionPreview() {
    if (_selectedFood != null) {
      final quantity = double.tryParse(_quantityController.text) ?? 0.0;
      if (quantity > 0) {
        setState(() {
          _nutritionPreview =
              FoodDatabaseService.calculateNutrition(_selectedFood!, quantity);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = FoodDatabaseService.getFoodCategories();
    final foods = FoodDatabaseService.getFoodsByCategory(_selectedCategory);

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
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _selectedFood = null;
                            _updateNutritionPreview();
                          });
                        },
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
                          final unit = FoodDatabaseService.getFoodUnit(food);
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
                            ? FoodDatabaseService.getFoodUnit(_selectedFood!)
                            : 'g',
                      ),
                      onChanged: (value) => _updateNutritionPreview(),
                    ),

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
