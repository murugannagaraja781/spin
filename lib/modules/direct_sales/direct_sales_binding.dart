import 'package:get/get.dart';
import 'direct_sales_controller.dart';

class DirectSalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectSalesController>(() => DirectSalesController());
  }
}
