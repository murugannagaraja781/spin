import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_config.dart';

class SalesmanSelectionController extends GetxController {
  final salesmen = <String>[].obs;
  final isLoading = false.obs;
  final selectedSalesman = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCachedSalesmen();
    fetchSalesmenFromApi();
  }

  Future<void> loadCachedSalesmen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList('cached_salesmen');
      if (cached != null && cached.isNotEmpty) {
        salesmen.assignAll(cached);
      } else {
        // Fallback default list if no cache is present
        salesmen.assignAll([
          'Ramesh Kumar',
          'Suresh Singh',
          'Rajesh Sharma',
          'Vikram Patel'
        ]);
      }
    } catch (e) {
      print('Error loading cached salesmen: $e');
    }
  }

  Future<void> fetchSalesmenFromApi() async {
    isLoading.value = true;
    try {
      final response = await dio_pkg.Dio().get(
        '${ApiConfig.baseUrl}/get_salesmen.php',
        options: dio_pkg.Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final status = response.data['status'];
        final List<dynamic>? list = response.data['salesmen'] ?? response.data['data'];
        if (status == 'success' && list != null) {
          final loaded = list.map((e) {
            if (e is Map) {
              return e['name']?.toString() ?? e.toString();
            }
            final str = e.toString().trim();
            if (str.startsWith('{') && str.endsWith('}')) {
              final regExp = RegExp(r'name:\s*([^,}]+)');
              final match = regExp.firstMatch(str);
              if (match != null) {
                return match.group(1)!.trim();
              }
            }
            return str;
          }).toList();
          salesmen.assignAll(loaded);
          
          // Cache locally for future offline use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('cached_salesmen', loaded);
        }
      }
    } catch (e) {
      print('Error fetching salesmen: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectSalesman(String? salesman) {
    if (salesman != null) {
      selectedSalesman.value = salesman;
    }
  }

  void continueToCustomer() {
    if (selectedSalesman.value.isEmpty) {
      Get.snackbar('Selection Required', 'Please select a salesman.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    Get.toNamed('/customer-selection', arguments: {
      'salesman': selectedSalesman.value,
    });
  }

  void continueToDirectSales() {
    if (selectedSalesman.value.isEmpty) {
      Get.snackbar('Selection Required', 'Please select a salesman.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    Get.toNamed('/direct-sales', arguments: {
      'salesman': selectedSalesman.value,
    });
  }

  void logout() {
    Get.offAllNamed('/login');
  }
}
