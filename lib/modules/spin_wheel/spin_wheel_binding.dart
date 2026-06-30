import 'package:get/get.dart';
import 'spin_wheel_controller.dart';

class SpinWheelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpinWheelController>(() => SpinWheelController());
  }
}
