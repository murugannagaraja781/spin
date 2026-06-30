import 'package:get/get.dart';
import 'app_routes.dart';

import '../../modules/login/login_binding.dart';
import '../../modules/login/login_view.dart';
import '../../modules/product_selection/product_selection_binding.dart';
import '../../modules/product_selection/product_selection_view.dart';
import '../../modules/salesman_selection/salesman_selection_binding.dart';
import '../../modules/salesman_selection/salesman_selection_view.dart';
import '../../modules/spin_wheel/spin_wheel_binding.dart';
import '../../modules/spin_wheel/spin_wheel_view.dart';
import '../../modules/winner_details/winner_details_binding.dart';
import '../../modules/winner_details/winner_details_view.dart';
import '../../modules/photo_capture/photo_capture_binding.dart';
import '../../modules/photo_capture/photo_capture_view.dart';
import '../../modules/submit_success/submit_success_binding.dart';
import '../../modules/submit_success/submit_success_view.dart';
import '../../modules/admin_dashboard/admin_dashboard_binding.dart';
import '../../modules/admin_dashboard/admin_dashboard_view.dart';
import '../../modules/customer_selection/customer_selection_binding.dart';
import '../../modules/customer_selection/customer_selection_view.dart';
import '../../modules/mobile_validation/mobile_validation_binding.dart';
import '../../modules/mobile_validation/mobile_validation_view.dart';
import '../../modules/direct_sales/direct_sales_binding.dart';
import '../../modules/direct_sales/direct_sales_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.productSelection,
      page: () => const ProductSelectionView(),
      binding: ProductSelectionBinding(),
    ),
    GetPage(
      name: AppRoutes.salesmanSelection,
      page: () => const SalesmanSelectionView(),
      binding: SalesmanSelectionBinding(),
    ),
    GetPage(
      name: AppRoutes.spinWheel,
      page: () => const SpinWheelView(),
      binding: SpinWheelBinding(),
    ),
    GetPage(
      name: AppRoutes.winnerDetails,
      page: () => const WinnerDetailsView(),
      binding: WinnerDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.photoCapture,
      page: () => const PhotoCaptureView(),
      binding: PhotoCaptureBinding(),
    ),
    GetPage(
      name: AppRoutes.submitSuccess,
      page: () => const SubmitSuccessView(),
      binding: SubmitSuccessBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.customerSelection,
      page: () => const CustomerSelectionView(),
      binding: CustomerSelectionBinding(),
    ),
    GetPage(
      name: AppRoutes.mobileValidation,
      page: () => const MobileValidationView(),
      binding: MobileValidationBinding(),
    ),
    GetPage(
      name: AppRoutes.directSales,
      page: () => const DirectSalesView(),
      binding: DirectSalesBinding(),
    ),
  ];
}
