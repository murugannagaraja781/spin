import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const bool useLocalServer = false;
  static const String liveBaseUrl = 'https://www.minikuttybeedi.com/api';
  static const String localAndroidEmulatorBaseUrl = 'http://10.0.2.2/spin/api';
  // Real device on same Wi-Fi network as your XAMPP machine (192.168.1.39)
  static const String localAndroidDeviceBaseUrl = 'http://192.168.1.39/spin/api';
  static const String localWebBaseUrl = 'http://localhost/spin/api';

  static String get baseUrl {
    if (useLocalServer) {
      if (kIsWeb) {
        return localWebBaseUrl;
      }
      if (Platform.isAndroid) {
        // Use emulator IP when running on emulator, LAN IP for real device
        return localAndroidDeviceBaseUrl;
      }
      if (Platform.isIOS) {
        return localAndroidDeviceBaseUrl;
      }
    }
    return liveBaseUrl;
  }
}

