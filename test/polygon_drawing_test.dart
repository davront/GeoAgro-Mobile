import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:agro_employee_public/src/feature/google_map/drawing/drawing_controller.dart';
import 'package:agro_employee_public/src/feature/google_map/drawing/map_projection.dart';
import 'package:agro_employee_public/src/feature/google_map/drawing/polygon_validator.dart';
import 'package:agro_employee_public/src/feature/google_map/drawing/snap_index.dart';

// Соседний участок ~100 м под Ташкентом, наклонный четырёхугольник.
const neighbour = [
  LatLng(41.30000, 69.20000),
  LatLng(41.30090, 69.20030),
  LatLng(41.30070, 69.20150),
  LatLng(41.29985, 69.20120),
];

// Агент стоит внутри рисуемых участков — limit_km не мешает проверкам формы.
List<PolygonIssue> check(List<LatLng> pts) => PolygonValidator.validate(
      points: pts,
      neighbours: const [NeighbourPolygon(4299, neighbour)],
      userLocation: pts.isEmpty ? null : pts.first,
    );

Set<PolygonIssueKind> kinds(List<PolygonIssue> issues) =>
    issues.map((i) => i.kind).toSet();

void main() {
  group('PolygonValidator', () {
    test('меньше трёх точек — подсказка, сколько осталось', () {
      final issues = check(const [LatLng(41.31, 69.21)]);
      expect(kinds(issues), {PolygonIssueKind.tooFewPoints});
      expect(issues.first.message, contains('2'));
    });

    test('самопересечение («бабочка») ловится', () {
      const bowtie = [
        LatLng(41.3100, 69.2100),
        LatLng(41.3110, 69.2112),
        LatLng(41.3110, 69.2100),
        LatLng(41.3100, 69.2112),
      ];
      expect(kinds(check(bowtie)), contains(PolygonIssueKind.selfIntersection));
    });

    test('обычный участок проходит', () {
      const square = [
        LatLng(41.3100, 69.2100),
        LatLng(41.3110, 69.2100),
        LatLng(41.3110, 69.2112),
        LatLng(41.3100, 69.2112),
      ];
      expect(check(square), isEmpty);
    });

    test('участок, прилипший к соседу через snap, — не наложение', () {
      // Тот же сценарий, на котором старая проверка давала ложное
      // «наложение» в 177 из 200 случаев.
      final snap = SnapIndex(const [neighbour]);
      final r = Random(1);
      LatLng along(double t) => LatLng(
            neighbour[1].latitude +
                t * (neighbour[2].latitude - neighbour[1].latitude) +
                0.000015,
            neighbour[1].longitude +
                t * (neighbour[2].longitude - neighbour[1].longitude) +
                0.000015,
          );
      for (var k = 0; k < 200; k++) {
        final a = snap.query(along(0.2 + r.nextDouble() * 0.2))!;
        final b = snap.query(along(0.6 + r.nextDouble() * 0.2))!;
        final mine = [
          a,
          b,
          LatLng(b.latitude + 0.0004, b.longitude + 0.0008),
          LatLng(a.latitude + 0.0004, a.longitude + 0.0006),
        ];
        expect(kinds(check(mine)), isNot(contains(PolygonIssueKind.overlap)),
            reason: 'итерация $k');
      }
    });

    test('вершина внутри соседа глубже допуска — наложение', () {
      const intoNeighbour = [
        LatLng(41.30040, 69.20080), // в середине соседа
        LatLng(41.30040, 69.20250),
        LatLng(41.30120, 69.20250),
        LatLng(41.30120, 69.20080),
      ];
      final issues = check(intoNeighbour);
      expect(kinds(issues), contains(PolygonIssueKind.overlap));
      expect(issues.firstWhere((i) => i.kind == PolygonIssueKind.overlap)
          .plantationId, 4299);
    });

    test('наложение «плюсом» без вершин внутри — ловится', () {
      // Узкая полоса поперёк соседа: её вершины снаружи, соседа — тоже.
      const strip = [
        LatLng(41.30040, 69.19950),
        LatLng(41.30040, 69.20200),
        LatLng(41.30045, 69.20200),
        LatLng(41.30045, 69.19950),
      ];
      expect(kinds(check(strip)), contains(PolygonIssueKind.overlap));
    });

    test('limit_km: агент далеко от участка', () {
      const square = [
        LatLng(41.3100, 69.2100),
        LatLng(41.3110, 69.2100),
        LatLng(41.3110, 69.2112),
      ];
      final issues = PolygonValidator.validate(
        points: square,
        userLocation: const LatLng(41.35, 69.21), // ~4.4 км
        limitKm: 1,
      );
      expect(kinds(issues), {PolygonIssueKind.tooFar});
    });

    test('mock-локация блокирует отправку', () {
      final issues = PolygonValidator.validate(
        points: const [
          LatLng(41.3100, 69.2100),
          LatLng(41.3110, 69.2100),
          LatLng(41.3110, 69.2112),
        ],
        userLocation: const LatLng(41.3105, 69.2105),
        isMockedLocation: true,
      );
      expect(kinds(issues), {PolygonIssueKind.mockedLocation});
    });
  });

  group('SnapIndex', () {
    final index = SnapIndex(const [neighbour]);

    test('прилипает к стороне в пределах 3 м', () {
      final mid = LatLng(
        (neighbour[1].latitude + neighbour[2].latitude) / 2 + 0.00001, // ~1 м
        (neighbour[1].longitude + neighbour[2].longitude) / 2,
      );
      expect(index.query(mid), isNotNull);
    });

    test('не прилипает дальше 3 м', () {
      final far = LatLng(neighbour[1].latitude + 0.0001, // ~11 м
          neighbour[1].longitude);
      expect(index.query(far), isNull);
    });
  });

  group('MapProjection', () {
    const cam = CameraPosition(target: LatLng(41.31, 69.24), zoom: 18);
    const size = Size(400, 800);

    test('центр камеры — центр экрана', () {
      final p = MapProjection.toScreen(cam.target, cam, size);
      expect(p.dx, closeTo(200, 1e-6));
      expect(p.dy, closeTo(400, 1e-6));
    });

    test('масштаб: 256·2^zoom px на 360° долготы', () {
      // 360° / (256·2^18) ≈ 5.364e-6° на пиксель
      final east = LatLng(cam.target.latitude,
          cam.target.longitude + 100 * 360 / (256 * pow(2, 18)));
      final p = MapProjection.toScreen(east, cam, size);
      expect(p.dx, closeTo(300, 1e-3));
      expect(p.dy, closeTo(400, 1e-6));
    });

    test('север — вверх, bearing 90 поворачивает его вправо', () {
      final north = LatLng(cam.target.latitude + 0.0001, cam.target.longitude);
      expect(MapProjection.toScreen(north, cam, size).dy, lessThan(400));
      const rotated =
          CameraPosition(target: LatLng(41.31, 69.24), zoom: 18, bearing: 90);
      final p = MapProjection.toScreen(north, rotated, size);
      expect(p.dx, lessThan(200)); // карта повёрнута: север уходит влево
      expect(p.dy, closeTo(400, 1e-6));
    });
  });

  group('DrawingController', () {
    test('undo откатывает и очистку, redo возвращает', () {
      final c = DrawingController();
      c.add(const LatLng(1, 1));
      c.add(const LatLng(2, 2));
      c.clear();
      expect(c.points, isEmpty);
      c.undo();
      expect(c.points.length, 2);
      c.redo();
      expect(c.points, isEmpty);
    });

    test('новое действие сбрасывает redo', () {
      final c = DrawingController()..add(const LatLng(1, 1));
      c.undo();
      expect(c.canRedo, isTrue);
      c.add(const LatLng(3, 3));
      expect(c.canRedo, isFalse);
    });
  });
}
