import 'package:flutter_test/flutter_test.dart';

import 'package:agro_employee_public/localization/app_strings.dart';
import 'package:agro_employee_public/src/core/utils/geo_utils.dart';
import 'package:agro_employee_public/src/core/utils/plantation_location_guard.dart';

void main() {
  group('TaskSubmitGate.rejectIfPlantationStillRejected', () {
    test('блокирует сдачу, пока плантация rejected', () {
      expect(
        TaskSubmitGate.rejectIfPlantationStillRejected(isRejected: true),
        AppStrings.taskMustResubmitPlantation,
      );
    });

    test('пропускает, если плантация уже не rejected', () {
      expect(
        TaskSubmitGate.rejectIfPlantationStillRejected(isRejected: false),
        isNull,
      );
    });

    test('fail-closed: неизвестный флаг тоже блок', () {
      expect(
        TaskSubmitGate.rejectIfPlantationStillRejected(isRejected: null),
        AppStrings.taskMustResubmitPlantation,
      );
    });
  });

  group('TaskSubmitGate.polygonFromNullablePairs', () {
    test('отбрасывает точки без lat/lng и оставляет валидный полигон', () {
      final polygon = TaskSubmitGate.polygonFromNullablePairs([
        (41.0, 69.0),
        (41.1, 69.0),
        (null, 69.1),
        (41.1, 69.1),
        (41.0, null),
      ]);

      expect(polygon, hasLength(3));
      expect(polygon.first, (41.0, 69.0));
    });
  });

  group('GeoUtils near plantation (joyida rule)', () {
    // Квадрат ~ вокруг (41.3, 69.2)
    final polygon = <(double, double)>[
      (41.300, 69.200),
      (41.301, 69.200),
      (41.301, 69.201),
      (41.300, 69.201),
    ];

    test('точка внутри полигона — ок', () {
      expect(
        GeoUtils.isPointInPolygon(41.3005, 69.2005, polygon),
        isTrue,
      );
    });

    test('точка далеко — расстояние больше 1 км', () {
      final d = GeoUtils.minDistanceToPolygon(41.40, 69.30, polygon);
      expect(d, greaterThan(1000));
    });

    test('точка рядом с вершиной — меньше 1 км', () {
      final d = GeoUtils.minDistanceToPolygon(41.3001, 69.2001, polygon);
      expect(d, lessThan(1000));
    });
  });
}
