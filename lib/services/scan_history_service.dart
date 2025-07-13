import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class ScanHistoryService extends GetxService {
  static const String _historyKey = 'scan_history';
  final RxList<Map<String, dynamic>> scanHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadScanHistory();
  }

  Future<void> loadScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        scanHistory.assignAll(
          historyList.map((item) => Map<String, dynamic>.from(item)).toList(),
        );
      }
    } catch (e) {
      print('Error loading scan history: $e');
    }
  }

  Future<void> saveScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(scanHistory.toList());
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      print('Error saving scan history: $e');
    }
  }

  Future<void> addToHistory(Map<String, dynamic> productData) async {
    // Check if product already exists in history
    final existingIndex = scanHistory.indexWhere(
      (item) => item['barcode'] == productData['barcode'],
    );

    if (existingIndex != -1) {
      // Update existing entry with new scan time
      scanHistory[existingIndex] = {
        ...productData,
        'scannedAt': DateTime.now().toIso8601String(),
      };
    } else {
      // Add new entry
      scanHistory.add({
        ...productData,
        'scannedAt': DateTime.now().toIso8601String(),
      });
    }

    // Keep only last 50 items to prevent storage issues
    if (scanHistory.length > 50) {
      scanHistory.removeRange(0, scanHistory.length - 50);
    }

    await saveScanHistory();
  }

  Future<void> removeFromHistory(String identifier) async {
    // Check if this is a manual entry key (contains underscore and timestamp)
    if (identifier.contains('_') && identifier.contains('T')) {
      // This is a manual entry key in format "name_timestamp"
      final parts = identifier.split('_');
      if (parts.length >= 2) {
        final name = parts[0];
        final timestamp = parts
            .sublist(1)
            .join('_'); // Rejoin in case name contains underscores

        scanHistory.removeWhere(
            (item) => item['name'] == name && item['scannedAt'] == timestamp);
      }
    } else {
      // This is a barcode for scanned products
      scanHistory.removeWhere((item) => item['barcode'] == identifier);
    }
    await saveScanHistory();
  }

  Future<void> clearHistory() async {
    scanHistory.clear();
    await saveScanHistory();
  }

  List<Map<String, dynamic>> getHistory() {
    print(
        'DEBUG: ScanHistoryService.getHistory() called, scanHistory length: ${scanHistory.length}');
    // Return history sorted by most recent first
    final sortedHistory = List<Map<String, dynamic>>.from(scanHistory);
    sortedHistory.sort((a, b) {
      final aTime = DateTime.parse(a['scannedAt'] ?? '1970-01-01');
      final bTime = DateTime.parse(b['scannedAt'] ?? '1970-01-01');
      return bTime.compareTo(aTime);
    });
    print('DEBUG: Returning ${sortedHistory.length} items from getHistory()');
    return sortedHistory;
  }

  String formatScanTime(String? isoString) {
    if (isoString == null) return 'Unknown';

    try {
      final scanTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(scanTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
