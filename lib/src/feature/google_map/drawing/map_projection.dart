import 'dart:math';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Переводит LatLng в экранные координаты виджета карты синхронно, из
/// одной CameraPosition — без `getScreenCoordinate`, который асинхронно
/// ходит в нативный слой и непригоден для перерисовки на каждом кадре.
///
/// Web Mercator, 256·2^zoom логических пикселей на ширину мира (как в
/// Google Maps). Учитывает bearing; наклон камеры не учитывает — на экране
/// рисования он выключен (tiltGesturesEnabled: false).
class MapProjection {
  const MapProjection._();

  static Offset world(LatLng p, double zoom) {
    final scale = 256 * pow(2, zoom).toDouble();
    final siny = sin(p.latitude * pi / 180).clamp(-0.9999, 0.9999);
    return Offset(
      scale * (p.longitude + 180) / 360,
      scale * (0.5 - log((1 + siny) / (1 - siny)) / (4 * pi)),
    );
  }

  static Offset toScreen(LatLng p, CameraPosition camera, Size size) {
    final d = world(p, camera.zoom) - world(camera.target, camera.zoom);
    final r = -camera.bearing * pi / 180;
    return size.center(Offset.zero) +
        Offset(d.dx * cos(r) - d.dy * sin(r), d.dx * sin(r) + d.dy * cos(r));
  }
}
