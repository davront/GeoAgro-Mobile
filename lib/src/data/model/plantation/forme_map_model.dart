import 'dart:convert';

List<FormeMapPlantation> formeMapModelFromJson(String str) =>
    List<FormeMapPlantation>.from(
        json.decode(str).map((x) => FormeMapPlantation.fromJson(x)));

String formeMapModelToJson(List<FormeMapPlantation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FormeMapPlantation {
  final int id;
  final List<FormeMapCoordinate> coordinates;
  final bool isChecked;
  final double? totalArea;
  final String? farmerName;
  final List<String> konturNumber;

  FormeMapPlantation({
    required this.id,
    required this.coordinates,
    required this.isChecked,
    this.totalArea,
    this.farmerName,
    required this.konturNumber,
  });

  factory FormeMapPlantation.fromJson(Map<String, dynamic> json) =>
      FormeMapPlantation(
        id: json["id"] ?? 0,
        coordinates: json["coordinates"] == null
            ? []
            : List<FormeMapCoordinate>.from(
                json["coordinates"].map((x) => FormeMapCoordinate.fromJson(x))),
        isChecked: json["is_checked"] ?? false,
        totalArea: json["total_area"]?.toDouble(),
        farmerName: json["farmer_name"],
        konturNumber: json["kontur_number"] == null
            ? []
            : List<String>.from(json["kontur_number"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x.toJson())),
        "is_checked": isChecked,
        "total_area": totalArea,
        "farmer_name": farmerName,
        "kontur_number": konturNumber,
      };

  // Получить цвет статуса для отображения на карте
  int getStatusColor() {
    return isChecked ? 0xFF28a745 : 0xFFffc107; // Зеленый - проверено, Желтый - не проверено
  }

  // Получить название статуса на узбекском
  String getStatusName() {
    return isChecked ? 'Tasdiqlangan' : 'Ko\'rib chiqilmoqda';
  }

  // Получить отображаемое имя фермера
  String getDisplayFarmerName() {
    return farmerName ?? 'Кўрсатилмаган';
  }

  // Получить отображаемую площадь
  String getDisplayArea() {
    return totalArea != null ? '${totalArea!.toStringAsFixed(2)} га' : 'Кўрсатилмаган';
  }

  // Получить отображаемые номера контуров
  String getDisplayKonturNumbers() {
    return konturNumber.isEmpty ? 'Кўрсатилмаган' : konturNumber.join(', ');
  }
}


class FormeMapCoordinate {
  final double latitude;
  final double longitude;

  FormeMapCoordinate({
    required this.latitude,
    required this.longitude,
  });

  factory FormeMapCoordinate.fromJson(Map<String, dynamic> json) =>
      FormeMapCoordinate(
        latitude: (json["latitude"] ?? 0.0).toDouble(),
        longitude: (json["longitude"] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
