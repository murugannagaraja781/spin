import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

class BrandingController extends GetxController {
  final appTitle = 'மினிக்குட்டி பீடி'.obs;
  final appSubtitle = 'മിനിക്കുട്ടി ബീഡി'.obs;
  final premiumTitle = '💎 PREMIUM SPIN & WIN 💎'.obs;
  final logoUrl = ''.obs;
  final superadminPassword = 'superadmin123'.obs;
  final salesmanPassword = 'admin123'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCachedSettings();
    fetchRemoteSettings();
  }

  Future<void> loadCachedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      appTitle.value = prefs.getString('brand_app_title') ?? 'மினிக்குட்டி பீடி';
      appSubtitle.value = prefs.getString('brand_app_subtitle') ?? 'മിനിക്കുട്ടി ബീഡി';
      premiumTitle.value = prefs.getString('brand_premium_title') ?? '💎 PREMIUM SPIN & WIN 💎';
      logoUrl.value = prefs.getString('brand_logo_url') ?? '';
      superadminPassword.value = prefs.getString('brand_superadmin_password') ?? 'superadmin123';
      salesmanPassword.value = prefs.getString('brand_salesman_password') ?? 'admin123';
    } catch (e) {
      print('Error loading cached branding settings: $e');
    }
  }

  Future<void> fetchRemoteSettings() async {
    try {
      final response = await dio_pkg.Dio().get(
        '${ApiConfig.baseUrl}/get_settings.php',
        options: dio_pkg.Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final String title = response.data['app_title'] ?? 'மினிக்குட்டி பீடி';
          final String subtitle = response.data['app_subtitle'] ?? 'മിനിക്കുട്ടി ബീഡി';
          final String premium = response.data['premium_title'] ?? '💎 PREMIUM SPIN & WIN 💎';
          final String logoPath = response.data['logo_path'] ?? '';
          final String superPass = response.data['superadmin_password'] ?? 'superadmin123';
          final String salesPass = response.data['salesman_password'] ?? 'admin123';

          appTitle.value = title;
          appSubtitle.value = subtitle;
          premiumTitle.value = premium;
          logoUrl.value = logoPath.isNotEmpty 
              ? (logoPath.startsWith('http') ? logoPath : '${ApiConfig.baseUrl}/../$logoPath')
              : '';
          superadminPassword.value = superPass;
          salesmanPassword.value = salesPass;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('brand_app_title', appTitle.value);
          await prefs.setString('brand_app_subtitle', appSubtitle.value);
          await prefs.setString('brand_premium_title', premiumTitle.value);
          await prefs.setString('brand_logo_url', logoUrl.value);
          await prefs.setString('brand_superadmin_password', superadminPassword.value);
          await prefs.setString('brand_salesman_password', salesmanPassword.value);
        }
      }
    } catch (e) {
      print('Error loading remote branding: $e');
    }
  }
}
