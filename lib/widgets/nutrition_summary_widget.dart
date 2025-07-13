import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutridev/services/nutrition_summary_service.dart';
import 'package:nutridev/services/scan_history_service.dart';

class NutritionSummaryWidget extends StatefulWidget {
  const NutritionSummaryWidget({super.key});

  @override
  State<NutritionSummaryWidget> createState() => _NutritionSummaryWidgetState();
}

class _NutritionSummaryWidgetState extends State<NutritionSummaryWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NutritionSummaryService _summaryService = NutritionSummaryService();
  final RxMap<String, dynamic> _summaryData = <String, dynamic>{}.obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSummaryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSummaryData() async {
    _isLoading.value = true;
    try {
      final data = await _summaryService.getNutritionSummary();
      _summaryData.value = data;
    } catch (e) {
      print('Error loading summary data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xfff4f2f2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nutrition Summary',
                    style: GoogleFonts.lexend(
                      fontSize:
                          MediaQuery.of(context).size.width < 350 ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Obx(() => Text(
                      '${_summaryData['totalProducts'] ?? 0} products',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    )),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.grey[50],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.green,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Vitamins'),
                Tab(text: 'Minerals'),
                Tab(text: 'Other'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildVitaminsTab(),
                  _buildMineralsTab(),
                  _buildOtherTab(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calories Card
          _buildNutrientCard(
            'Total Calories',
            '${_summaryData['totalCalories']?.toStringAsFixed(0) ?? '0'} kcal',
            Icons.local_fire_department,
            Colors.orange,
          ),

          const SizedBox(height: 8),

          // Debug info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Debug: ${_summaryData['productsWithData'] ?? 0} products with data',
              style: GoogleFonts.lexend(fontSize: 10, color: Colors.grey[600]),
            ),
          ),

          const SizedBox(height: 12),

          // Macronutrients - Use Wrap for responsive layout
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 3,
                child: _buildNutrientCard(
                  'Protein',
                  '${_summaryData['totalProtein']?.toStringAsFixed(1) ?? '0'}g',
                  Icons.fitness_center,
                  Colors.blue,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 3,
                child: _buildNutrientCard(
                  'Carbs',
                  '${_summaryData['totalCarbs']?.toStringAsFixed(1) ?? '0'}g',
                  Icons.grain,
                  Colors.amber,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 3,
                child: _buildNutrientCard(
                  'Fat',
                  '${_summaryData['totalFat']?.toStringAsFixed(1) ?? '0'}g',
                  Icons.water_drop,
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Other Nutrients - Use Wrap for responsive layout
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 3,
                child: _buildNutrientCard(
                  'Fiber',
                  '${_summaryData['totalFiber']?.toStringAsFixed(1) ?? '0'}g',
                  Icons.eco,
                  Colors.green,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 3,
                child: _buildNutrientCard(
                  'Sugar',
                  '${_summaryData['totalSugar']?.toStringAsFixed(1) ?? '0'}g',
                  Icons.cake,
                  Colors.pink,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 3,
                child: _buildNutrientCard(
                  'Salt',
                  '${_summaryData['totalSalt']?.toStringAsFixed(2) ?? '0'}g',
                  Icons.restaurant,
                  Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Products with Data
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_summaryData['productsWithData'] ?? 0} products have nutrition data',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_summaryData['maxCalories'] != null &&
                    _summaryData['maxCalories'] > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Calorie range: ${_summaryData['minCalories']?.toStringAsFixed(0) ?? '0'} - ${_summaryData['maxCalories']?.toStringAsFixed(0) ?? '0'} kcal',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminsTab() {
    final vitamins = _summaryData['vitamins'] as Map<String, double>? ?? {};
    final ingredientsVitamins =
        _summaryData['ingredientsNutrients'] as Map<String, double>? ?? {};

    if (vitamins.isEmpty && ingredientsVitamins.isEmpty) {
      return _buildEmptyState('No vitamin data available');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vitamins from Nutrition Data',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...vitamins.entries.map((entry) => _buildNutrientItem(
                _summaryService.formatNutrientName(entry.key),
                '${entry.value.toStringAsFixed(2)} ${_summaryService.getNutrientUnit(entry.key)}',
                Icons.medication,
                Colors.orange,
              )),
          if (ingredientsVitamins.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Vitamins Found in Ingredients',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ingredientsVitamins.entries
                .where((entry) => entry.key.startsWith('vitamin'))
                .map((entry) => _buildNutrientItem(
                      _summaryService.formatNutrientName(entry.key),
                      'Found in ${entry.value.toInt()} product${entry.value.toInt() == 1 ? '' : 's'}',
                      Icons.list_alt,
                      Colors.green,
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildMineralsTab() {
    final minerals = _summaryData['minerals'] as Map<String, double>? ?? {};
    final ingredientsMinerals =
        _summaryData['ingredientsNutrients'] as Map<String, double>? ?? {};

    if (minerals.isEmpty && ingredientsMinerals.isEmpty) {
      return _buildEmptyState('No mineral data available');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minerals from Nutrition Data',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...minerals.entries.map((entry) => _buildNutrientItem(
                _summaryService.formatNutrientName(entry.key),
                '${entry.value.toStringAsFixed(2)} ${_summaryService.getNutrientUnit(entry.key)}',
                Icons.diamond,
                Colors.blue,
              )),
          if (ingredientsMinerals.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Minerals Found in Ingredients',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ingredientsMinerals.entries
                .where((entry) => [
                      'calcium',
                      'iron',
                      'magnesium',
                      'phosphorus',
                      'potassium',
                      'zinc',
                      'copper',
                      'manganese',
                      'selenium'
                    ].contains(entry.key))
                .map((entry) => _buildNutrientItem(
                      _summaryService.formatNutrientName(entry.key),
                      'Found in ${entry.value.toInt()} product${entry.value.toInt() == 1 ? '' : 's'}',
                      Icons.list_alt,
                      Colors.green,
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildOtherTab() {
    final otherNutrients =
        _summaryData['otherNutrients'] as Map<String, double>? ?? {};
    final ingredientsNutrients =
        _summaryData['ingredientsNutrients'] as Map<String, double>? ?? {};

    if (otherNutrients.isEmpty && ingredientsNutrients.isEmpty) {
      return _buildEmptyState('No additional nutrient data available');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Other Nutrients',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...otherNutrients.entries.map((entry) => _buildNutrientItem(
                _summaryService.formatNutrientName(entry.key),
                '${entry.value.toStringAsFixed(2)} ${_summaryService.getNutrientUnit(entry.key)}',
                Icons.science_outlined,
                Colors.purple,
              )),
          if (ingredientsNutrients.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Additional Nutrients in Ingredients',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ingredientsNutrients.entries
                .where((entry) =>
                    !entry.key.startsWith('vitamin') &&
                    ![
                      'calcium',
                      'iron',
                      'magnesium',
                      'phosphorus',
                      'potassium',
                      'zinc',
                      'copper',
                      'manganese',
                      'selenium'
                    ].contains(entry.key))
                .map((entry) => _buildNutrientItem(
                      _summaryService.formatNutrientName(entry.key),
                      'Found in ${entry.value.toInt()} product${entry.value.toInt() == 1 ? '' : 's'}',
                      Icons.list_alt,
                      Colors.green,
                    )),
          ],
        ],
      ),
    );
  }

  Widget _buildNutrientCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientItem(
      String name, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
