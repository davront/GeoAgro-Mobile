import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/update_required_dialog.dart';

class VersionCheckService {
  /// Проверяет версию приложения с версией бэкенда
  static Future<void> checkVersionAndShowUpdateDialog(
    BuildContext context,
    String? serverVersion, {
    String downloadUrl = '',
  }) async {
    if (serverVersion == null || serverVersion.isEmpty) {
      debugPrint(
          "🔍 Version check: server version is null/empty, skipping check");
      return; // Если версия с сервера не пришла, не показываем диалог
    }

    final currentVersion = await _getCurrentVersion();
    final comparison = _compareVersions(currentVersion, serverVersion);
    final needsUpdate = comparison < 0;

    debugPrint(
        "🔍 Version check: current=$currentVersion, server=$serverVersion, needsUpdate=$needsUpdate");

    if (needsUpdate) {
      debugPrint(
          "📱 Showing update dialog: app version is older than server version");
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // Нельзя закрыть диалог
          builder: (context) => UpdateRequiredDialog(
            currentVersion: currentVersion,
            requiredVersion: serverVersion,
            downloadUrl: downloadUrl,
          ),
        );
      }
    } else {
      debugPrint("✅ Version check passed: app is up to date");
    }
  }

  /// Получает текущую версию приложения
  static Future<String> _getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return "0.0.0"; // Fallback версия при ошибке
    }
  }

  /// Сравнивает версии в формате "major.minor.patch"
  /// Возвращает:
  /// -1 если current < required (нужно обновление)
  /// 0 если current == required
  /// 1 если current > required
  static int _compareVersions(String current, String required) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final requiredParts = required.split('.').map(int.parse).toList();

      // Дополняем до одинаковой длины нулями
      while (currentParts.length < requiredParts.length) {
        currentParts.add(0);
      }
      while (requiredParts.length < currentParts.length) {
        requiredParts.add(0);
      }

      for (int i = 0; i < currentParts.length; i++) {
        if (currentParts[i] < requiredParts[i]) return -1;
        if (currentParts[i] > requiredParts[i]) return 1;
      }

      return 0;
    } catch (e) {
      // Если не удалось распарсить версии, считаем что обновление не нужно
      return 0;
    }
  }

  /// Получает текущую версию для отображения в UI
  static Future<String> getCurrentVersionForDisplay() async {
    return await _getCurrentVersion();
  }
}
