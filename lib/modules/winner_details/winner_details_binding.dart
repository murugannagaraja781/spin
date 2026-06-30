import 'package:get/get.dart';
import 'winner_details_controller.dart';

class WinnerDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WinnerDetailsController>(() => WinnerDetailsController());
  }
}
