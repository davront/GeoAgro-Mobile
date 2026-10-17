import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  // Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      // Try to reach a reliable host with timeout
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      // If google.com fails, try a different approach
      try {
        final result = await InternetAddress.lookup('8.8.8.8')
            .timeout(Duration(seconds: 3));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e2) {
        // If both fail, assume we have connection if connectivity shows we do
        final connectivityResults = await Connectivity().checkConnectivity();
        return connectivityResults.isNotEmpty &&
            (connectivityResults.contains(ConnectivityResult.wifi) ||
                connectivityResults.contains(ConnectivityResult.mobile) ||
                connectivityResults.contains(ConnectivityResult.ethernet));
      }
    }
  }

  // Check if device is connected to WiFi
  static Future<bool> isConnectedToWifi() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.wifi);
  }

  // Check if device is connected to mobile data
  static Future<bool> isConnectedToMobile() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.mobile);
  }

  // Get connection type
  static Future<String> getConnectionType() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (connectivityResults.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (connectivityResults.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else if (connectivityResults.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else if (connectivityResults.contains(ConnectivityResult.other)) {
      return 'Other';
    } else {
      return 'None';
    }
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Check if URL is valid
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Extract domain from URL
  static String? extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check if phone number is valid (Uzbekistan format)
  static bool isValidPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('998')) {
      return cleanPhone.length == 12;
    }

    if (cleanPhone.startsWith('90')) {
      return cleanPhone.length == 9;
    }

    return false;
  }

  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('998')) {
      cleanPhone = cleanPhone.substring(3);
    }

    if (cleanPhone.length == 9) {
      return '+998 ${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5, 7)} ${cleanPhone.substring(7)}';
    }

    return phone;
  }

  /// Голые цифры номера без страны-кода — то, что бэк ожидает в
  /// phone_number (без +998, без форматирования). Принимает как
  /// "+998901234567", так и уже голые "901234567".
  static String stripCountryCode(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.startsWith('998') ? digitsOnly.substring(3) : digitsOnly;
  }
}
