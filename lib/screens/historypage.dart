import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutridev/screens/nutrition_details.dart';
import 'package:nutridev/services/scan_history_service.dart';
import 'package:nutridev/widgets/nutrition_summary_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scanHistoryService = Get.find<ScanHistoryService>();
    final theme = Theme.of(context);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Responsive dimensions
    final horizontalPadding = isMobile
        ? 12.0
        : isTablet
            ? 16.0
            : 20.0;
    final iconSize = isMobile
        ? 48.0
        : isTablet
            ? 56.0
            : 64.0;
    final fontSize = isMobile
        ? 14.0
        : isTablet
            ? 16.0
            : 18.0;
    final smallFontSize = isMobile
        ? 10.0
        : isTablet
            ? 12.0
            : 14.0;
    final summaryHeight = isMobile
        ? 300.0
        : isTablet
            ? 350.0
            : 400.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History', style: GoogleFonts.lexend()),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep, color: theme.colorScheme.onPrimary),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('Clear History',
                      style: theme.textTheme.headlineSmall),
                  content: Text(
                      'Are you sure you want to clear all scan history?',
                      style: theme.textTheme.bodyMedium),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel',
                          style: TextStyle(color: theme.colorScheme.primary)),
                    ),
                    TextButton(
                      onPressed: () {
                        scanHistoryService.clearHistory();
                        Get.back();
                      },
                      child: Text('Clear',
                          style: TextStyle(color: theme.colorScheme.tertiary)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final history = scanHistoryService.getHistory();

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: iconSize,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No scan history yet',
                  style: GoogleFonts.lexend(
                    fontSize: fontSize + 2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan some products to see them here',
                  style: GoogleFonts.lexend(
                    fontSize: fontSize - 2,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Nutrition Summary Widget
            SizedBox(
              height: summaryHeight,
              child: const NutritionSummaryWidget(),
            ),

            // Divider
            Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child:
                  Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
            ),

            // History List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(horizontalPadding),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final barcode = item['barcode'] ?? '';
                  final name = item['name'] ?? 'Unknown Product';
                  final scannedAt = item['scannedAt'] ?? '';
                  final scanTime = scanHistoryService.formatScanTime(scannedAt);
                  final isManual = item['manual'] == true;
                  final quantity = item['quantity']?.toString() ?? '';

                  return Card(
                    margin: EdgeInsets.only(bottom: horizontalPadding - 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(horizontalPadding),
                      leading: Container(
                        width: iconSize - 16,
                        height: iconSize - 16,
                        decoration: BoxDecoration(
                          color: isManual
                              ? theme.colorScheme.secondary.withOpacity(0.2)
                              : theme.colorScheme.onSurface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isManual ? Icons.restaurant : Icons.qr_code_scanner,
                          color: isManual
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.lexend(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isManual)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Manual',
                                style: GoogleFonts.lexend(
                                  fontSize: smallFontSize,
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (isManual) ...[
                            Text(
                              'Quantity: $quantity',
                              style: GoogleFonts.lexend(
                                fontSize: smallFontSize,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ] else ...[
                            Text(
                              'Barcode: $barcode',
                              style: GoogleFonts.lexend(
                                fontSize: smallFontSize,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            scanTime,
                            style: GoogleFonts.lexend(
                              fontSize: smallFontSize,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'view') {
                            if (isManual) {
                              // Show manual food details in a dialog
                              _showManualFoodDetails(item);
                            } else if (barcode.isNotEmpty) {
                              Get.to(
                                  () => NutritionDetailsPage(barcode: barcode));
                            }
                          } else if (value == 'remove') {
                            if (isManual) {
                              // Remove manual entry by name and timestamp
                              final removeKey =
                                  '${item['name']}_${item['scannedAt']}';
                              scanHistoryService.removeFromHistory(removeKey);
                            } else {
                              scanHistoryService.removeFromHistory(barcode);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility,
                                    size: 18,
                                    color: theme.colorScheme.onSurface),
                                SizedBox(width: 8),
                                Text(isManual ? 'View Details' : 'View Details',
                                    style: TextStyle(
                                        color: theme.colorScheme.onSurface)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    size: 18,
                                    color: theme.colorScheme.tertiary),
                                SizedBox(width: 8),
                                Text('Remove',
                                    style: TextStyle(
                                        color: theme.colorScheme.tertiary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showManualFoodDetails(Map<String, dynamic> item) {
    final nutrition = item['nutrition'] as Map<String, dynamic>?;
    final quantity = item['quantity']?.toString() ?? '';
    final scanHistoryService = Get.find<ScanHistoryService>();
    final scanTime = scanHistoryService.formatScanTime(item['scannedAt'] ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(
          '${item['name']} Details',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantity: $quantity',
                style: GoogleFonts.lexend(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Added: $scanTime',
                style:
                    GoogleFonts.lexend(fontSize: 14, color: Colors.grey[600]),
              ),
              if (nutrition != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Nutrition Information:',
                  style: GoogleFonts.lexend(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildNutritionRow('Calories',
                    '${nutrition['calories']?.toStringAsFixed(1) ?? '0'} kcal'),
                _buildNutritionRow('Protein',
                    '${nutrition['protein']?.toStringAsFixed(1) ?? '0'}g'),
                _buildNutritionRow('Carbs',
                    '${nutrition['carbs']?.toStringAsFixed(1) ?? '0'}g'),
                _buildNutritionRow(
                    'Fat', '${nutrition['fat']?.toStringAsFixed(1) ?? '0'}g'),
                _buildNutritionRow('Fiber',
                    '${nutrition['fiber']?.toStringAsFixed(1) ?? '0'}g'),
                _buildNutritionRow('Sugar',
                    '${nutrition['sugar']?.toStringAsFixed(1) ?? '0'}g'),
                _buildNutritionRow(
                    'Salt', '${nutrition['salt']?.toStringAsFixed(1) ?? '0'}g'),
                _buildNutritionRow('Sodium',
                    '${nutrition['sodium']?.toStringAsFixed(1) ?? '0'}mg'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: GoogleFonts.lexend(fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
            style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            value,
            style:
                GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
