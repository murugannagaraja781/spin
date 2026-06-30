import 'package:get/get.dart';
import 'customer_selection_controller.dart';

class CustomerSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerSelectionController>(() => CustomerSelectionController());
  }
}
