import 'package:get/get.dart';
import 'mobile_validation_controller.dart';

class MobileValidationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MobileValidationController>(() => MobileValidationController());
  }
}
