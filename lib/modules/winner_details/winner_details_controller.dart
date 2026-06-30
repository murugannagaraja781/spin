import 'package:get/get.dart';

class WinnerDetailsController extends GetxController {
  final customerName = ''.obs;
  final mobileNumber = ''.obs;

  late String prize;
  late String product;
  late String salesman;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    prize = args['prize'] ?? '';
    product = args['product'] ?? '';
    salesman = args['salesman'] ?? '';
  }

  void continueToPhoto() {
    if (customerName.value.isEmpty || mobileNumber.value.length < 10) {
      Get.snackbar('Validation Error', 'Please enter valid name and mobile number', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    Get.toNamed('/photo-capture', arguments: {
      'prize': prize,
      'product': product,
      'salesman': salesman,
      'customerName': customerName.value,
      'mobileNumber': mobileNumber.value,
    });
  }
}
