import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_config.dart';
import '../../core/controllers/branding_controller.dart';

class LoginController extends GetxController {
  final password = ''.obs;
  final isLoading = false.obs;
  final String _baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    checkSubscription();
  }

  void checkSubscription() {
    final now = DateTime.now();
    final expiryDate = DateTime(2028, 6, 26);
    final warningDate = DateTime(2028, 6, 23);

    // Expired state
    if (now.isAfter(expiryDate) || now.isAtSameMomentAs(expiryDate)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showExpiredDialog();
      });
    }
    // 3-day Warning state
    else if (now.isAfter(warningDate) || now.isAtSameMomentAs(warningDate)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showWarningDialog();
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (_) {}
  }

  void _showWarningDialog() {
    Get.dialog(
      PopScope(
        canPop: true,
        child: AlertDialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          ),
          title: const Text(
            'Subscription Expiring Soon',
            style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Your subscription will expire on 26 Jun 2028.\n\n'
            'Only 3 days remaining. Please contact the developer to renew your subscription and avoid service interruption.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Later', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _makePhoneCall('6382379565');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
              ),
              child: const Text('Contact Developer'),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showExpiredDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text(
                'Renewal Required',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Your plan expires on 26 Jun 2028.\n'
            'Please contact the developer for renewal assistance.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                exit(0);
              },
              child: const Text('Close', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () {
                _makePhoneCall('6382379565');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Contact Developer call 6382379565'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> login() async {
    final pass = password.value.trim();
    
    if (pass.isEmpty) {
      Get.snackbar('Error', 'Please enter password', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final response = await dio_pkg.Dio().post(
        '$_baseUrl/login.php',
        data: dio_pkg.FormData.fromMap({'password': pass}),
        options: dio_pkg.Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        var responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            Get.snackbar('Error', 'Invalid server response format', snackPosition: SnackPosition.BOTTOM);
            return;
          }
        }

        if (responseData['status'] == 'success') {
          final role = responseData['role'] ?? '';
          
          if (role == 'admin') {
            Get.offNamed('/admin-dashboard');
          } else if (role == 'user') {
            Get.offNamed('/salesman-selection');
          }
        } else {
          Get.snackbar('Error', responseData['message'] ?? 'Login failed', 
            snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      // Offline fallback authentication
      final branding = Get.find<BrandingController>();
      if (pass == branding.superadminPassword.value) {
        Get.offNamed('/admin-dashboard');
        Get.snackbar('Offline Mode', 'Logged in as Super Admin (Offline cache)', snackPosition: SnackPosition.BOTTOM);
      } else if (pass == branding.salesmanPassword.value) {
        Get.offNamed('/salesman-selection');
        Get.snackbar('Offline Mode', 'Logged in as Salesman (Offline cache)', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Login failed: Connection lost & invalid offline password.', snackPosition: SnackPosition.BOTTOM);
      }
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
