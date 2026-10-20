import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/utils/geo_utils.dart';

enum PolygonIssueKind {
  tooFewPoints,
  selfIntersection,
  overlap,
  noLocation,
  mockedLocation,
  tooFar;

  /// Ошибки формы самого контура — полигон подсвечивается красным.
  bool get isGeometry =>
      this == selfIntersection || this == overlap || this == tooFewPoints;
}

class PolygonIssue {
  final PolygonIssueKind kind;
  final String message;
  final int? plantationId;

  const PolygonIssue(this.kind, this.message, {this.plantationId});
}

/// Соседний участок, с которым сверяется наложение.
class NeighbourPolygon {
  final int id;
  final List<LatLng> points;

  const NeighbourPolygon(this.id, this.points);
}

/// Все проверки рисуемого контура — чистая функция без Flutter, чтобы
/// запускаться на каждое изменение точек и покрываться unit-тестами.
///
/// Геометрия считается в локальных метрах (equirectangular вокруг первой
/// точки): на масштабе одного участка ошибка меньше сантиметра, а допуски
/// задаются в метрах напрямую.
class PolygonValidator {
  const PolygonValidator._();

  /// Насколько вершина может зайти внутрь соседа, не считаясь наложением.
  /// Snap ставит точку прямо на чужую границу, а float-погрешность кладёт
  /// её то чуть внутрь, то чуть наружу — старая проверка считала касание
  /// пересечением и блокировала ~9 из 10 прилипших участков.
  static const double overlapToleranceMeters = 0.5;

  static List<PolygonIssue> validate({
    required List<LatLng> points,
    List<NeighbourPolygon> neighbours = const [],
    LatLng? userLocation,
    bool isMockedLocation = false,
    double limitKm = 1.0,
  }) {
    if (points.length < 3) {
      final left = 3 - points.length;
      return [
        PolygonIssue(PolygonIssueKind.tooFewPoints,
            "Yana $left ta nuqta qo'ying"),
      ];
    }

    final issues = <PolygonIssue>[];
    final frame = _Frame(points.first);
    final mine = points.map(frame.toXY).toList();

    if (_selfIntersects(mine)) {
      issues.add(const PolygonIssue(PolygonIssueKind.selfIntersection,
          "Maydon chegaralari kesishmoqda"));
    }

    final mineBox = _Box.of(mine).inflate(overlapToleranceMeters);
    for (final n in neighbours) {
      if (n.points.length < 3) continue;
      final other = n.points.map(frame.toXY).toList();
      if (!mineBox.overlaps(_Box.of(other))) continue;
      if (_overlaps(mine, other)) {
        issues.add(PolygonIssue(PolygonIssueKind.overlap,
            "Boshqa plantatsiya (#${n.id}) ustiga chizilgan",
            plantationId: n.id));
        break;
      }
    }

    if (userLocation == null) {
      issues.add(const PolygonIssue(PolygonIssueKind.noLocation,
          "Foydalanuvchi joylashuvi aniqlanmadi"));
    } else if (isMockedLocation) {
      issues.add(const PolygonIssue(PolygonIssueKind.mockedLocation,
          "Aniqlangan joylashuv soxta (mock location). Fake GPS dasturlarini "
          "o'chiring va qayta urinib ko'ring"));
    } else {
      final user = frame.toXY(userLocation);
      if (!_contains(mine, user) &&
          _distanceToVertices(points, userLocation) > limitKm * 1000) {
        final km = limitKm == limitKm.truncateToDouble()
            ? limitKm.toStringAsFixed(0)
            : limitKm.toStringAsFixed(1);
        issues.add(PolygonIssue(PolygonIssueKind.tooFar,
            "Foydalanuvchi kiritilgan maydonning $km km radiusida emas"));
      }
    }

    return issues;
  }

  // Та же метрика, что и в прежней validateCoordinatesWithLimit — до
  // ближайшей вершины, не стороны, чтобы не менять правило antifraud.
  static double _distanceToVertices(List<LatLng> points, LatLng p) =>
      GeoUtils.minDistanceToPolygon(p.latitude, p.longitude,
          points.map((e) => (e.latitude, e.longitude)).toList());

  static bool _selfIntersects(List<Point<double>> poly) {
    final n = poly.length;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        // Соседние стороны делят вершину — это не пересечение.
        if (j == i + 1 || (i == 0 && j == n - 1)) continue;
        if (_properCross(poly[i], poly[(i + 1) % n], poly[j],
                poly[(j + 1) % n]) !=
            null) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _overlaps(List<Point<double>> mine, List<Point<double>> other) {
    // 1. Вершина заходит внутрь чужого контура глубже допуска.
    for (final p in mine) {
      if (_contains(other, p) &&
          _distanceToEdges(other, p) > overlapToleranceMeters) {
        return true;
      }
    }
    for (final p in other) {
      if (_contains(mine, p) &&
          _distanceToEdges(mine, p) > overlapToleranceMeters) {
        return true;
      }
    }
    // 2. Стороны пересекаются крест-накрест вдали от вершин — ловит
    // наложение "плюсом", когда ни одна вершина не внутри.
    for (var i = 0; i < mine.length; i++) {
      final a = mine[i], b = mine[(i + 1) % mine.length];
      for (var j = 0; j < other.length; j++) {
        final c = other[j], d = other[(j + 1) % other.length];
        // Сторона, прилипшая к чужой, лежит на ней: знаки векторного
        // произведения у почти коллинеарных отрезков — шум float, и
        // "пересечение" находится в случайной точке посередине стороны.
        if (_alongEachOther(a, b, c, d)) continue;
        final x = _properCross(a, b, c, d);
        if (x == null) continue;
        final nearVertex = [...mine, ...other]
            .any((v) => v.distanceTo(x) <= overlapToleranceMeters);
        if (!nearVertex) return true;
      }
    }
    return false;
  }

  /// Один из отрезков целиком в пределах допуска от другого.
  static bool _alongEachOther(
      Point<double> a, Point<double> b, Point<double> c, Point<double> d) {
    const tol = overlapToleranceMeters;
    return (_segmentDistance(a, c, d) <= tol &&
            _segmentDistance(b, c, d) <= tol) ||
        (_segmentDistance(c, a, b) <= tol && _segmentDistance(d, a, b) <= tol);
  }

  /// Точка строгого пересечения отрезков или null (касание, коллинеарность
  /// и общий конец пересечением не считаются).
  static Point<double>? _properCross(
      Point<double> p1, Point<double> p2, Point<double> p3, Point<double> p4) {
    final d1 = _cross(p3, p4, p1), d2 = _cross(p3, p4, p2);
    final d3 = _cross(p1, p2, p3), d4 = _cross(p1, p2, p4);
    if (!((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0))) return null;
    if (!((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) return null;
    final t = d1 / (d1 - d2);
    return Point(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y));
  }

  static double _cross(Point<double> a, Point<double> b, Point<double> c) =>
      (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);

  static bool _contains(List<Point<double>> poly, Point<double> p) {
    var inside = false;
    for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final a = poly[i], b = poly[j];
      if ((a.y > p.y) != (b.y > p.y) &&
          p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x) {
        inside = !inside;
      }
    }
    return inside;
  }

  static double _distanceToEdges(List<Point<double>> poly, Point<double> p) {
    var best = double.infinity;
    for (var i = 0; i < poly.length; i++) {
      final d = _segmentDistance(p, poly[i], poly[(i + 1) % poly.length]);
      if (d < best) best = d;
    }
    return best;
  }

  static double _segmentDistance(
      Point<double> p, Point<double> a, Point<double> b) {
    final abx = b.x - a.x, aby = b.y - a.y;
    final lenSq = abx * abx + aby * aby;
    final t = lenSq == 0
        ? 0.0
        : (((p.x - a.x) * abx + (p.y - a.y) * aby) / lenSq).clamp(0.0, 1.0);
    return p.distanceTo(Point(a.x + t * abx, a.y + t * aby));
  }
}

/// Локальная плоская система координат в метрах вокруг [origin].
class _Frame {
  final LatLng origin;
  final double _mPerDegLng;
  static const double _mPerDegLat = 111320.0;

  _Frame(this.origin)
      : _mPerDegLng = 111320.0 * cos(origin.latitude * pi / 180);

  Point<double> toXY(LatLng p) => Point(
        (p.longitude - origin.longitude) * _mPerDegLng,
        (p.latitude - origin.latitude) * _mPerDegLat,
      );
}

class _Box {
  final double minX, minY, maxX, maxY;

  const _Box(this.minX, this.minY, this.maxX, this.maxY);

  factory _Box.of(List<Point<double>> pts) {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (final p in pts) {
      minX = min(minX, p.x);
      minY = min(minY, p.y);
      maxX = max(maxX, p.x);
      maxY = max(maxY, p.y);
    }
    return _Box(minX, minY, maxX, maxY);
  }

  _Box inflate(double d) => _Box(minX - d, minY - d, maxX + d, maxY + d);

  bool overlaps(_Box o) =>
      minX <= o.maxX && o.minX <= maxX && minY <= o.maxY && o.minY <= maxY;
}
