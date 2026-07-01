import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/api_config.dart';
import '../../data/local_db_service.dart';
import '../../core/controllers/branding_controller.dart';

class AdminDashboardController extends GetxController {
  final String _baseUrl = ApiConfig.baseUrl;

  // Local sync properties
  final winners = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isServerOnline = false.obs;
  final isSyncing = false.obs;
  int get unsyncedCount => winners.where((w) => w['synced'] != 1).length;

  // Server managed properties
  final serverWinners = <Map<String, dynamic>>[].obs;
  final serverProducts = <Map<String, dynamic>>[].obs;
  final serverSalesmen = <Map<String, dynamic>>[].obs;
  final serverSpins = <Map<String, dynamic>>[].obs;
  
  final isServerLoading = false.obs;

  // Overview metrics
  final serverTotalSales = 0.0.obs;
  final serverTotalSpins = 0.obs;
  final serverTodaySales = 0.0.obs;
  final serverDirectSalesCount = 0.obs;
  final serverDirectSalesAmount = 0.0.obs;

  // Daily Chart coordinates
  final chartDatesList = <String>[].obs;
  final chartSalesList = <double>[].obs;
  final chartSpinsList = <int>[].obs;

  // History Filter state parameters
  final selectedSalesmanFilter = ''.obs;
  final selectedProductFilter = ''.obs;

  // Selection state for bulk delete
  final selectedWinnerIds = <int>[].obs;

  List<Map<String, dynamic>> get filteredWinners {
    return serverWinners.where((w) {
      final matchesSalesman = selectedSalesmanFilter.value.isEmpty ||
          w['salesman_name']?.toString().toLowerCase() == selectedSalesmanFilter.value.toLowerCase();
      final matchesProduct = selectedProductFilter.value.isEmpty ||
          w['product_name']?.toString().toLowerCase() == selectedProductFilter.value.toLowerCase();
      return matchesSalesman && matchesProduct;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredSpinWinners {
    return serverWinners.where((w) {
      final isSpin = int.tryParse(w['spin_eligible']?.toString() ?? '') ?? 1;
      if (isSpin != 1) return false;
      final matchesSalesman = selectedSalesmanFilter.value.isEmpty ||
          w['salesman_name']?.toString().toLowerCase() == selectedSalesmanFilter.value.toLowerCase();
      final matchesProduct = selectedProductFilter.value.isEmpty ||
          w['product_name']?.toString().toLowerCase() == selectedProductFilter.value.toLowerCase();
      return matchesSalesman && matchesProduct;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredDirectWinners {
    return serverWinners.where((w) {
      final isSpin = int.tryParse(w['spin_eligible']?.toString() ?? '') ?? 1;
      if (isSpin == 1) return false;
      final matchesSalesman = selectedSalesmanFilter.value.isEmpty ||
          w['salesman_name']?.toString().toLowerCase() == selectedSalesmanFilter.value.toLowerCase();
      final matchesProduct = selectedProductFilter.value.isEmpty ||
          w['product_name']?.toString().toLowerCase() == selectedProductFilter.value.toLowerCase();
      return matchesSalesman && matchesProduct;
    }).toList();
  }

  Timer? _healthTimer;

  @override
  void onInit() {
    super.onInit();
    loadLocalData();
    fetchServerData();
    _startHealthCheck();
  }

  @override
  void onClose() {
    _healthTimer?.cancel();
    super.onClose();
  }

  void _startHealthCheck() {
    _checkServer();
    _healthTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkServer();
    });
  }

  Future<void> _checkServer() async {
    try {
      final response = await dio.Dio().get('$_baseUrl/health.php', 
        options: dio.Options(sendTimeout: const Duration(seconds: 3), receiveTimeout: const Duration(seconds: 3)));
      isServerOnline.value = response.statusCode == 200;
    } catch (_) {
      isServerOnline.value = false;
    }
  }

  Future<void> loadLocalData() async {
    isLoading.value = true;
    final data = await LocalDbService.getWinners();
    data.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });
    winners.assignAll(data);
    isLoading.value = false;
  }

  // Fetch all live server data
  Future<void> fetchServerData() async {
    isServerLoading.value = true;
    try {
      // 1. Fetch live Winners History
      final winnersRes = await dio.Dio().get('$_baseUrl/get_winners.php');
      if (winnersRes.statusCode == 200 && winnersRes.data != null) {
        if (winnersRes.data['status'] == 'success') {
          final List list = winnersRes.data['data'] ?? [];
          serverWinners.assignAll(list.map((e) => Map<String, dynamic>.from(e)).toList());
          _calculateMetrics();
        }
      }

      // 2. Fetch live Products
      final productsRes = await dio.Dio().get('$_baseUrl/get_products.php');
      if (productsRes.statusCode == 200 && productsRes.data != null) {
        if (productsRes.data['status'] == 'success') {
          final List list = productsRes.data['data'] ?? [];
          serverProducts.assignAll(list.map((e) => Map<String, dynamic>.from(e)).toList());
        }
      }

      // 3. Fetch live Salesmen
      final salesmenRes = await dio.Dio().get('$_baseUrl/get_salesmen.php');
      if (salesmenRes.statusCode == 200 && salesmenRes.data != null) {
        final List list = salesmenRes.data['salesmen'] ?? salesmenRes.data['data'] ?? [];
        final List<Map<String, dynamic>> mapped = [];
        for (var e in list) {
          if (e is Map) {
            mapped.add({
              'id': int.tryParse(e['id'].toString()) ?? 0,
              'name': e['name']?.toString() ?? '',
            });
          } else if (e != null) {
            mapped.add({
              'id': 0,
              'name': e.toString(),
            });
          }
        }
        // Assign artificial IDs only for fallback items lacking DB IDs
        for (int i = 0; i < mapped.length; i++) {
          if (mapped[i]['id'] == 0) {
            mapped[i]['id'] = i + 1;
          }
        }
        serverSalesmen.assignAll(mapped);
      }

      // 4. Fetch live Spin Wheel values
      final spinsRes = await dio.Dio().get('$_baseUrl/get_spins.php');
      if (spinsRes.statusCode == 200 && spinsRes.data != null) {
        if (spinsRes.data['status'] == 'success') {
          final List list = spinsRes.data['data'] ?? [];
          serverSpins.assignAll(list.map((e) => Map<String, dynamic>.from(e)).toList());
        }
      }
    } catch (e) {
      print('Error fetching server data: $e');
    } finally {
      isServerLoading.value = false;
    }
  }

  // CRUD Products
  Future<void> addProduct(String name, double price) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/add_product.php',
        data: {'name': name, 'price': price},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Product added successfully!', snackPosition: SnackPosition.BOTTOM);
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to add product', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  Future<void> deleteProduct(int id) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/delete_product.php',
        data: {'id': id},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Product deleted successfully!', snackPosition: SnackPosition.BOTTOM);
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to delete product', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  Future<void> deleteWinner(int id) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/delete_winner.php',
        data: {'id': id},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'History record deleted successfully!', snackPosition: SnackPosition.BOTTOM);
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to delete record', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  Future<void> editProduct(int id, String name, double price) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/edit_product.php',
        data: {'id': id, 'name': name, 'price': price},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Product updated successfully!', snackPosition: SnackPosition.BOTTOM);
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to update product', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  Future<void> deleteWinnersBulk(List<int> ids) async {
    if (ids.isEmpty) return;
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/delete_winner.php',
        data: {'ids': ids},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Selected records deleted successfully!', snackPosition: SnackPosition.BOTTOM);
        selectedWinnerIds.clear(); // Clear selections
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to delete selected records', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  // CRUD Salesmen
  Future<void> addSalesman(String name) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/add_salesman.php',
        data: {'name': name},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Salesman added successfully!', snackPosition: SnackPosition.BOTTOM);
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to add salesman', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  Future<void> deleteSalesman(int id) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/delete_salesman.php',
        data: {'id': id},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Salesman deleted successfully!', snackPosition: SnackPosition.BOTTOM);
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to delete salesman', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  // CRUD Spin values
  Future<void> addSpin(String prizeName) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/add_spin.php',
        data: {'prize_name': prizeName},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Spin value added successfully!', snackPosition: SnackPosition.BOTTOM);
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to add spin value', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  Future<void> deleteSpin(int id) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/delete_spin.php',
        data: {'id': id},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Spin value deleted successfully!', snackPosition: SnackPosition.BOTTOM);
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to delete spin value', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  // Update Branding
  Future<void> updateBrandingSettings(
    String appTitle, 
    String appSubtitle, 
    String premiumTitle,
    String superadminPassword,
    String salesmanPassword,
  ) async {
    isServerLoading.value = true;
    try {
      final response = await dio.Dio().post(
        '$_baseUrl/update_settings.php',
        data: {
          'app_title': appTitle,
          'app_subtitle': appSubtitle,
          'premium_title': premiumTitle,
          'superadmin_password': superadminPassword,
          'salesman_password': salesmanPassword,
        },
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Branding & password settings updated!', snackPosition: SnackPosition.BOTTOM);
        
        // Update local branding controller immediately
        final branding = Get.find<BrandingController>();
        branding.appTitle.value = appTitle;
        branding.appSubtitle.value = appSubtitle;
        branding.premiumTitle.value = premiumTitle;
        branding.superadminPassword.value = superadminPassword;
        branding.salesmanPassword.value = salesmanPassword;

        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to update branding', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection error: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  Future<void> uploadLogoImage(String filePath) async {
    isServerLoading.value = true;
    try {
      final fileName = filePath.split('/').last;
      final formData = dio.FormData.fromMap({
        'logo': await dio.MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await dio.Dio().post(
        '$_baseUrl/upload_logo.php',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar('Success', 'Logo uploaded successfully!', snackPosition: SnackPosition.BOTTOM);
        
        final String newLogoPath = response.data['logo_path'] ?? '';
        final branding = Get.find<BrandingController>();
        branding.logoUrl.value = newLogoPath.isNotEmpty 
            ? (newLogoPath.startsWith('http') ? newLogoPath : '${ApiConfig.baseUrl}/../$newLogoPath')
            : '';
            
        await fetchServerData();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Failed to upload logo', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'File upload failed: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isServerLoading.value = false;
    }
  }

  // Sync Offline local DB entries
  Future<void> syncDataToServer() async {
    if (!isServerOnline.value || winners.isEmpty) return;

    isSyncing.value = true;
    int successCount = 0;
    
    try {
      for (var winner in winners) {
        if (winner['synced'] == 1) {
          successCount++;
          continue;
        }

        final formData = dio.FormData.fromMap({
          'salesman': winner['salesman'],
          'product': winner['product'],
          'customer_name': winner['customerName'],
          'mobile_number': winner['mobileNumber'],
          'prize': winner['prize'],
          'latitude': winner['latitude'] ?? '',
          'longitude': winner['longitude'] ?? '',
          'quantity': winner['quantity'] ?? 1,
          'order_total': winner['order_total'] ?? 0.00,
          'discount_applied': winner['discount_applied'] ?? 0.00,
          'net_amount': winner['net_amount'] ?? 0.00,
          'spin_eligible': winner['spin_eligible'] ?? 1,
        });

        if (winner['photoPath'] != null && winner['photoPath'].toString().isNotEmpty) {
          formData.files.add(
            MapEntry('photo', await dio.MultipartFile.fromFile(winner['photoPath'], filename: 'photo.jpg'))
          );
        }

        final response = await dio.Dio().post('$_baseUrl/submit.php', data: formData);
        
        if (response.statusCode == 200) {
           winner['synced'] = 1;
           successCount++;
        }
      }

      if (successCount == winners.length) {
        await LocalDbService.clearAll();
        winners.clear();
        Get.snackbar('Sync Successful', 'All data securely uploaded to the live server!', 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: const Color(0xFF0D1B2A), 
          colorText: const Color(0xFFFFD700));
      } else {
        await LocalDbService.saveWinners(winners);
        winners.refresh();
        Get.snackbar('Partial Sync', 'Some records failed to upload.', snackPosition: SnackPosition.BOTTOM);
      }
      
      await fetchServerData(); // Reload server view
    } catch (e) {
      Get.snackbar('Sync Error', 'Network connection lost during sync.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSyncing.value = false;
    }
  }

  void clearData() async {
    await LocalDbService.clearAll();
    winners.clear();
    Get.snackbar('Cleared', 'All offline demo data deleted.', snackPosition: SnackPosition.BOTTOM);
  }

  void _calculateMetrics() {
    double totalSales = 0.0;
    int totalSpins = 0;
    double todaySales = 0.0;
    int directCount = 0;
    double directAmount = 0.0;

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Map to group sales & spins by date
    final Map<String, double> salesByDate = {};
    final Map<String, int> spinsByDate = {};

    for (var w in serverWinners) {
      final double netAmount = double.tryParse(w['net_amount']?.toString() ?? '') ?? 0.0;
      final int spinEligible = int.tryParse(w['spin_eligible']?.toString() ?? '') ?? 1;
      final String rawDate = w['created_at'] ?? '';
      
      totalSales += netAmount;
      if (spinEligible == 1) {
        totalSpins++;
      } else {
        directCount++;
        directAmount += netAmount;
      }

      if (rawDate.startsWith(todayStr)) {
        todaySales += netAmount;
      }

      // Extract yyyy-MM-dd date
      if (rawDate.length >= 10) {
        final dateKey = rawDate.substring(0, 10);
        salesByDate[dateKey] = (salesByDate[dateKey] ?? 0.0) + netAmount;
        spinsByDate[dateKey] = (spinsByDate[dateKey] ?? 0) + (spinEligible == 1 ? 1 : 0);
      }
    }

    serverTotalSales.value = totalSales;
    serverTotalSpins.value = totalSpins;
    serverTodaySales.value = todaySales;
    serverDirectSalesCount.value = directCount;
    serverDirectSalesAmount.value = directAmount;

    // Get sorted last 10 active days for chart
    final sortedDates = salesByDate.keys.toList()..sort();
    final displayDates = sortedDates.length > 10 
        ? sortedDates.sublist(sortedDates.length - 10) 
        : sortedDates;

    final List<String> formattedDates = [];
    final List<double> salesValues = [];
    final List<int> spinsValues = [];

    for (var d in displayDates) {
      try {
        final parsed = DateTime.parse(d);
        formattedDates.add('${parsed.day}/${parsed.month}');
      } catch (_) {
        formattedDates.add(d);
      }
      salesValues.add(salesByDate[d] ?? 0.0);
      spinsValues.add(spinsByDate[d] ?? 0);
    }

    // Default placeholder if empty
    if (formattedDates.isEmpty) {
      formattedDates.add('Today');
      salesValues.add(0.0);
      spinsValues.add(0);
    }

    chartDatesList.assignAll(formattedDates);
    chartSalesList.assignAll(salesValues);
    chartSpinsList.assignAll(spinsValues);
  }

  Future<void> exportWinnersToCSV({String filterType = 'all'}) async {
    List<dynamic> listToExport = [];
    String reportTitle = 'All Sales History Report';
    String fileName = 'all_sales_report.csv';

    if (filterType == 'spin') {
      listToExport = filteredWinners.where((w) => w['spin_eligible'] == 1).toList();
      reportTitle = 'Spin Sales History Report';
      fileName = 'spin_sales_report.csv';
    } else if (filterType == 'direct') {
      listToExport = filteredWinners.where((w) => w['spin_eligible'] == 0).toList();
      reportTitle = 'Direct Sales History Report';
      fileName = 'direct_sales_report.csv';
    } else {
      listToExport = filteredWinners;
    }

    if (listToExport.isEmpty) {
      Get.snackbar('No Data', 'No records found matching this category to export.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln('ID,Date,Salesman,Customer Name,Mobile,Product,Quantity,Order Total,Spin Eligible,Prize Won,Net Amount,Latitude,Longitude');

    for (var w in listToExport) {
      csvBuffer.writeln(
        '${w['id'] ?? ""},'
        '${w['created_at'] ?? ""},'
        '"${w['salesman_name']?.toString().replaceAll('"', '""') ?? ""}",'
        '"${w['customer_name']?.toString().replaceAll('"', '""') ?? ""}",'
        '${w['mobile_number'] ?? ""},'
        '"${w['product_name']?.toString().replaceAll('"', '""') ?? ""}",'
        '${w['quantity'] ?? 1},'
        '${w['order_total'] ?? 0.0},'
        '${w['spin_eligible'] ?? 1},'
        '"${w['prize_won']?.toString().replaceAll('"', '""') ?? ""}",'
        '${w['net_amount'] ?? 0.0},'
        '${w['latitude'] ?? ""},'
        '${w['longitude'] ?? ""}'
      );
    }

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csvBuffer.toString());
      
      await Share.shareXFiles([XFile(file.path)], text: '$reportTitle (CSV)');
    } catch (e) {
      Get.snackbar('Export Error', 'Failed to generate CSV: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void logout() {
    Get.offAllNamed('/login');
  }
}
