import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../core/constants/api_config.dart';

class ProductSelectionController extends GetxController {
  final qtyTextController = TextEditingController(text: '1');
  final selectedProduct = Rxn<Map<String, dynamic>>();
  final products = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  
  final quantity = 1.obs;
  final orderTotal = 0.0.obs;

  late String salesman;
  late String customerName;
  late String customerMobile;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    salesman = args['salesman']?.toString() ?? '';
    customerName = args['customerName']?.toString() ?? 'Walk-in Customer';
    customerMobile = args['customerMobile']?.toString() ?? '';
    fetchProducts();

    quantity.listen((val) {
      if (qtyTextController.text != val.toString()) {
        qtyTextController.text = val.toString();
      }
    });
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await dio_pkg.Dio().get('${ApiConfig.baseUrl}/get_products.php');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final data = response.data['data'] as List;
          products.assignAll(
            data.map((item) => Map<String, dynamic>.from(item as Map)).toList()
          );
          
          // Auto-select first product
          if (products.isNotEmpty) {
            selectProduct(products.first);
          }
        }
      }
    } catch (e) {
      print('Product fetch error: $e');
      // Fallback local products
      products.assignAll([
        {'id': 1, 'name': '₹10 Product', 'price': 10.00},
        {'id': 2, 'name': '₹20 Product', 'price': 20.00},
      ]);
      if (products.isNotEmpty) {
        selectProduct(products.first);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectProduct(Map<String, dynamic> product) {
    selectedProduct.value = product;
    calculateTotal();
  }

  void updateQuantity(int val) {
    if (val < 1) return;
    quantity.value = val;
    calculateTotal();
  }

  void calculateTotal() {
    if (selectedProduct.value != null) {
      final double price = double.tryParse(selectedProduct.value!['price'].toString()) ?? 0.0;
      orderTotal.value = price * quantity.value;
    } else {
      orderTotal.value = 0.0;
    }
  }

  void proceedToSpin() {
    if (selectedProduct.value == null) {
      Get.snackbar('Selection Required', 'Please select a product first.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.toNamed('/mobile-validation', arguments: {
      'salesman': salesman,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'product': selectedProduct.value!['name'],
      'price': selectedProduct.value!['price'].toString(),
      'quantity': quantity.value,
      'orderTotal': orderTotal.value,
      'spin_eligible': true,
    });
  }

  void proceedToDirectComplete() {
    if (selectedProduct.value == null) {
      Get.snackbar('Selection Required', 'Please select a product first.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.toNamed('/submit-success', arguments: {
      'salesman': salesman,
      'customerName': customerName,
      'mobileNumber': customerMobile.isEmpty ? '9876543210' : customerMobile,
      'product': selectedProduct.value!['name'],
      'price': selectedProduct.value!['price'].toString(),
      'quantity': quantity.value,
      'orderTotal': orderTotal.value,
      'prize': '',
      'discount_applied': 0.0,
      'net_amount': orderTotal.value,
      'spin_eligible': false,
      'photoPath': '',
    });
  }
}
