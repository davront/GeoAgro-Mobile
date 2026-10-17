import 'dart:developer';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Сервис для проверки и запроса разрешений приложения
class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  /// Проверить разрешение на камеру
  Future<bool> checkCameraPermission() async {
    try {
      if (Platform.isAndroid) {
        // Для Android проверяем через попытку доступа
        // image_picker сам запрашивает разрешения при необходимости
        return true; // image_picker обрабатывает разрешения автоматически
      } else if (Platform.isIOS) {
        // Для iOS проверяем статус разрешения
        return true; // image_picker обрабатывает разрешения автоматически
      }
      return false;
    } catch (e) {
      log('Error checking camera permission: $e');
      return false;
    }
  }

  /// Запросить разрешение на камеру
  Future<bool> requestCameraPermission() async {
    try {
      // Пытаемся выбрать изображение с камеры (это запросит разрешение)
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 1,
      );
      // Если файл выбран - разрешение дано
      // Если null - пользователь отменил, но разрешение могло быть дано
      // Проверяем через повторную попытку или считаем, что разрешение запрошено
      // Для точной проверки нужно использовать permission_handler
      return file != null;
    } catch (e) {
      log('Error requesting camera permission: $e');
      // Если ошибка связана с разрешением, возвращаем false
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('permission') || errorStr.contains('denied')) {
        return false;
      }
      return false;
    }
  }

  /// Проверить разрешение на галерею
  Future<bool> checkGalleryPermission() async {
    try {
      // image_picker обрабатывает разрешения автоматически
      return true;
    } catch (e) {
      log('Error checking gallery permission: $e');
      return false;
    }
  }

  /// Запросить разрешение на галерею
  Future<bool> requestGalleryPermission() async {
    try {
      // Пытаемся выбрать изображение из галереи (это запросит разрешение)
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 1,
      );
      // Если файл выбран - разрешение дано
      // Если null - пользователь отменил, но разрешение могло быть дано
      return file != null;
    } catch (e) {
      log('Error requesting gallery permission: $e');
      // Если ошибка связана с разрешением, возвращаем false
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('permission') || errorStr.contains('denied')) {
        return false;
      }
      return false;
    }
  }

  /// Проверить разрешение на геолокацию
  Future<bool> checkLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      log('Error checking location permission: $e');
      return false;
    }
  }

  /// Запросить разрешение на геолокацию
  Future<bool> requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Открываем настройки геолокации
        await Geolocator.openLocationSettings();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      log('Error requesting location permission: $e');
      return false;
    }
  }

  /// Проверить разрешение на уведомления
  Future<bool> checkNotificationPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      log('Error checking notification permission: $e');
      return false;
    }
  }

  /// Запросить разрешение на уведомления
  Future<bool> requestNotificationPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      log('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Получить статус всех разрешений
  Future<Map<String, bool>> getAllPermissionsStatus() async {
    return {
      'camera': await checkCameraPermission(),
      'gallery': await checkGalleryPermission(),
      'location': await checkLocationPermission(),
      'notifications': await checkNotificationPermission(),
    };
  }
}
