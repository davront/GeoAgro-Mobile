import 'dart:convert';
import 'package:flutter/foundation.dart';

PlantationsListModel plantationsListModelFromJson(String str) => PlantationsListModel.fromJson(json.decode(str));

String plantationsListModelToJson(PlantationsListModel data) => json.encode(data.toJson());

class PlantationsListModel {
  final int? count;
  final String? next;
  final String? previous;
  final List<Result>? results;

  PlantationsListModel({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory PlantationsListModel.fromJson(Map<String, dynamic> json) => PlantationsListModel(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

// class Result {
//   final int? id;
//   final int? gardenEstablishedYear;
//   final String? districtName;
//   final String? regionName;
//   final double? totalArea;
//   final bool? isDeleting;
//   final bool? isChecked;
//   final dynamic prevData;

//   Result({
//     this.id,
//     this.gardenEstablishedYear,
//     this.districtName,
//     this.regionName,
//     this.totalArea,
//     this.isDeleting,
//     this.isChecked,
//     this.prevData,
//   });

//   factory Result.fromJson(Map<String, dynamic> json) => Result(
//         id: json["id"],
//         gardenEstablishedYear: json["garden_established_year"],
//         districtName: json["district_name"],
//         regionName: json["region_name"],
//         totalArea: json["total_area"],
//         isDeleting: json["is_deleting"],
//         isChecked: json["is_checked"],
//         prevData: json["prev_data"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "garden_established_year": gardenEstablishedYear,
//         "district_name": districtName,
//         "region_name": regionName,
//         "total_area": totalArea,
//         "is_deleting": isDeleting,
//         "is_checked": isChecked,
//         "prev_data": prevData,
//       };
// }

class Result {
  int? id;
  District? district;
  int? farmer;
  String? farmerName; // Добавляем имя фермера
  int? farmerInn; // ИНН фермера
  int? gardenEstablishedYear;
  double? totalArea;
  double? chegaraArea; // Граничная площадь (Chegara maydon)
  int? landType;
  bool? isFertile;
  String? createdAt;
  bool? isChecked;
  bool? isRejected;
  List<ModerationComment>? moderationComments;
  int? createdById;
  String? createdByUsername;

  Result({
    this.id,
    this.district,
    this.farmer,
    this.farmerName,
    this.farmerInn,
    this.gardenEstablishedYear,
    this.totalArea,
    this.chegaraArea,
    this.landType,
    this.isFertile,
    this.createdAt,
    this.isChecked,
    this.isRejected,
    this.moderationComments,
    this.createdById,
    this.createdByUsername,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    List<ModerationComment>? moderationComments;
    try {
      if (json["moderation_comment"] != null && json["moderation_comment"] is List) {
        final list = json["moderation_comment"] as List<dynamic>;
        if (list.isNotEmpty) {
          moderationComments = list
              .map((x) {
                try {
                  return ModerationComment.fromJson(x as Map<String, dynamic>);
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
      moderationComments = null;
    }

    // Отладочная информация для is_rejected и is_checked
    final rawIsRejected = json["is_rejected"];
    final rawIsChecked = json["is_checked"];
    bool? isRejected;
    bool? isChecked;
    
    // Парсим is_rejected
    if (rawIsRejected == null) {
      isRejected = false;
    } else if (rawIsRejected is bool) {
      isRejected = rawIsRejected;
    } else if (rawIsRejected is String) {
      isRejected = rawIsRejected.toLowerCase() == 'true';
    } else if (rawIsRejected is int) {
      isRejected = rawIsRejected != 0;
    } else {
      isRejected = false;
    }
    
    // Парсим is_checked
    if (rawIsChecked == null) {
      isChecked = false;
    } else if (rawIsChecked is bool) {
      isChecked = rawIsChecked;
    } else if (rawIsChecked is String) {
      isChecked = rawIsChecked.toLowerCase() == 'true';
    } else if (rawIsChecked is int) {
      isChecked = rawIsChecked != 0;
    } else {
      isChecked = false;
    }
    
    // Логируем для отладки
    if (json["id"] != null) {
      debugPrint('Result ${json["id"]}: is_checked=$rawIsChecked (parsed: $isChecked), is_rejected=$rawIsRejected (parsed: $isRejected)');
    }

    return Result(
      id: json["id"],
      district: json["district"] == null ? null : District.fromJson(json["district"]),
      farmer: json["farmer"],
      farmerName: json["farmer_name"],
      farmerInn: json["farmer_inn"] ?? json["inn"],
      gardenEstablishedYear: json["garden_established_year"],
      totalArea: json["total_area"]?.toDouble(),
      chegaraArea: json["chegara_area"]?.toDouble(),
      landType: json["land_type"],
      isFertile: json["is_fertile"],
      createdAt: json["created_at"],
      isChecked: isChecked,
      isRejected: isRejected,
      moderationComments: moderationComments,
      createdById: (json["created_by"] is Map<String, dynamic>) ? json["created_by"]["id"] as int? : null,
      createdByUsername: (json["created_by"] is Map<String, dynamic>) ? json["created_by"]["username"] as String? : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "district": district?.toJson(),
        "farmer": farmer,
        "farmer_name": farmerName, // Добавляем в JSON
        "farmer_inn": farmerInn,
        "garden_established_year": gardenEstablishedYear,
        "total_area": totalArea,
        "chegara_area": chegaraArea,
        "land_type": landType,
        "is_fertile": isFertile,
        "created_at": createdAt,
        "is_checked": isChecked,
        "is_rejected": isRejected,
        "moderation_comment": moderationComments == null
            ? null
            : List<dynamic>.from(moderationComments!.map((x) => x.toJson())),
        "created_by": {
          "id": createdById,
          "username": createdByUsername,
        },
      };
}

class District {
  String? name;
  int? region;

  District({
    this.name,
    this.region,
  });

  factory District.fromJson(Map<String, dynamic> json) => District(
        name: json["name"],
        region: json["region"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "region": region,
      };
}

class ModerationComment {
  final int? id;
  final String? text;
  final String? image;

  ModerationComment({this.id, this.text, this.image});

  factory ModerationComment.fromJson(Map<String, dynamic> json) => ModerationComment(
        id: json["id"],
        text: json["text"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "image": image,
      };
}
