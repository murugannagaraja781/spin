import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';
import '../constants/api_config.dart';
import '../../data/local_db_service.dart';

class SyncService extends GetxService {
  Timer? _syncTimer;
  bool _isSyncing = false;
  final String _baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    _startAutoSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _startAutoSync() {
    // Run sync check every 25 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 25), (timer) async {
      await trySyncOfflineData();
    });
  }

  Future<void> trySyncOfflineData() async {
    if (_isSyncing) return;

    try {
      final winners = await LocalDbService.getWinners();
      final unsynced = winners.where((w) => w['synced'] != 1).toList();
      
      if (unsynced.isEmpty) return;

      _isSyncing = true;
      print('Auto-Sync: Found ${unsynced.length} unsynced entries. Checking server connection...');

      // 1. Check server health
      final response = await dio_pkg.Dio().get(
        '$_baseUrl/health.php',
        options: dio_pkg.Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode != 200) {
        _isSyncing = false;
        return;
      }

      int syncSuccessCount = 0;
      for (var winner in winners) {
        if (winner['synced'] == 1) {
          syncSuccessCount++;
          continue;
        }

        final formData = dio_pkg.FormData.fromMap({
          'salesman': winner['salesman'],
          'product': winner['product'],
          'customer_name': winner['customerName'],
          'mobile_number': winner['mobileNumber'],
          'prize': winner['prize'],
          'latitude': winner['latitude'] ?? '',
          'longitude': winner['longitude'] ?? '',
          'quantity': winner['quantity'] ?? 1,
          'order_total': winner['order_total'] ?? 0.00,
          'discount_applied': winner['discount_applied'] ?? 0.00,
          'net_amount': winner['net_amount'] ?? 0.00,
          'spin_eligible': winner['spin_eligible'] ?? 1,
        });

        if (winner['photoPath'] != null && winner['photoPath'].toString().isNotEmpty) {
          formData.files.add(
            MapEntry('photo', await dio_pkg.MultipartFile.fromFile(winner['photoPath'], filename: 'photo.jpg'))
          );
        }

        try {
          final postResponse = await dio_pkg.Dio().post(
            '$_baseUrl/submit.php',
            data: formData,
            options: dio_pkg.Options(
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

          if (postResponse.statusCode == 200) {
            winner['synced'] = 1;
            syncSuccessCount++;
          }
        } catch (e) {
          print('Auto-Sync: Entry upload failed: $e');
        }
      }

      if (syncSuccessCount == winners.length) {
        // All synced! Clear local database.
        await LocalDbService.clearAll();
        Get.snackbar(
          'Background Sync Complete',
          'All offline sales records have been successfully uploaded to the server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF0D1B2A).withOpacity(0.8),
          colorText: const Color(0xFFFFD700),
          duration: const Duration(seconds: 4),
        );
      } else {
        // Save the list (with some entries now updated as synced)
        await LocalDbService.saveWinners(winners);
      }
    } catch (e) {
      print('Auto-Sync: Network validation or upload failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
