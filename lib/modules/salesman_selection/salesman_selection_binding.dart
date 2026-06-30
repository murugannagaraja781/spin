import 'package:get/get.dart';
import 'salesman_selection_controller.dart';

class SalesmanSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalesmanSelectionController>(() => SalesmanSelectionController());
  }
}
