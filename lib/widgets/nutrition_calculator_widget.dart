import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionCalculatorWidget extends StatefulWidget {
  const NutritionCalculatorWidget({super.key});

  @override
  State<NutritionCalculatorWidget> createState() =>
      _NutritionCalculatorWidgetState();
}

class _NutritionCalculatorWidgetState extends State<NutritionCalculatorWidget> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedActivityLevel = 'Moderate';

  Map<String, dynamic>? _nutritionRecommendations;

  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active'
  ];

  final Map<String, double> _activityMultipliers = {
    'Sedentary': 1.2,
    'Light': 1.375,
    'Moderate': 1.55,
    'Active': 1.725,
    'Very Active': 1.9,
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _weightController.text = prefs.getString('nutrition_weight') ?? '';
      _heightController.text = prefs.getString('nutrition_height') ?? '';
      _ageController.text = prefs.getString('nutrition_age') ?? '';
      _selectedGender = prefs.getString('nutrition_gender') ?? 'Male';
      _selectedActivityLevel =
          prefs.getString('nutrition_activity') ?? 'Moderate';
    });

    // If we have saved data, calculate nutrition automatically
    if (_weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _ageController.text.isNotEmpty) {
      _calculateNutrition();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nutrition_weight', _weightController.text);
    await prefs.setString('nutrition_height', _heightController.text);
    await prefs.setString('nutrition_age', _ageController.text);
    await prefs.setString('nutrition_gender', _selectedGender);
    await prefs.setString('nutrition_activity', _selectedActivityLevel);

    // Save nutrition recommendations
    if (_nutritionRecommendations != null) {
      await prefs.setString(
          'nutrition_recommendations', _nutritionRecommendations.toString());
    }
  }

  Future<void> _clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('nutrition_weight');
    await prefs.remove('nutrition_height');
    await prefs.remove('nutrition_age');
    await prefs.remove('nutrition_gender');
    await prefs.remove('nutrition_activity');
    await prefs.remove('nutrition_recommendations');

    setState(() {
      _weightController.clear();
      _heightController.clear();
      _ageController.clear();
      _selectedGender = 'Male';
      _selectedActivityLevel = 'Moderate';
      _nutritionRecommendations = null;
    });

    Get.snackbar(
      'Success',
      'Saved data cleared successfully',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
    );
  }

  void _calculateNutrition() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);

    if (weight == null || height == null || age == null) {
      Get.snackbar(
        'Error',
        'Please enter valid weight, height, and age',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr;
    if (_selectedGender == 'Male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Calculate TDEE (Total Daily Energy Expenditure)
    final tdee = bmr * _activityMultipliers[_selectedActivityLevel]!;

    // Calculate BMI
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);

    // Calculate protein needs (1.2-2.0g per kg for most people)
    final proteinGrams =
        weight * 1.6; // Using 1.6g per kg as moderate recommendation

    // Calculate other macronutrients
    final fatGrams = (tdee * 0.25) / 9; // 25% of calories from fat
    final carbGrams = (tdee - (proteinGrams * 4) - (fatGrams * 9)) /
        4; // Remaining calories from carbs

    setState(() {
      _nutritionRecommendations = {
        'bmi': bmi,
        'bmr': bmr,
        'tdee': tdee,
        'protein': proteinGrams,
        'fat': fatGrams,
        'carbs': carbGrams,
        'weight': weight,
        'height': height,
        'age': age,
      };
    });

    // Save the data after calculation
    _saveData();
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nutrition Calculator',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                  if (_weightController.text.isNotEmpty ||
                      _heightController.text.isNotEmpty ||
                      _ageController.text.isNotEmpty)
                    IconButton(
                      onPressed: _clearSavedData,
                      icon: Icon(Icons.clear, color: Colors.red[600], size: 20),
                      tooltip: 'Clear saved data',
                    ),
                ],
              ),
              if (_weightController.text.isNotEmpty ||
                  _heightController.text.isNotEmpty ||
                  _ageController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[600], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Using saved data',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Input Fields
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      icon: Icons.height,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedGender,
                      items: _genderOptions,
                      label: 'Gender',
                      onChanged: (value) {
                        setState(() => _selectedGender = value!);
                        _saveData();
                        // Recalculate if we have all required data
                        if (_weightController.text.isNotEmpty &&
                            _heightController.text.isNotEmpty &&
                            _ageController.text.isNotEmpty) {
                          _calculateNutrition();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildDropdown(
                value: _selectedActivityLevel,
                items: _activityLevels,
                label: 'Activity Level',
                onChanged: (value) {
                  setState(() => _selectedActivityLevel = value!);
                  _saveData();
                  // Recalculate if we have all required data
                  if (_weightController.text.isNotEmpty &&
                      _heightController.text.isNotEmpty &&
                      _ageController.text.isNotEmpty) {
                    _calculateNutrition();
                  }
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateNutrition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Calculate Nutrition',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              if (_nutritionRecommendations != null) ...[
                const SizedBox(height: 20),
                _buildResultsCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _saveData();
        // Recalculate if we have all required data
        if (_weightController.text.isNotEmpty &&
            _heightController.text.isNotEmpty &&
            _ageController.text.isNotEmpty) {
          _calculateNutrition();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildResultsCard() {
    final rec = _nutritionRecommendations!;
    final bmi = rec['bmi'] as double;
    final bmiCategory = _getBMICategory(bmi);
    final bmiColor = _getBMIColor(bmi);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Nutrition Recommendations',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // BMI Section
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'BMI',
                  bmi.toStringAsFixed(1),
                  bmiCategory,
                  Icons.monitor_weight_outlined,
                  bmiColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  'BMR',
                  '${rec['bmr'].toStringAsFixed(0)} kcal',
                  'Basal Metabolic Rate',
                  Icons.local_fire_department_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily Calories
          _buildMetricCard(
            'Daily Calories',
            '${rec['tdee'].toStringAsFixed(0)} kcal',
            'Total Daily Energy Expenditure',
            Icons.restaurant_menu,
            Colors.green,
            fullWidth: true,
          ),
          const SizedBox(height: 12),

          // Macronutrients
          Text(
            'Daily Macronutrients',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildMacroCard(
                  'Protein',
                  '${rec['protein'].toStringAsFixed(0)}g',
                  Colors.red[100]!,
                  Colors.red[700]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard(
                  'Carbs',
                  '${rec['carbs'].toStringAsFixed(0)}g',
                  Colors.blue[100]!,
                  Colors.blue[700]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard(
                  'Fat',
                  '${rec['fat'].toStringAsFixed(0)}g',
                  Colors.yellow[100]!,
                  Colors.yellow[700]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.lexend(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
