import 'dart:math';

/// Общая геометрия для проверок "точка рядом с полигоном" — используется и
/// при создании плантации (рисование полигона на карте), и при
/// редактировании (сверка GPS с уже сохранёнными координатами). Работает
/// с голыми lat/lng, а не с каким-то одним типом координат (LatLng из
/// google_maps_flutter, собственный Coordinate и т.д.), чтобы не тянуть
/// зависимость на пакет карт туда, где полигон не рисуется.
class GeoUtils {
  const GeoUtils._();

  static double _degreesToRadians(double degrees) => degrees * pi / 180;

  /// Расстояние между двумя точками по большому кругу, в метрах.
  static double haversineMeters(
      double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Точка внутри полигона (ray casting). `polygon` — список [lat, lng]
  /// пар в порядке обхода контура.
  static bool isPointInPolygon(
      double lat, double lng, List<(double, double)> polygon) {
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final (latI, lngI) = polygon[i];
      final (latJ, lngJ) = polygon[j];
      if (((latI > lat) != (latJ > lat)) &&
          (lng < (lngJ - lngI) * (lat - latI) / (latJ - latI) + lngI)) {
        inside = !inside;
      }
    }
    return inside;
  }

  /// Минимальное расстояние (в метрах) от точки до любой вершины полигона.
  static double minDistanceToPolygon(
      double lat, double lng, List<(double, double)> polygon) {
    var minDistance = double.infinity;
    for (final (pLat, pLng) in polygon) {
      final d = haversineMeters(lat, lng, pLat, pLng);
      if (d < minDistance) minDistance = d;
    }
    return minDistance;
  }

  /// Ближайшая точка на любом ребре полигона (не только на вершинах —
  /// проекция на сегмент между двумя соседними вершинами), плюс
  /// расстояние до неё в метрах. Используется для snap-to-edge при
  /// рисовании нового полигона рядом с уже существующим участком —
  /// без этого прилипание срабатывало бы только точно у вершины
  /// соседнего контура, не вдоль всей его границы.
  ///
  /// Аппроксимация: работает в декартовых координатах (lat/lng как
  /// плоские x/y с масштабом по широте), приемлемо на масштабе одного
  /// земельного участка (десятки-сотни метров), не для больших дистанций.
  static ((double, double) point, double distanceMeters)
      nearestPointOnPolygonEdge(
    double lat,
    double lng,
    List<(double, double)> polygon,
  ) {
    if (polygon.isEmpty) {
      return ((lat, lng), double.infinity);
    }
    if (polygon.length == 1) {
      final (pLat, pLng) = polygon.first;
      return ((pLat, pLng), haversineMeters(lat, lng, pLat, pLng));
    }

    // Локальный плоский масштаб — градусы широты/долготы в метры,
    // достаточно точный для расстояний в пределах одного участка.
    final metersPerDegLat = 111320.0;
    final metersPerDegLng = 111320.0 * cos(_degreesToRadians(lat));

    double bestDistance = double.infinity;
    (double, double) bestPoint = polygon.first;

    for (var i = 0; i < polygon.length; i++) {
      final (aLat, aLng) = polygon[i];
      final (bLat, bLng) = polygon[(i + 1) % polygon.length];

      // Проекция точки на отрезок [A, B] в локальных метровых координатах.
      final ax = 0.0, ay = 0.0;
      final bx = (bLng - aLng) * metersPerDegLng;
      final by = (bLat - aLat) * metersPerDegLat;
      final px = (lng - aLng) * metersPerDegLng;
      final py = (lat - aLat) * metersPerDegLat;

      final abLenSq = bx * bx + by * by;
      final t =
          abLenSq == 0 ? 0.0 : ((px * bx + py * by) / abLenSq).clamp(0.0, 1.0);

      final projX = ax + t * (bx - ax);
      final projY = ay + t * (by - ay);
      final dx = px - projX;
      final dy = py - projY;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < bestDistance) {
        bestDistance = distance;
        bestPoint = (
          aLat + t * (bLat - aLat),
          aLng + t * (bLng - aLng),
        );
      }
    }

    return (bestPoint, bestDistance);
  }
}
