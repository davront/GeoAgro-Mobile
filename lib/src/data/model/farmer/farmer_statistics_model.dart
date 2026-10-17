import 'dart:convert';

List<FarmerData> farmerStatisticsModelFromJson(String str) {
  final List<dynamic> jsonList = json.decode(str);
  return jsonList
      .map((e) => FarmerData.fromJson(e as Map<String, dynamic>))
      .toList();
}

String farmerStatisticsModelToJson(List<FarmerData> data) =>
    json.encode(data.map((e) => e.toJson()).toList());

class FarmerData {
  final int? id;
  final int? inn;
  final String? name;
  final int? totalPlantations;
  final int? approvedPlantations;
  final int? rejectedPlantations;
  final int? plantationCount;
  final int? fruitGardenCount;
  final int? vineyardCount;
  final double? totalArea;
  final double? plantedArea;
  final double? notUsableArea;
  final double? emptyArea;
  final double? approvedArea;
  final double? rejectedArea;
  final double? approvePercent;
  final String? lastAddedPlantations;

  FarmerData({
    this.id,
    this.inn,
    this.name,
    this.totalPlantations,
    this.approvedPlantations,
    this.rejectedPlantations,
    this.plantationCount,
    this.fruitGardenCount,
    this.vineyardCount,
    this.totalArea,
    this.plantedArea,
    this.notUsableArea,
    this.emptyArea,
    this.approvedArea,
    this.rejectedArea,
    this.approvePercent,
    this.lastAddedPlantations,
  });

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory FarmerData.fromJson(Map<String, dynamic> json) => FarmerData(
        id: _parseInt(json["farmer_id"]) ?? _parseInt(json["id"]),
        inn: _parseInt(json["farmer_inn"]) ??
            _parseInt(json["inn"]) ??
            _parseInt(json["farmer_id"]) ??
            _parseInt(json["id"]),
        name: json["farmer_name"] ?? json["name"],
        totalPlantations: json["total_plantations"],
        approvedPlantations: json["approved_plantations"],
        rejectedPlantations: json["rejected_plantations"],
        plantationCount: json["plantation_count"],
        fruitGardenCount: json["fruit_garden_count"],
        vineyardCount: json["vineyard_count"],
        totalArea: json["total_area"]?.toDouble(),
        plantedArea: json["planted_area"]?.toDouble(),
        notUsableArea: json["not_usable_area"]?.toDouble(),
        emptyArea: json["empty_area"]?.toDouble(),
        approvedArea: json["approved_area"]?.toDouble(),
        rejectedArea: json["rejected_area"]?.toDouble(),
        approvePercent: json["approve_percent"]?.toDouble(),
        lastAddedPlantations: json["last_added_plantations"],
      );

  Map<String, dynamic> toJson() => {
        "farmer_id": id,
        "farmer_inn": inn,
        "farmer_name": name,
        "total_plantations": totalPlantations,
        "approved_plantations": approvedPlantations,
        "rejected_plantations": rejectedPlantations,
        "plantation_count": plantationCount,
        "fruit_garden_count": fruitGardenCount,
        "vineyard_count": vineyardCount,
        "total_area": totalArea,
        "planted_area": plantedArea,
        "not_usable_area": notUsableArea,
        "empty_area": emptyArea,
        "approved_area": approvedArea,
        "rejected_area": rejectedArea,
        "approve_percent": approvePercent,
        "last_added_plantations": lastAddedPlantations,
      };
}
