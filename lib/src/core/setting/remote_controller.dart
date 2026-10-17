import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'setup.dart';
import '../storage/app_storage.dart';

// class RemoteController extends ChangeNotifier {
//   bool _isBlocked;
//   bool get isBlocked => _isBlocked;

//   final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

//   RemoteController() : _isBlocked = isBloc {
//     log("RemoteController initialized");
//     _initializeRemoteConfig();
//   }

//   Future<void> _initializeRemoteConfig() async {
//     try {
//       await _remoteConfig.setConfigSettings(RemoteConfigSettings(
//         fetchTimeout: const Duration(seconds: 15), // Serverga ulanish timeout
//         minimumFetchInterval: const Duration(seconds: 5), // Yangilanish uchun interval
//       ));

//       // Set default values for Remote Config
//       await _remoteConfig.setDefaults({'isBlocked': isBloc});
//       log("Remote Config defaults set");

//       // Fetch and activate values
//       await fetchAndActivate();

//       // Listen for Remote Config updates
//       _remoteConfig.onConfigUpdated.listen((_) async {
//         log("Remote Config updated");
//         await fetchAndActivate();
//       });
//     } catch (e) {
//       log("Error initializing Remote Config: $e");
//     }
//   }

//   Future<void> fetchAndActivate() async {
//     try {
//       bool updated = await _remoteConfig.fetchAndActivate();
//       log("Remote Config activated: $updated");

//       // Update local state
//       _isBlocked = _remoteConfig.getBool('isBlocked');
//       await AppStorage.$writeBool(key: StorageKey.isBlocked, value: _isBlocked);
//       log("IsBlocked updated: $_isBlocked");

//       notifyListeners();
//     } catch (e) {
//       log("Error fetching Remote Config: $e");
//     }
//   }
// }

/// [Chat Version]
class RemoteController extends ChangeNotifier {
  bool _isBlocked;
  bool get isBlocked => _isBlocked;

  String _latestVersion = '';
  String get latestVersion => _latestVersion;

  String _apkDownloadUrl = '';
  String get apkDownloadUrl => _apkDownloadUrl;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  RemoteController() : _isBlocked = isBloc {
    initialize();
  }

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10), // Уменьшили timeout
        minimumFetchInterval: const Duration(minutes: 5), // Увеличили интервал
      ));

      await _remoteConfig.setDefaults({
        'isBlocked': isBloc,
        'latest_app_version': '',
        'apk_download_url': '',
      });
      log("Remote Config defaults set");

      // Неблокирующий вызов fetchAndActivate
      fetchAndActivate().catchError((e) {
        log("Non-blocking Remote Config fetch failed: $e");
        // Не показываем ошибку пользователю
      });

      // Dinamik o'zgarishlarni kuzatish
      _remoteConfig.onConfigUpdated.listen((_) async {
        log("Remote Config updated");
        await fetchAndActivate();
      });
    } catch (e) {
      log("Error initializing Remote Config: $e");
      // Set default values if Remote Config fails
      _isBlocked = false;
      notifyListeners();
    }
  }

  Future<void> fetchAndActivate() async {
    try {
      bool updated = await _remoteConfig.fetchAndActivate();
      log("Remote Config activated: $updated");

      _isBlocked = _remoteConfig.getBool('isBlocked');
      log("IsBlocked updated: $_isBlocked");
      await AppStorage.$writeBool(key: StorageKey.isBlocked, value: _isBlocked);

      _latestVersion = _remoteConfig.getString('latest_app_version');
      _apkDownloadUrl = _remoteConfig.getString('apk_download_url');
      log("Latest version from Remote Config: $_latestVersion");

      notifyListeners();
    } catch (e) {
      log("Error fetching Remote Config: $e");
      // Set default values if fetching fails
      _isBlocked = false;
      // Don't show error to user, just use default values
      notifyListeners();
    }
  }
}
