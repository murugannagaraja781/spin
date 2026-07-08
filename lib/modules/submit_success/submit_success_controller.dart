import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../core/constants/api_config.dart';
import '../../data/local_db_service.dart';

class SubmitSuccessController extends GetxController {
  final isSubmitting = true.obs;
  final isSuccess = false.obs;
  
  late Map<String, dynamic> data;

  @override
  void onInit() {
    super.onInit();
    data = Get.arguments ?? {};
    _submitDataOffline();
  }

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<void> _submitDataOffline() async {
    try {
      final bool alreadySubmitted = data['already_submitted'] == true;
      if (alreadySubmitted) {
        isSuccess.value = true;
        isSubmitting.value = false;
        return;
      }

      final mobileNumber = data['mobileNumber']?.toString() ?? '';
      final product = data['product']?.toString() ?? '';
      final bool isSpinEligible = (data['spin_eligible'] == true);
      
      // Local Validation for spins
      if (isSpinEligible) {
        final isUsedToday = await LocalDbService.isMobileUsedToday(mobileNumber, product);
        if (isUsedToday) {
          Get.snackbar(
            'Already Spun Today', 
            'This mobile number has already completed a spin for this product today!', 
            snackPosition: SnackPosition.BOTTOM, 
            duration: const Duration(seconds: 4)
          );
          isSuccess.value = false;
          isSubmitting.value = false;
          return;
        }
      }

      // Capture GPS location
      String latitude = '';
      String longitude = '';
      final position = await _determinePosition();
      if (position != null) {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      }

      // Attempt to upload to server immediately
      bool onlineSuccess = false;
      try {
        final formDataMap = {
          'salesman': data['salesman'] ?? '',
          'product': data['product'] ?? '',
          'customer_name': data['customerName'] ?? '',
          'mobile_number': data['mobileNumber'] ?? '',
          'prize': data['prize'] ?? '',
          'latitude': latitude,
          'longitude': longitude,
          'quantity': data['quantity'] ?? 1,
          'order_total': data['orderTotal'] ?? 0.00,
          'discount_applied': data['discount_applied'] ?? 0.00,
          'net_amount': data['net_amount'] ?? 0.00,
          'spin_eligible': (data['spin_eligible'] == true) ? 1 : 0,
        };
        final formData = dio_pkg.FormData.fromMap(formDataMap);

        final photoPath = data['photoPath']?.toString() ?? '';
        if (photoPath.isNotEmpty) {
          formData.files.add(
            MapEntry('photo', await dio_pkg.MultipartFile.fromFile(photoPath, filename: 'photo.jpg'))
          );
        }

        final response = await dio_pkg.Dio().post(
          '${ApiConfig.baseUrl}/submit.php',
          data: formData,
          options: dio_pkg.Options(
            sendTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          if (response.data['status'] == 'success') {
            onlineSuccess = true;
          }
        }
      } catch (e) {
        print('Direct online sync failed: $e');
      }

      // Save Locally (with synced flag)
      await LocalDbService.addWinner({
        'salesman': data['salesman'],
        'product': data['product'],
        'customerName': data['customerName'],
        'mobileNumber': data['mobileNumber'],
        'prize': data['prize'],
        'photoPath': data['photoPath'], // Saves local temp path
        'latitude': latitude,
        'longitude': longitude,
        'quantity': data['quantity'] ?? 1,
        'order_total': data['orderTotal'] ?? 0.00,
        'discount_applied': data['discount_applied'] ?? 0.00,
        'net_amount': data['net_amount'] ?? 0.00,
        'spin_eligible': (data['spin_eligible'] == true) ? 1 : 0,
        'synced': onlineSuccess ? 1 : 0,
      });

      // Show Success
      await Future.delayed(const Duration(seconds: 1)); // Simulate slight network delay for UI effect
      isSuccess.value = true;
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to save data locally.', snackPosition: SnackPosition.BOTTOM);
      isSuccess.value = false;
      print('Local DB Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void backToHome() {
    Get.offAllNamed('/salesman-selection');
  }
}
