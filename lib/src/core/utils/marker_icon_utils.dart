import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerIconUtils {
  /// Синяя точка текущего местоположения юзера на карте (стиль как в
  /// стандартном Google Maps "My Location"). Раньше грузилась из
  /// assets/images/user_arrow.png, но тот файл оказался битым (1 байт,
  /// не PNG) — rootBundle.load читал его "успешно", BitmapDescriptor.bytes
  /// не валидирует содержимое на Dart-стороне, и краш вылезал только
  /// глубоко в нативном слое Google Maps при рендере маркера, необрабатываемо
  /// из Dart. Генерация тем же canvas-путём, что и createRulerIcon ниже,
  /// убирает зависимость от asset-файла вообще.
  ///
  /// Рендерится в 4x логического размера — на маркерах Google Maps
  /// растягивает bitmap под текущий zoom/плотность экрана, при 1x-canvas
  /// (как было раньше со стрелкой) получалось видимо пиксельно.
  static Future<BitmapDescriptor> createUserArrowIcon() async {
    const double logicalSize = 18.0;
    const double scale = 4.0;
    const double size = logicalSize * scale;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double center = size / 2;

    // Мягкий halo вокруг точки — как у Google Maps "My Location". Halo
    // радиус меньше центра canvas, иначе съедает весь запас и визуально
    // доминирует над самой точкой.
    final Paint haloPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center, center), center * 0.85, haloPaint);

    // Белая обводка (контрастна на любом фоне карты).
    final Paint outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center, center), 7 * scale, outlinePaint);

    // Синяя заливка — стандартный цвет "текущее местоположение".
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center, center), 5 * scale, fillPaint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw StateError('Failed to encode user location icon to PNG bytes');
    }
    // Без imagePixelRatio BitmapDescriptor.bytes рендерит PNG 1:1 в
    // логические px — наш 112px canvas (scale=4) занимал бы 112 логических
    // px на экране вместо задуманных 28, отсюда гигантская точка.
    return BitmapDescriptor.bytes(
      data.buffer.asUint8List(),
      imagePixelRatio: scale,
    );
  }

  static Future<BitmapDescriptor> createRulerIcon() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Размер иконки
    const double size = 60.0;
    const double strokeWidth = 3.0;

    // Рисуем белый круг
    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Рисуем черную обводку
    final Paint strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2.0;

    final double center = size / 2;
    final double radius = (size - strokeWidth) / 2;

    // Сначала рисуем черную обводку
    canvas.drawCircle(Offset(center, center), radius + 1, strokePaint);

    // Затем белый круг
    canvas.drawCircle(Offset(center, center), radius, circlePaint);

    // Рисуем крестик в центре
    final Paint crossPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double crossSize = 8.0;
    // Горизонтальная линия
    canvas.drawLine(
      Offset(center - crossSize, center),
      Offset(center + crossSize, center),
      crossPaint,
    );
    // Вертикальная линия
    canvas.drawLine(
      Offset(center, center - crossSize),
      Offset(center, center + crossSize),
      crossPaint,
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  /// Маркер вершины полигона при рисовании плантации — номерованный
  /// кружок в цвете AppColors.info (согласован с линией/заливкой
  /// рисуемого полигона в create_map_page_vm.dart). Раньше вершины
  /// рисовались стандартной жёлтой Google-каплей
  /// (BitmapDescriptor.defaultMarkerWithHue(hueYellow)) — родовая форма,
  /// не показывала номер точки без тапа, и цвет расходился с остальной
  /// info-синей палитрой рисования.
  static Future<BitmapDescriptor> createPolygonVertexIcon(int number) async {
    const double logicalSize = 26.0;
    const double scale = 4.0;
    const double size = logicalSize * scale;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double center = size / 2;

    // Мягкая тень для отрыва от фона карты/полигона.
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
    canvas.drawCircle(
        const Offset(center, center + 2), 11 * scale, shadowPaint);

    // Белая обводка — контраст на зелёном/синем фоне карты и полигона.
    final Paint outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(center, center), 11 * scale, outlinePaint);

    // Заливка цветом линии рисования (AppColors.info).
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF0369A1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(center, center), 9 * scale, fillPaint);

    // Номер точки — виден без тапа на InfoWindow, помогает
    // ориентироваться в порядке обхода полигона при рисовании.
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11 * scale,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center - textPainter.width / 2,
        center - textPainter.height / 2,
      ),
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw StateError('Failed to encode polygon vertex icon to PNG bytes');
    }
    return BitmapDescriptor.bytes(
      data.buffer.asUint8List(),
      imagePixelRatio: scale,
    );
  }
}
