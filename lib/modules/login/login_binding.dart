import 'package:get/get.dart';
import 'login_controller.dart';
import '../../core/controllers/branding_controller.dart';
import '../../core/services/sync_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BrandingController>(BrandingController(), permanent: true);
    Get.put<SyncService>(SyncService(), permanent: true);
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
