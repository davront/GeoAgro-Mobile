import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../localization/app_strings.dart';
import '../storage/app_storage.dart';
import 'geo_utils.dart';

/// GPS + limit_km для «на месте»: joyida-edit и сдача задачи с плантацией.
/// Fail-closed: нет permission / mock / таймаут → нельзя.
class PlantationLocationGuard {
  const PlantationLocationGuard._();

  /// Текущая точка. null — нет доступа, mock GPS или не удалось получить.
  static Future<Map<String, double>?> currentUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (pos.isMocked) return null;
      return {"latitude": pos.latitude, "longitude": pos.longitude};
    } catch (e) {
      debugPrint('PlantationLocationGuard: location unavailable: $e');
      return null;
    }
  }

  /// null — можно продолжать; иначе текст ошибки для пользователя.
  ///
  /// [polygon] — список (lat, lng). Меньше 3 точек → нет координат.
  static Future<String?> checkNearPolygon(
    Map<String, double>? userLoc,
    List<(double, double)> polygon, {
    String? tooFarMessage,
  }) async {
    if (polygon.length < 3) {
      return AppStrings.taskPlantationNoCoords;
    }

    if (userLoc == null) {
      return AppStrings.taskLocationUnavailable;
    }

    final lat = userLoc["latitude"];
    final lng = userLoc["longitude"];
    if (lat == null || lng == null) {
      return AppStrings.taskLocationUnavailable;
    }

    if (GeoUtils.isPointInPolygon(lat, lng, polygon)) return null;

    final minDistance = GeoUtils.minDistanceToPolygon(lat, lng, polygon);
    final limitKm =
        await AppStorage.$readDouble(key: StorageKey.limitKm) ?? 1.0;
    final limitMeters = limitKm * 1000;

    if (minDistance > limitMeters) {
      if (tooFarMessage != null) return tooFarMessage;
      final limitLabel = limitKm.truncateToDouble() == limitKm
          ? limitKm.toStringAsFixed(0)
          : limitKm.toStringAsFixed(1);
      return AppStrings.taskTooFarFromPlantation(limitLabel);
    }
    return null;
  }
}

/// Чистые правила сдачи задачи с плантацией (без GPS I/O) — для тестов и VM.
class TaskSubmitGate {
  const TaskSubmitGate._();

  /// Плантация всё ещё отклонена — сначала joyida + повторная модерация.
  ///
  /// Fail-closed: `null` (флаг неизвестен) тоже блокирует сдачу.
  static String? rejectIfPlantationStillRejected({required bool? isRejected}) {
    if (isRejected != false) return AppStrings.taskMustResubmitPlantation;
    return null;
  }

  /// Полигон для проверки GPS из списка координат с nullable lat/lng.
  static List<(double, double)> polygonFromNullablePairs(
      Iterable<(double?, double?)> coords) {
    return coords
        .where((p) => p.$1 != null && p.$2 != null)
        .map((p) => (p.$1!, p.$2!))
        .toList();
  }
}
