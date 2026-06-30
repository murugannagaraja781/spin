import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:geolocator/geolocator.dart';
import '../../core/constants/api_config.dart';
import '../../data/local_db_service.dart';

class DirectSalesController extends GetxController {
  final salesman = ''.obs;
  final products = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // Form states
  final selectedProduct = Rxn<Map<String, dynamic>>();
  final quantity = 1.obs;

  // Cart state
  final cartItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    salesman.value = args['salesman'] ?? '';
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await dio_pkg.Dio().get(
        '${ApiConfig.baseUrl}/get_products.php',
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final List list = response.data['data'] ?? [];
          products.assignAll(list.map((e) => Map<String, dynamic>.from(e)).toList());
          if (products.isNotEmpty) {
            selectedProduct.value = products.first;
          }
        }
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart() {
    if (selectedProduct.value == null) {
      Get.snackbar('Input Error', 'Please select a product.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (quantity.value <= 0) {
      Get.snackbar('Input Error', 'Quantity must be at least 1.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Check if product already in cart, if so, merge quantities
    final existingIdx = cartItems.indexWhere((item) => item['product']['id'] == selectedProduct.value!['id']);
    if (existingIdx != -1) {
      final newQty = cartItems[existingIdx]['quantity'] + quantity.value;
      cartItems[existingIdx] = {
        'product': selectedProduct.value!,
        'quantity': newQty,
      };
    } else {
      cartItems.add({
        'product': selectedProduct.value!,
        'quantity': quantity.value,
      });
    }

    // Reset quantity input to 1
    quantity.value = 1;
    Get.snackbar('Success', 'Added to cart!', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
  }

  double get cartTotal {
    double total = 0.0;
    for (var item in cartItems) {
      final double price = double.tryParse(item['product']['price'].toString()) ?? 0.0;
      total += price * item['quantity'];
    }
    return total;
  }

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> submitCart() async {
    if (cartItems.isEmpty) {
      Get.snackbar('Cart Empty', 'Please add at least one product before submitting.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      // 1. Get GPS coordinates
      String latitude = '';
      String longitude = '';
      final position = await _determinePosition();
      if (position != null) {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      }

      // Record checkout total for success summary
      final double totalCheckoutAmount = cartTotal;
      final int totalCheckoutItems = cartItems.length;

      // 2. Submit each cart item as a record
      for (var item in cartItems) {
        final productMap = item['product'];
        final int qty = item['quantity'];
        final double price = double.tryParse(productMap['price'].toString()) ?? 0.0;
        final double itemTotal = price * qty;

        final winnerData = {
          'salesman': salesman.value,
          'product': productMap['name'],
          'customerName': 'Counter Customer',
          'mobileNumber': '0000000000',
          'prize': 'No Spin',
          'photoPath': '',
          'latitude': latitude,
          'longitude': longitude,
          'quantity': qty,
          'orderTotal': itemTotal,
          'discount_applied': 0.0,
          'net_amount': itemTotal,
          'spin_eligible': false,
        };

        // Try direct upload
        bool onlineSuccess = false;
        try {
          final formData = dio_pkg.FormData.fromMap({
            'salesman': winnerData['salesman'],
            'product': winnerData['product'],
            'customer_name': winnerData['customerName'],
            'mobile_number': winnerData['mobileNumber'],
            'prize': winnerData['prize'],
            'latitude': latitude,
            'longitude': longitude,
            'quantity': qty,
            'order_total': itemTotal,
            'discount_applied': 0.0,
            'net_amount': itemTotal,
            'spin_eligible': 0,
          });

          final response = await dio_pkg.Dio().post(
            '${ApiConfig.baseUrl}/submit.php',
            data: formData,
            options: dio_pkg.Options(
              sendTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );

          if (response.statusCode == 200 && response.data != null && response.data['status'] == 'success') {
            onlineSuccess = true;
          }
        } catch (_) {}

        // Add to local DB (with synced status)
        await LocalDbService.addWinner({
          'salesman': winnerData['salesman'],
          'product': winnerData['product'],
          'customerName': winnerData['customerName'],
          'mobileNumber': winnerData['mobileNumber'],
          'prize': winnerData['prize'],
          'photoPath': '',
          'latitude': latitude,
          'longitude': longitude,
          'quantity': qty,
          'order_total': itemTotal,
          'discount_applied': 0.0,
          'net_amount': itemTotal,
          'spin_eligible': 0,
          'synced': onlineSuccess ? 1 : 0,
        });
      }

      // Prepare cart list for invoice display before clearing cart
      final List<Map<String, dynamic>> invoiceItems = cartItems.map((item) {
        return {
          'name': item['product']['name'],
          'quantity': item['quantity'],
          'price': double.tryParse(item['product']['price'].toString()) ?? 0.0,
        };
      }).toList();

      // 3. Clear cart and show checkout success page
      cartItems.clear();
      
      Get.offNamed('/submit-success', arguments: {
        'salesman': salesman.value,
        'product': 'Multiple Products ($totalCheckoutItems)',
        'customerName': 'Counter Customer',
        'mobileNumber': '0000000000',
        'prize': 'Direct Sale Complete',
        'photoPath': '',
        'quantity': totalCheckoutItems,
        'orderTotal': totalCheckoutAmount,
        'net_amount': totalCheckoutAmount,
        'spin_eligible': false,
        'items': invoiceItems,
      });

    } catch (e) {
      Get.snackbar('Submission Error', 'Failed to submit sales entry: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }
}
