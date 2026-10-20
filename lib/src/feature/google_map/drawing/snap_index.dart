import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Пространственный индекс рёбер соседних участков для snap-to-edge.
///
/// Прицел опрашивает его на каждом кадре движения карты, поэтому полный
/// перебор (сотни участков × стороны) не годится: рёбра раскладываются по
/// ячейкам сетки ~20 м, и запрос смотрит только 3×3 ячейки вокруг точки.
class SnapIndex {
  SnapIndex(Iterable<List<LatLng>> polygons) {
    for (final poly in polygons) {
      if (poly.length < 2) continue;
      for (var i = 0; i < poly.length; i++) {
        _insert(poly[i], poly[(i + 1) % poly.length]);
      }
    }
  }

  static const double thresholdMeters = 3.0;

  // ~22 м по широте; по долготе на широте Узбекистана ~17 м — с запасом
  // больше порога, так что соседних 3×3 ячеек всегда достаточно.
  static const double _cellDeg = 0.0002;

  // Ребро, которое тянется через тысячи ячеек, — битая геометрия; не
  // раздуваем индекс ради него.
  static const int _maxCellsPerEdge = 4000;

  final Map<int, List<(LatLng, LatLng)>> _cells = {};

  bool get isEmpty => _cells.isEmpty;

  static int _key(int cx, int cy) => cx * 1000003 + cy;

  void _insert(LatLng a, LatLng b) {
    final x0 = (min(a.longitude, b.longitude) / _cellDeg).floor();
    final x1 = (max(a.longitude, b.longitude) / _cellDeg).floor();
    final y0 = (min(a.latitude, b.latitude) / _cellDeg).floor();
    final y1 = (max(a.latitude, b.latitude) / _cellDeg).floor();
    if ((x1 - x0 + 1) * (y1 - y0 + 1) > _maxCellsPerEdge) return;
    for (var x = x0; x <= x1; x++) {
      for (var y = y0; y <= y1; y++) {
        (_cells[_key(x, y)] ??= []).add((a, b));
      }
    }
  }

  /// Ближайшая точка чужой границы не дальше [thresholdMeters] или null.
  LatLng? query(LatLng p) {
    final cx = (p.longitude / _cellDeg).floor();
    final cy = (p.latitude / _cellDeg).floor();
    final mPerDegLat = 111320.0;
    final mPerDegLng = 111320.0 * cos(p.latitude * pi / 180);

    LatLng? best;
    var bestDist = thresholdMeters;
    for (var x = cx - 1; x <= cx + 1; x++) {
      for (var y = cy - 1; y <= cy + 1; y++) {
        final edges = _cells[_key(x, y)];
        if (edges == null) continue;
        for (final (a, b) in edges) {
          final bx = (b.longitude - a.longitude) * mPerDegLng;
          final by = (b.latitude - a.latitude) * mPerDegLat;
          final px = (p.longitude - a.longitude) * mPerDegLng;
          final py = (p.latitude - a.latitude) * mPerDegLat;
          final lenSq = bx * bx + by * by;
          final t =
              lenSq == 0 ? 0.0 : ((px * bx + py * by) / lenSq).clamp(0.0, 1.0);
          final dx = px - t * bx, dy = py - t * by;
          final d = sqrt(dx * dx + dy * dy);
          if (d <= bestDist) {
            bestDist = d;
            best = LatLng(a.latitude + t * (b.latitude - a.latitude),
                a.longitude + t * (b.longitude - a.longitude));
          }
        }
      }
    }
    return best;
  }
}
