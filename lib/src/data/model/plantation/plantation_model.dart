// To parse this JSON data, do
//
//     final plantationModel = plantationModelFromJson(jsonString);

import 'dart:convert';

PlantationModel plantationModelFromJson(String str) => PlantationModel.fromJson(json.decode(str));

String plantationModelToJson(PlantationModel data) => json.encode(data.toJson());

class PlantationModel {
    int? id;
    int? gardenEstablishedYear;
    int? plantationType;
    double? totalArea;
    double? irrigationArea;
    int? landType;
    double? fertilityScore;
    bool? isFertile;
    bool? fenced;
    int? irrigationSystemsCount;
    List<Investment>? investments;
    List<Reservoir>? reservoirs;
    List<Trellise>? trellises;
    List<FruitArea>? fruitAreas;
    List<String>? images;
    List<Subsidy>? subsidies;
    double? notUsableArea;

    PlantationModel({
        this.id,
        this.gardenEstablishedYear,
        this.plantationType,
        this.totalArea,
        this.irrigationArea,
        this.landType,
        this.fertilityScore,
        this.isFertile,
        this.fenced,
        this.irrigationSystemsCount,
        this.investments,
        this.reservoirs,
        this.trellises,
        this.fruitAreas,
        this.images,
        this.subsidies,
        this.notUsableArea,
    });

    PlantationModel copyWith({
        int? id,
        int? gardenEstablishedYear,
        int? plantationType,
        double? totalArea,
        double? irrigationArea,
        int? landType,
        double? fertilityScore,
        bool? isFertile,
        bool? fenced,
        int? irrigationSystemsCount,
        List<Investment>? investments,
        List<Reservoir>? reservoirs,
        List<Trellise>? trellises,
        List<FruitArea>? fruitAreas,
        List<String>? images,
        List<Subsidy>? subsidies,
        double? notUsableArea,
    }) => 
        PlantationModel(
            id: id ?? this.id,
            gardenEstablishedYear: gardenEstablishedYear ?? this.gardenEstablishedYear,
            plantationType: plantationType ?? this.plantationType,
            totalArea: totalArea ?? this.totalArea,
            irrigationArea: irrigationArea ?? this.irrigationArea,
            landType: landType ?? this.landType,
            fertilityScore: fertilityScore ?? this.fertilityScore,
            isFertile: isFertile ?? this.isFertile,
            fenced: fenced ?? this.fenced,
            irrigationSystemsCount: irrigationSystemsCount ?? this.irrigationSystemsCount,
            investments: investments ?? this.investments,
            reservoirs: reservoirs ?? this.reservoirs,
            trellises: trellises ?? this.trellises,
            fruitAreas: fruitAreas ?? this.fruitAreas,
            images: images ?? this.images,
            subsidies: subsidies ?? this.subsidies,
            notUsableArea: notUsableArea ?? this.notUsableArea,
        );

    factory PlantationModel.fromJson(Map<String, dynamic> json) => PlantationModel(
        id: json["id"],
        gardenEstablishedYear: json["garden_established_year"],
        plantationType: json["plantation_type"],
        totalArea: json["total_area"]?.toDouble(),
        irrigationArea: json["irrigation_area"]?.toDouble(),
        landType: json["land_type"],
        fertilityScore: json["fertility_score"]?.toDouble(),
        isFertile: json["is_fertile"],
        fenced: json["fenced"],
        irrigationSystemsCount: json["irrigation_systems_count"],
        investments: json["investments"] == null ? [] : List<Investment>.from(json["investments"]!.map((x) => Investment.fromJson(x))),
        reservoirs: json["reservoirs"] == null ? [] : List<Reservoir>.from(json["reservoirs"]!.map((x) => Reservoir.fromJson(x))),
        trellises: json["trellises"] == null ? [] : List<Trellise>.from(json["trellises"]!.map((x) => Trellise.fromJson(x))),
        fruitAreas: json["fruit_areas"] == null ? [] : List<FruitArea>.from(json["fruit_areas"]!.map((x) => FruitArea.fromJson(x))),
        images: (() {
          final imgs = json["images"];
          if (imgs == null) return <String>[];
          if (imgs is List) {
            return imgs
                .map((e) {
                  if (e is Map<String, dynamic>) {
                    final raw = (e["image_url"] ?? e["image"])?.toString();
                    if (raw == null) return null;
                    return raw.startsWith('http://') ? raw.replaceFirst('http://', 'https://') : raw;
                  }
                  final s = e?.toString();
                  if (s == null) return null;
                  return s.startsWith('http://') ? s.replaceFirst('http://', 'https://') : s;
                })
                .whereType<String>()
                .toList();
          }
          return <String>[];
        })(),
        subsidies: json["subsidies"] == null ? [] : List<Subsidy>.from(json["subsidies"]!.map((x) => Subsidy.fromJson(x))),
        notUsableArea: json["not_usable_area"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "garden_established_year": gardenEstablishedYear,
        "plantation_type": plantationType,
        "total_area": totalArea,
        "irrigation_area": irrigationArea,
        "land_type": landType,
        "fertility_score": fertilityScore,
        "is_fertile": isFertile,
        "fenced": fenced,
        "irrigation_systems_count": irrigationSystemsCount,
        "investments": investments == null ? [] : List<dynamic>.from(investments!.map((x) => x.toJson())),
        "reservoirs": reservoirs == null ? [] : List<dynamic>.from(reservoirs!.map((x) => x.toJson())),
        "trellises": trellises == null ? [] : List<dynamic>.from(trellises!.map((x) => x.toJson())),
        "fruit_areas": fruitAreas == null ? [] : List<dynamic>.from(fruitAreas!.map((x) => x.toJson())),
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "subsidies": subsidies == null ? [] : List<dynamic>.from(subsidies!.map((x) => x.toJson())),
        "not_usable_area": notUsableArea,
    };
}

class FruitArea {
    int? fruit; // ID фрукта
    int? variety; // ID сорта
    int? rootstock; // ID подвоя
    String? fruitName; // Название фрукта
    String? varietyName; // Название сорта
    String? rootstockName; // Название подвоя
    int? plantedYear;
    double? area;
    String? schema;

    FruitArea({
        this.fruit,
        this.variety,
        this.rootstock,
        this.fruitName,
        this.varietyName,
        this.rootstockName,
        this.plantedYear,
        this.area,
        this.schema,
    });

    FruitArea copyWith({
        int? fruit,
        int? variety,
        int? rootstock,
        String? fruitName,
        String? varietyName,
        String? rootstockName,
        int? plantedYear,
        double? area,
        String? schema,
    }) => 
        FruitArea(
            fruit: fruit ?? this.fruit,
            variety: variety ?? this.variety,
            rootstock: rootstock ?? this.rootstock,
            fruitName: fruitName ?? this.fruitName,
            varietyName: varietyName ?? this.varietyName,
            rootstockName: rootstockName ?? this.rootstockName,
            plantedYear: plantedYear ?? this.plantedYear,
            area: area ?? this.area,
            schema: schema ?? this.schema,
        );

    factory FruitArea.fromJson(Map<String, dynamic> json) {
      // Обрабатываем новый формат, где fruit, variety, rootstock - это объекты
      int? fruitId;
      String? fruitName;
      int? varietyId;
      String? varietyName;
      int? rootstockId;
      String? rootstockName;

      // Обрабатываем поле fruit
      if (json["fruit"] is Map<String, dynamic>) {
        fruitId = json["fruit"]["id"];
        fruitName = json["fruit"]["name"];
      } else {
        fruitId = json["fruit"] is int ? json["fruit"] : int.tryParse(json["fruit"]?.toString() ?? "");
        fruitName = json["fruit_name"] ?? json["fruit"]?.toString();
      }

      // Обрабатываем поле variety
      if (json["variety"] is Map<String, dynamic>) {
        varietyId = json["variety"]["id"];
        varietyName = json["variety"]["name"];
      } else {
        varietyId = json["variety"] is int ? json["variety"] : int.tryParse(json["variety"]?.toString() ?? "");
        varietyName = json["variety_name"] ?? json["variety"]?.toString();
      }

      // Обрабатываем поле rootstock
      if (json["rootstock"] is Map<String, dynamic>) {
        rootstockId = json["rootstock"]["id"];
        rootstockName = json["rootstock"]["name"];
      } else {
        rootstockId = json["rootstock"] is int ? json["rootstock"] : int.tryParse(json["rootstock"]?.toString() ?? "");
        rootstockName = json["rootstock_name"] ?? json["rootstock"]?.toString();
      }

      return FruitArea(
        fruit: fruitId,
        variety: varietyId,
        rootstock: rootstockId,
        fruitName: fruitName,
        varietyName: varietyName,
        rootstockName: rootstockName,
        plantedYear: json["planted_year"],
        area: json["area"]?.toDouble(),
        schema: json["schema"],
      );
    }

    Map<String, dynamic> toJson() => {
        "fruit": fruit,
        "variety": variety,
        "rootstock": rootstock,
        "planted_year": plantedYear,
        "area": area,
        "schema": schema,
    };
}

class Investment {
    int? id;
    int? investType;
    double? investmentAmount;

    Investment({
        this.id,
        this.investType,
        this.investmentAmount,
    });

    Investment copyWith({
        int? id,
        int? investType,
        double? investmentAmount,
    }) => 
        Investment(
            id: id ?? this.id,
            investType: investType ?? this.investType,
            investmentAmount: investmentAmount ?? this.investmentAmount,
        );

    factory Investment.fromJson(Map<String, dynamic> json) => Investment(
        id: json["id"],
        investType: json["invest_type"],
        investmentAmount: json["investment_amount"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "invest_type": investType,
        "investment_amount": investmentAmount,
    };
}

class Reservoir {
    int? id;
    int? plantation;
    int? reservoirType;
    String? reservoirVolume;

    Reservoir({
        this.id,
        this.plantation,
        this.reservoirType,
        this.reservoirVolume,
    });

    Reservoir copyWith({
        int? id,
        int? plantation,
        int? reservoirType,
        String? reservoirVolume,
    }) => 
        Reservoir(
            id: id ?? this.id,
            plantation: plantation ?? this.plantation,
            reservoirType: reservoirType ?? this.reservoirType,
            reservoirVolume: reservoirVolume ?? this.reservoirVolume,
        );

    factory Reservoir.fromJson(Map<String, dynamic> json) => Reservoir(
        id: json["id"],
        plantation: json["plantation"],
        reservoirType: json["reservoir_type"],
        reservoirVolume: json["reservoir_volume"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "plantation": plantation,
        "reservoir_type": reservoirType,
        "reservoir_volume": reservoirVolume,
    };
}

class Subsidy {
    int? year;
    String? contractNumber;
    int? direction;
    double? amount;
    bool? efficiency;

    Subsidy({
        this.year,
        this.contractNumber,
        this.direction,
        this.amount,
        this.efficiency,
    });

    Subsidy copyWith({
        int? year,
        String? contractNumber,
        int? direction,
        double? amount,
        bool? efficiency,
    }) => 
        Subsidy(
            year: year ?? this.year,
            contractNumber: contractNumber ?? this.contractNumber,
            direction: direction ?? this.direction,
            amount: amount ?? this.amount,
            efficiency: efficiency ?? this.efficiency,
        );

    factory Subsidy.fromJson(Map<String, dynamic> json) => Subsidy(
        year: json["year"],
        contractNumber: json["contract_number"],
        direction: json["direction"],
        amount: json["amount"]?.toDouble(),
        efficiency: json["efficiency"],
    );

    Map<String, dynamic> toJson() => {
        "year": year,
        "contract_number": contractNumber,
        "direction": direction,
        "amount": amount,
        "efficiency": efficiency,
    };
}

class Trellise {
    int? id;
    int? plantation;
    double? trellisInstalledArea;
    int? trellisType;
    int? trellisCount;

    Trellise({
        this.id,
        this.plantation,
        this.trellisInstalledArea,
        this.trellisType,
        this.trellisCount,
    });

    Trellise copyWith({
        int? id,
        int? plantation,
        double? trellisInstalledArea,
        int? trellisType,
        int? trellisCount,
    }) => 
        Trellise(
            id: id ?? this.id,
            plantation: plantation ?? this.plantation,
            trellisInstalledArea: trellisInstalledArea ?? this.trellisInstalledArea,
            trellisType: trellisType ?? this.trellisType,
            trellisCount: trellisCount ?? this.trellisCount,
        );

    factory Trellise.fromJson(Map<String, dynamic> json) => Trellise(
        id: json["id"],
        plantation: json["plantation"],
        trellisInstalledArea: json["trellis_installed_area"]?.toDouble(),
        trellisType: json["trellis_type"],
        trellisCount: json["trellis_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "plantation": plantation,
        "trellis_installed_area": trellisInstalledArea,
        "trellis_type": trellisType,
        "trellis_count": trellisCount,
    };
}
