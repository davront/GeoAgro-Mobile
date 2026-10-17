import 'dart:convert';

List<FruitRootstocksModel> fruitRootstocksModelFromJson(String str) =>
    List<FruitRootstocksModel>.from(
        json.decode(str).map((x) => FruitRootstocksModel.fromJson(x)));

String fruitRootstocksModelToJson(List<FruitRootstocksModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FruitRootstocksModel {
  int id;
  String name;
  int fruit;

  FruitRootstocksModel({
    required this.id,
    required this.name,
    required this.fruit,
  });

  FruitRootstocksModel copyWith({
    int? id,
    String? name,
    int? fruit,
  }) =>
      FruitRootstocksModel(
        id: id ?? this.id,
        name: name ?? this.name,
        fruit: fruit ?? this.fruit,
      );

  factory FruitRootstocksModel.fromJson(Map<String, dynamic> json) =>
      FruitRootstocksModel(
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
