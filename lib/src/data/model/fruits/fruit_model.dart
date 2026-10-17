import 'dart:convert';

List<FruitModel> fruitModelFromJson(String str) =>
    List<FruitModel>.from(json.decode(str).map((x) => FruitModel.fromJson(x)));

String fruitModelToJson(List<FruitModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FruitModel {
  int id;
  String name;

  FruitModel({
    required this.id,
    required this.name,
  });

  FruitModel copyWith({
    int? id,
    String? name,
  }) =>
      FruitModel(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory FruitModel.fromJson(Map<String, dynamic> json) => FruitModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
