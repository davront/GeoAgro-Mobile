/// Разбивка площадей/кол-ва фермеров по одному признаку (весь район,
/// только сады, только виноградники) — одинаковая структура во всех
/// трёх блоках ответа `statistics/regions/<region_id>/pending/`.
class AreaBreakdown {
  final int farmerCount;
  final double totalArea;
  final double plantedArea;
  final double economicInefficientArea;
  final double notUsableArea;
  final double emptyArea;

  AreaBreakdown({
    required this.farmerCount,
    required this.totalArea,
    required this.plantedArea,
    required this.economicInefficientArea,
    required this.notUsableArea,
    required this.emptyArea,
  });

  factory AreaBreakdown.fromJson(Map<String, dynamic> json) => AreaBreakdown(
        farmerCount: json["farmer_count"] is int
            ? json["farmer_count"] as int
            : int.tryParse(json["farmer_count"]?.toString() ?? "") ?? 0,
        totalArea: (json["total_area"] as num?)?.toDouble() ?? 0,
        plantedArea: (json["planted_area"] as num?)?.toDouble() ?? 0,
        economicInefficientArea:
            (json["economic_inefficient_area"] as num?)?.toDouble() ?? 0,
        notUsableArea: (json["not_usable_area"] as num?)?.toDouble() ?? 0,
        emptyArea: (json["empty_area"] as num?)?.toDouble() ?? 0,
      );
}

/// Статистика одного района внутри региона —
/// `statistics/regions/<region_id>/pending/` возвращает список таких
/// объектов, по одному на каждый район региона.
class DistrictAreaStat {
  final int districtId;
  final String districtName;
  final AreaBreakdown total;
  final AreaBreakdown fruitGarden;
  final AreaBreakdown vineyard;

  DistrictAreaStat({
    required this.districtId,
    required this.districtName,
    required this.total,
    required this.fruitGarden,
    required this.vineyard,
  });

  factory DistrictAreaStat.fromJson(Map<String, dynamic> json) =>
      DistrictAreaStat(
        districtId: json["district_id"] is int
            ? json["district_id"] as int
            : int.tryParse(json["district_id"]?.toString() ?? "") ?? 0,
        districtName: json["district_name"] as String? ?? "",
        total: AreaBreakdown.fromJson(
            Map<String, dynamic>.from(json["total"] as Map? ?? {})),
        fruitGarden: AreaBreakdown.fromJson(
            Map<String, dynamic>.from(json["fruit_garden"] as Map? ?? {})),
        vineyard: AreaBreakdown.fromJson(
            Map<String, dynamic>.from(json["vineyard"] as Map? ?? {})),
      );
}

List<DistrictAreaStat> districtAreaStatsFromJson(List<dynamic> data) => data
    .whereType<Map>()
    .map((e) => DistrictAreaStat.fromJson(Map<String, dynamic>.from(e)))
    .toList();
