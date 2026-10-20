import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'drawing_controller.dart';
import 'map_projection.dart';

/// Линия от последней точки к прицелу и пунктир замыкания к первой —
/// рисуются поверх карты во Flutter. Перерисовка идёт по [crosshair]
/// (каждый кадр движения камеры) через `CustomPaint(repaint:)`, без
/// перестройки виджетов и без обращений к нативной карте.
class PreviewOverlay extends StatelessWidget {
  final ValueListenable<Crosshair?> crosshair;
  final List<LatLng> points;
  final Color color;

  const PreviewOverlay({
    super.key,
    required this.crosshair,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _PreviewPainter(crosshair, points, color),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  final ValueListenable<Crosshair?> crosshair;
  final List<LatLng> points;
  final Color color;

  _PreviewPainter(this.crosshair, this.points, this.color)
      : super(repaint: crosshair);

  @override
  void paint(Canvas canvas, Size size) {
    final c = crosshair.value;
    if (c == null) return;

    final aim = MapProjection.toScreen(c.point, c.camera, size);
    if (c.snapTarget != null) {
      canvas.drawCircle(aim, 5, Paint()..color = color);
    }
    if (points.isEmpty) return;

    final last = MapProjection.toScreen(points.last, c.camera, size);
    canvas.drawLine(
      last,
      aim,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    if (points.length >= 2) {
      final first = MapProjection.toScreen(points.first, c.camera, size);
      _dashed(
        canvas,
        aim,
        first,
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = 2,
      );
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 8.0, gap = 6.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    for (var d = 0.0; d < total; d += dash + gap) {
      final end = d + dash < total ? d + dash : total;
      canvas.drawLine(a + dir * d, a + dir * end, paint);
    }
  }

  @override
  bool shouldRepaint(_PreviewPainter old) =>
      old.points != points || old.color != color || old.crosshair != crosshair;
}
