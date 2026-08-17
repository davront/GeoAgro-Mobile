import 'dart:convert';
import 'comment_model.dart';
import 'new_plantation_model.dart' show Coordinate;
import 'plantations_list_model.dart';

EditPlantationModel editPlantationModelFromJson(String str) =>
    EditPlantationModel.fromJson(json.decode(str));

/// Safely parses a value to bool, handling bool, int (0/1), and String ("true"/"false").
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return null;
}

String editPlantationModelToJson(EditPlantationModel data) =>
    json.encode(data.toJson());

class EditPlantationModel {
  int? id;
  int? gardenEstablishedYear;
  // Some backends may return plantation_type at the root in addition to
  // or instead of the nested `types.plantation_type`. Keep a fallback field.
  int? plantationType;
  Types? types;
  double? totalArea;
  double? irrigationArea;
  double? chegaraArea; // Граничная площадь (Chegara maydon)
  double? fertilityScore;
  int? landType;
  bool? isFertile;
  bool? isChecked;
  bool? isRejected;
  bool? isDeleting;
  int? irrigationSystemsCount;
  String? qarorRaqami;
  int? qarorType;
  List<Investment>? investments;
  List<Reservoir>? reservoirs;
  List<Trellise>? trellises;
  List<FruitArea>? fruitAreas;
  List<String>? images;
  List<Subsidy>? subsidies;
  double? notUsableArea;
  double? emptyArea;
  List<String>? konturNumber;
  List<Coordinate>? coordinates;
  List<Comment>? comments;
  List<ModerationComment>? moderationComments;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  String? moderatedAt;
  int? moderatedBy;
  String? dealNumber;
  String? dealFile; // URL уже загруженного файла (сервер вернул в GET)
  String? resolutionNumber;
  String? resolutionFile; // URL уже загруженного файла (сервер вернул в GET)

  EditPlantationModel({
    this.id,
    this.gardenEstablishedYear,
    this.plantationType,
    this.types,
    this.totalArea,
    this.irrigationArea,
    this.chegaraArea,
    this.fertilityScore,
    this.landType,
    this.isFertile,
    this.isChecked,
    this.isRejected,
    this.isDeleting,
    this.irrigationSystemsCount,
    this.qarorRaqami,
    this.qarorType,
    this.investments,
    this.reservoirs,
    this.trellises,
    this.fruitAreas,
    this.images,
    this.subsidies,
    this.notUsableArea,
    this.emptyArea,
    this.konturNumber,
    this.coordinates,
    this.comments,
    this.moderationComments,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.moderatedAt,
    this.moderatedBy,
    this.dealNumber,
    this.dealFile,
    this.resolutionNumber,
    this.resolutionFile,
  });

  EditPlantationModel copyWith({
    int? id,
    int? gardenEstablishedYear,
    int? plantationType,
    Types? types,
    double? totalArea,
    double? irrigationArea,
    double? chegaraArea,
    double? fertilityScore,
    int? landType,
    bool? isFertile,
    bool? isChecked,
    bool? isRejected,
    bool? isDeleting,
    int? irrigationSystemsCount,
    String? qarorRaqami,
    int? qarorType,
    List<Investment>? investments,
    List<Reservoir>? reservoirs,
    List<Trellise>? trellises,
    List<FruitArea>? fruitAreas,
    List<String>? images,
    List<Subsidy>? subsidies,
    double? notUsableArea,
    double? emptyArea,
    List<String>? konturNumber,
    List<Comment>? comments,
    List<ModerationComment>? moderationComments,
    String? createdAt,
    String? updatedAt,
    int? createdBy,
    String? moderatedAt,
    int? moderatedBy,
    String? dealNumber,
    String? dealFile,
    String? resolutionNumber,
    String? resolutionFile,
  }) =>
      EditPlantationModel(
        id: id ?? this.id,
        gardenEstablishedYear:
            gardenEstablishedYear ?? this.gardenEstablishedYear,
        plantationType: plantationType ?? this.plantationType,
        types: types ?? this.types,
        totalArea: totalArea ?? this.totalArea,
        irrigationArea: irrigationArea ?? this.irrigationArea,
        chegaraArea: chegaraArea ?? this.chegaraArea,
        fertilityScore: fertilityScore ?? this.fertilityScore,
        landType: landType ?? this.landType,
        isFertile: isFertile ?? this.isFertile,
        isChecked: isChecked ?? this.isChecked,
        isRejected: isRejected ?? this.isRejected,
        isDeleting: isDeleting ?? this.isDeleting,
        irrigationSystemsCount:
            irrigationSystemsCount ?? this.irrigationSystemsCount,
        qarorRaqami: qarorRaqami ?? this.qarorRaqami,
        qarorType: qarorType ?? this.qarorType,
        investments: investments ?? this.investments,
        reservoirs: reservoirs ?? this.reservoirs,
        trellises: trellises ?? this.trellises,
        fruitAreas: fruitAreas ?? this.fruitAreas,
        images: images ?? this.images,
        subsidies: subsidies ?? this.subsidies,
        notUsableArea: notUsableArea ?? this.notUsableArea,
        emptyArea: emptyArea ?? this.emptyArea,
        konturNumber: konturNumber ?? this.konturNumber,
        comments: comments ?? this.comments,
        moderationComments: moderationComments ?? this.moderationComments,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        createdBy: createdBy ?? this.createdBy,
        moderatedAt: moderatedAt ?? this.moderatedAt,
        moderatedBy: moderatedBy ?? this.moderatedBy,
        dealNumber: dealNumber ?? this.dealNumber,
        dealFile: dealFile ?? this.dealFile,
        resolutionNumber: resolutionNumber ?? this.resolutionNumber,
        resolutionFile: resolutionFile ?? this.resolutionFile,
      );

  factory EditPlantationModel.fromJson(Map<String, dynamic> json) =>
      EditPlantationModel(
        id: json["id"],
        gardenEstablishedYear: json["garden_established_year"],
        plantationType: json["plantation_type"],
        types: json["types"] == null ? null : Types.fromJson(json["types"]),
        totalArea: json["total_area"]?.toDouble(),
        irrigationArea: json["irrigation_area"]?.toDouble(),
        chegaraArea: json["chegara_area"]?.toDouble(),
        fertilityScore: json["fertility_score"]?.toDouble(),
        landType: json["land_type"],
        isFertile: json["is_fertile"],
        isChecked: _parseBool(json["is_checked"]),
        isRejected: _parseBool(json["is_rejected"]) ?? false,
        isDeleting: _parseBool(json["is_deleting"]) ?? false,
        irrigationSystemsCount: json["irrigation_systems_count"],
        qarorRaqami: json["qaror_raqami"],
        qarorType: json["qaror_type"],
        investments: json["investments"] == null
            ? []
            : List<Investment>.from(
                json["investments"]!.map((x) => Investment.fromJson(x))),
        reservoirs: json["reservoirs"] == null
            ? []
            : List<Reservoir>.from(
                json["reservoirs"]!.map((x) => Reservoir.fromJson(x))),
        trellises: json["trellises"] == null
            ? []
            : List<Trellise>.from(
                json["trellises"]!.map((x) => Trellise.fromJson(x))),
        fruitAreas: json["fruit_areas"] == null
            ? []
            : List<FruitArea>.from(
                json["fruit_areas"]!.map((x) => FruitArea.fromJson(x))),
        images: (() {
          final imgs = json["images"];
          if (imgs == null) return <String>[];
          if (imgs is List) {
            return imgs
                .map((e) {
                  if (e is Map<String, dynamic>) {
                    final raw = (e["image_url"] ?? e["image"])?.toString();
                    if (raw == null) return null;
                    return raw.startsWith('http://')
                        ? raw.replaceFirst('http://', 'https://')
                        : raw;
                  }
                  final s = e?.toString();
                  if (s == null) return null;
                  return s.startsWith('http://')
                      ? s.replaceFirst('http://', 'https://')
                      : s;
                })
                .whereType<String>()
                .toList();
          }
          return <String>[];
        })(),
        subsidies: json["subsidies"] == null
            ? []
            : List<Subsidy>.from(
                json["subsidies"]!.map((x) => Subsidy.fromJson(x))),
        notUsableArea: json["not_usable_area"]?.toDouble(),
        emptyArea: json["empty_area"]?.toDouble(),
        konturNumber: json["kontur_number"] == null
            ? null
            : List<String>.from(json["kontur_number"].map((x) => x.toString())),
        coordinates: json["coordinates"] == null
            ? null
            : List<Coordinate>.from((json["coordinates"] as List)
                .map((x) => Coordinate.fromJson(x))),
        comments: json["comments"] == null
            ? null
            : List<Comment>.from((json["comments"] as List<dynamic>)
                .map((x) => Comment.fromJson(x as Map<String, dynamic>))),
        moderationComments: (() {
          try {
            if (json["moderation_comment"] != null &&
                json["moderation_comment"] is List) {
              final list = json["moderation_comment"] as List<dynamic>;
              if (list.isNotEmpty) {
                return list
                    .map((x) {
                      try {
                        return ModerationComment.fromJson(
                            x as Map<String, dynamic>);
                      } catch (e) {
                        return null;
                      }
                    })
                    .whereType<ModerationComment>()
                    .toList();
              }
            }
          } catch (e) {
            // If parsing fails, just leave it as null
          }
          return null;
        })(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        createdBy: json["created_by"],
        moderatedAt: json["moderated_at"]?.toString(),
        moderatedBy: json["moderated_by"],
        dealNumber: json["deal_number"],
        dealFile: json["deal_file"]?.toString(),
        resolutionNumber: json["resolution_number"],
        resolutionFile: json["resolution_file"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "garden_established_year": gardenEstablishedYear,
        "plantation_type": plantationType,
        "types": types?.toJson(),
        "total_area": totalArea,
        "irrigation_area": irrigationArea,
        "chegara_area": chegaraArea,
        "fertility_score": fertilityScore,
        "land_type": landType,
        "is_fertile": isFertile,
        "is_checked": isChecked,
        "is_rejected": isRejected,
        "is_deleting": isDeleting,
        "irrigation_systems_count": irrigationSystemsCount,
        "qaror_raqami": qarorRaqami,
        "qaror_type": qarorType,
        "investments": investments == null
            ? []
            : List<dynamic>.from(investments!.map((x) => x.toJson())),
        "reservoirs": reservoirs == null
            ? []
            : List<dynamic>.from(reservoirs!.map((x) => x.toJson())),
        "trellises": trellises == null
            ? []
            : List<dynamic>.from(trellises!.map((x) => x.toJson())),
        "fruit_areas": fruitAreas == null
            ? []
            : List<dynamic>.from(fruitAreas!.map((x) => x.toJson())),
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "subsidies": subsidies == null
            ? []
            : List<dynamic>.from(subsidies!.map((x) => x.toJson())),
        "not_usable_area": notUsableArea,
        "empty_area": emptyArea,
        "kontur_number": konturNumber == null
            ? []
            : List<dynamic>.from(konturNumber!.map((x) => x)),
        "comments": comments == null
            ? []
            : List<dynamic>.from(comments!.map((x) => x.toJson())),
        "moderation_comment": moderationComments == null
            ? null
            : List<dynamic>.from(moderationComments!.map((x) => x.toJson())),
        "created_at": createdAt,
        "updated_at": updatedAt,
        "created_by": createdBy,
        "moderated_at": moderatedAt,
        "moderated_by": moderatedBy,
        "deal_number": dealNumber,
        "resolution_number": resolutionNumber,
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
  double? weight;
  bool? fenced;
  double? hundredweight;
  dynamic kochatSoni;
  bool? iqtisodiysamarasiz;
  double? economicInefficientArea;

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
    this.weight,
    this.fenced,
    this.hundredweight,
    this.kochatSoni,
    this.iqtisodiysamarasiz,
    this.economicInefficientArea,
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
    double? weight,
    bool? fenced,
    double? hundredweight,
    dynamic kochatSoni,
    bool? iqtisodiysamarasiz,
    double? economicInefficientArea,
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
        weight: weight ?? this.weight,
        fenced: fenced ?? this.fenced,
        hundredweight: hundredweight ?? this.hundredweight,
        kochatSoni: kochatSoni ?? this.kochatSoni,
        iqtisodiysamarasiz: iqtisodiysamarasiz ?? this.iqtisodiysamarasiz,
        economicInefficientArea:
            economicInefficientArea ?? this.economicInefficientArea,
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
      fruitId = json["fruit"] is int
          ? json["fruit"]
          : int.tryParse(json["fruit"]?.toString() ?? "");
      fruitName = json["fruit_name"] ?? json["fruit"]?.toString();
    }

    // Обрабатываем поле variety
    if (json["variety"] is Map<String, dynamic>) {
      varietyId = json["variety"]["id"];
      varietyName = json["variety"]["name"];
    } else {
      varietyId = json["variety"] is int
          ? json["variety"]
          : int.tryParse(json["variety"]?.toString() ?? "");
      varietyName = json["variety_name"] ?? json["variety"]?.toString();
    }

    // Обрабатываем поле rootstock
    if (json["rootstock"] is Map<String, dynamic>) {
      rootstockId = json["rootstock"]["id"];
      rootstockName = json["rootstock"]["name"];
    } else {
      rootstockId = json["rootstock"] is int
          ? json["rootstock"]
          : int.tryParse(json["rootstock"]?.toString() ?? "");
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
      weight: json["weight"]?.toDouble(),
      fenced: json["fenced"],
      hundredweight: json["hundredweight"]?.toDouble(),
      kochatSoni: json["kochat_soni"],
      iqtisodiysamarasiz: json["iqtisodiy_samarasiz"],
      economicInefficientArea: json["economic_inefficient_area"]?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "fruit": fruit,
        "variety": variety,
        "rootstock": rootstock,
        "planted_year": plantedYear,
        "area": area,
        "schema": schema,
        "weight": weight,
        "fenced": fenced,
        "hundredweight": hundredweight,
        "kochat_soni": kochatSoni,
        "iqtisodiy_samarasiz": iqtisodiysamarasiz,
        "economic_inefficient_area": economicInefficientArea ?? 0.0,
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
  dynamic reservoirVolume;

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
    dynamic reservoirVolume,
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

class Types {
  int? plantationType;
  int? typeChoice;
  int? subtype;

  Types({
    this.plantationType,
    this.typeChoice,
    this.subtype,
  });

  Types copyWith({
    int? plantationType,
    int? typeChoice,
    int? subtype,
  }) =>
      Types(
        plantationType: plantationType ?? this.plantationType,
        typeChoice: typeChoice ?? this.typeChoice,
        subtype: subtype ?? this.subtype,
      );

  factory Types.fromJson(Map<String, dynamic> json) => Types(
        plantationType: json["plantation_type"],
        typeChoice: json["type_choice"],
        subtype: json["subtype"],
      );

  Map<String, dynamic> toJson() => {
        "plantation_type": plantationType,
        "type_choice": typeChoice,
        "subtype": subtype,
      };
}
