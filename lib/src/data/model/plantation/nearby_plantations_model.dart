import 'dart:convert';

NearbyPlantationsModel nearbyPlantationsModelFromJson(String str) =>
    NearbyPlantationsModel.fromJson(json.decode(str));

String nearbyPlantationsModelToJson(NearbyPlantationsModel data) =>
    json.encode(data.toJson());

class NearbyPlantationsModel {
  final List<NearbyPlantation>? plantations;

  NearbyPlantationsModel({
    this.plantations,
  });

  factory NearbyPlantationsModel.fromJson(Map<String, dynamic> json) =>
      NearbyPlantationsModel(
        plantations: json["plantations"] == null
            ? []
            : List<NearbyPlantation>.from(
                json["plantations"]!.map((x) => NearbyPlantation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plantations": plantations == null
            ? []
            : List<dynamic>.from(plantations!.map((x) => x.toJson())),
      };
}

class NearbyPlantation {
  final int? id;
  final String? status; // "approved", "pending", "rejected"
  final double? area;
  final double? perimeter;
  final List<PlantationCoordinate>? coordinates;
  final String? farmerName;
  final int? gardenEstablishedYear;

  NearbyPlantation({
    this.id,
    this.status,
    this.area,
    this.perimeter,
    this.coordinates,
    this.farmerName,
    this.gardenEstablishedYear,
  });

  factory NearbyPlantation.fromJson(Map<String, dynamic> json) =>
      NearbyPlantation(
        id: json["id"],
        status: json["status"],
        area: json["area"]?.toDouble(),
        perimeter: json["perimeter"]?.toDouble(),
        coordinates: json["coordinates"] == null
            ? []
            : List<PlantationCoordinate>.from(
                json["coordinates"]!.map((x) => PlantationCoordinate.fromJson(x))),
        farmerName: json["farmer_name"],
        gardenEstablishedYear: json["garden_established_year"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "area": area,
        "perimeter": perimeter,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => x.toJson())),
        "farmer_name": farmerName,
        "garden_established_year": gardenEstablishedYear,
      };

  // Helper method to get color based on status
  String getStatusDisplayName() {
    switch (status) {
      case 'approved':
        return 'Tasdiqlangan';
      case 'pending':
        return 'Ko\'rib chiqilmoqda';
      case 'rejected':
        return 'Qayta ko\'rishga';
      default:
        return 'Noma\'lum';
    }
  }

  // Helper method to get color for map display
  int getStatusColor() {
    switch (status) {
      case 'approved':
        return 0xFF4CAF50; // Green
      case 'pending':
        return 0xFFFF9800; // Orange
      case 'rejected':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
}

class PlantationCoordinate {
  final double? latitude;
  final double? longitude;

  PlantationCoordinate({
    this.latitude,
    this.longitude,
  });

  factory PlantationCoordinate.fromJson(Map<String, dynamic> json) =>
      PlantationCoordinate(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
