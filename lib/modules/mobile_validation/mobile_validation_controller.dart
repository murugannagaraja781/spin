import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../core/constants/api_config.dart';
import '../../data/local_db_service.dart';

class MobileValidationController extends GetxController {
  final mobileNumber = ''.obs;
  final isLoading = false.obs;

  late String salesman;
  late String customerName;
  late String customerMobile;
  late String product;
  late String price;
  late int quantity;
  late double orderTotal;
  late bool spinEligible;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    salesman = args['salesman']?.toString() ?? '';
    customerName = args['customerName']?.toString() ?? '';
    customerMobile = args['customerMobile']?.toString() ?? '';
    product = args['product']?.toString() ?? '';
    price = args['price']?.toString() ?? '';
    quantity = args['quantity'] as int? ?? 1;
    orderTotal = args['orderTotal'] as double? ?? 0.0;
    spinEligible = args['spin_eligible'] as bool? ?? true;

    // Pre-populate if customer already has mobile number
    if (customerMobile.isNotEmpty) {
      mobileNumber.value = customerMobile;
    }
  }

  Future<void> validateAndProceed() async {
    final mobile = mobileNumber.value.trim();

    if (mobile.length < 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      Get.snackbar('Validation Error', 'Please enter a valid 10-digit mobile number.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // 1. Check Offline local DB first
      final isUsedLocal = await LocalDbService.isMobileUsedToday(mobile, product);
      if (isUsedLocal) {
        Get.snackbar(
          'Already Spun Today', 
          'This mobile number has already completed a spin for this product today (Offline Check).', 
          snackPosition: SnackPosition.BOTTOM
        );
        isLoading.value = false;
        return;
      }

      // 2. Check Online API
      final response = await dio_pkg.Dio().post(
        '${ApiConfig.baseUrl}/validate_mobile.php',
        data: {
          'mobile': mobile,
          'product': product,
        },
        options: dio_pkg.Options(
          contentType: dio_pkg.Headers.formUrlEncodedContentType,
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        var responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            // Fallback to offline validation if JSON is corrupt
            _navigateToSpin(mobile);
            return;
          }
        }

        if (responseData['status'] == 'success') {
          // Success! Navigate to spin wheel
          _navigateToSpin(mobile);
        } else {
          // Failed validation (already spun today)
          Get.snackbar(
            'Spin Limit Reached', 
            responseData['message'] ?? 'This mobile number has already spun today.', 
            snackPosition: SnackPosition.BOTTOM
          );
        }
      } else {
        // Fallback to offline approval if status is not 200
        _navigateToSpin(mobile);
      }
    } catch (e) {
      print('Network validation failed: $e. Proceeding with offline-first check.');
      // If network fails, since offline check passed, we let them proceed
      _navigateToSpin(mobile);
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateToSpin(String mobile) {
    Get.toNamed('/spin-wheel', arguments: {
      'salesman': salesman,
      'customerName': customerName,
      'mobileNumber': mobile,
      'product': product,
      'price': price,
      'quantity': quantity,
      'orderTotal': orderTotal,
      'spin_eligible': true,
    });
  }
}
