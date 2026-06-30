import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../core/constants/api_config.dart';

class CustomerSelectionController extends GetxController {
  final customers = <Map<String, dynamic>>[].obs;
  final filteredCustomers = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final selectedCustomer = Rxn<Map<String, dynamic>>();

  final newCustName = ''.obs;
  final newCustMobile = ''.obs;

  late String salesman;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    salesman = args['salesman']?.toString() ?? '';
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    try {
      final response = await dio_pkg.Dio().get('${ApiConfig.baseUrl}/get_customers.php');
      if (response.statusCode == 200 && response.data != null) {
        var responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (_) {}
        }
        if (responseData['status'] == 'success') {
          final List dataList = responseData['data'] ?? [];
          final list = dataList.map((e) => Map<String, dynamic>.from(e)).toList();
          customers.assignAll(list);
          filterCustomers('');
        }
      }
    } catch (e) {
      print('Error fetching customers: $e');
      // Fallback local dummy customers
      customers.assignAll([
        {'id': 1, 'name': 'Sri Balaji Provisions', 'mobile': '9876543210'},
        {'id': 2, 'name': 'Venkateswara Traders', 'mobile': '9876543211'},
        {'id': 3, 'name': 'Murugan Grocery Shop', 'mobile': '9876543212'},
        {'id': 4, 'name': 'Srinivasa Super Market', 'mobile': '9876543213'},
      ]);
      filterCustomers('');
    } finally {
      isLoading.value = false;
    }
  }

  void filterCustomers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCustomers.assignAll(customers);
    } else {
      filteredCustomers.assignAll(
        customers.where((c) => c['name'].toString().toLowerCase().contains(query.toLowerCase())).toList()
      );
    }
  }

  Future<void> addCustomer() async {
    final name = newCustName.value.trim();
    final mobile = newCustMobile.value.trim();

    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter a customer name.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final response = await dio_pkg.Dio().post(
        '${ApiConfig.baseUrl}/add_customer.php',
        data: {'name': name, 'mobile': mobile},
        options: dio_pkg.Options(contentType: dio_pkg.Headers.formUrlEncodedContentType)
      );

      if (response.statusCode == 200 && response.data != null) {
        var responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (_) {}
        }
        if (responseData['status'] == 'success') {
          final newCust = Map<String, dynamic>.from(responseData['data']);
          customers.add(newCust);
          filterCustomers(searchQuery.value);
          selectCustomer(newCust);
          newCustName.value = '';
          newCustMobile.value = '';
          Get.back(); // close dialog
          Get.snackbar('Success', 'Customer added successfully!', snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar('Error', responseData['message'] ?? 'Failed to add customer', snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      // Local backup if offline
      final localCust = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': name,
        'mobile': mobile
      };
      customers.add(localCust);
      filterCustomers(searchQuery.value);
      selectCustomer(localCust);
      newCustName.value = '';
      newCustMobile.value = '';
      Get.back(); // close dialog
      Get.snackbar('Success (Offline)', 'Customer added locally.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectCustomer(Map<String, dynamic> customer) {
    selectedCustomer.value = customer;
  }

  void proceedToProduct() {
    if (selectedCustomer.value == null) {
      Get.snackbar('Selection Required', 'Please select a customer first.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    Get.toNamed('/product-selection', arguments: {
      'salesman': salesman,
      'customerName': selectedCustomer.value!['name'],
      'customerMobile': selectedCustomer.value!['mobile'] ?? '',
    });
  }
}
