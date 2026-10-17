import 'dart:convert';

TokenModel tokenModelFromJson(String str) => TokenModel.fromJson(json.decode(str));

String tokenModelToJson(TokenModel data) => json.encode(data.toJson());

class TokenModel {
  String access;
  String refresh;

  TokenModel({
    required this.access,
    required this.refresh,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        access: json["access"],
        refresh: json["refresh"],
      );

  Map<String, dynamic> toJson() => {
        "access": access,
        "refresh": refresh,
      };
}
