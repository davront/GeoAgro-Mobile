import 'dart:convert';

// Бэк отдаёт /api/common/fruits/{id}/varieties/ либо голым массивом, либо
// пагинированным {"count":..,"results":[...]} — тот же формат, что и
// FarmerListModel/PlantationsListModel. Раньше парсер жёстко ждал массив
// и падал на пагинированном ответе, из-за чего "Meva navi" оставался
// пустым для всех фруктов, хотя "Meva turi" (fruits list, не
// пагинированный) грузился нормально.
List<FruitVarietyModel> fruitVarietyModelFromJson(String str) {
  final decoded = json.decode(str);
  final list = decoded is Map<String, dynamic>
      ? decoded['results'] as List<dynamic>? ?? const []
      : decoded as List<dynamic>;
  return List<FruitVarietyModel>.from(
      list.map((x) => FruitVarietyModel.fromJson(x)));
}

String fruitVarietyModelToJson(List<FruitVarietyModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FruitVarietyModel {
  int id;
  String name;
  int fruit;

  FruitVarietyModel({
    required this.id,
    required this.name,
    required this.fruit,
  });

  FruitVarietyModel copyWith({
    int? id,
    String? name,
    int? fruit,
  }) =>
      FruitVarietyModel(
        id: id ?? this.id,
        name: name ?? this.name,
        fruit: fruit ?? this.fruit,
      );

  factory FruitVarietyModel.fromJson(Map<String, dynamic> json) =>
      FruitVarietyModel(
        id: json["id"],
        name: json["name"],
        fruit: json["fruit"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "fruit": fruit,
      };
}
