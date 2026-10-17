// import 'dart:math';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class PolygonUtils {
//   // Yer radiusi (metrlarda)
//   static const double earthRadius = 6371000;

//   /// Poligonning umumiy maydonini hisoblash
//   static double calculatePolygonArea(List<LatLng> points) {
//     if (points.length < 3) {
//       return 0.0; // Ko'p burchak uchun kamida 3 nuqta kerak
//     }

//     double area = 0.0;

//     for (int i = 0; i < points.length; i++) {
//       final LatLng p1 = points[i];
//       final LatLng p2 = points[
//           (i + 1) % points.length]; // Oxirgi nuqtani birinchi nuqtaga ulash

//       // Koordinatalarni radianlarga o'tkazish
//       final double x1 = p1.longitude * pi / 180 * cos(p1.latitude * pi / 180);
//       final double y1 = p1.latitude * pi / 180;

//       final double x2 = p2.longitude * pi / 180 * cos(p2.latitude * pi / 180);
//       final double y2 = p2.latitude * pi / 180;

//       // Shoelace formula asosida maydonni hisoblash
//       area += (x1 * y2 - y1 * x2);
//     }

//     // Yer radiusini hisobga olgan holda maydonni topish
//     area = (area * earthRadius * earthRadius).abs() / 2.0;

//     return area; // Kvadrat metrda qaytariladi
//   }
// }
