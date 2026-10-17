// To parse this JSON data, do
//
//     final farmerListModel = farmerListModelFromJson(jsonString);

import 'dart:convert';

FarmerListModel farmerListModelFromJson(String str) => FarmerListModel.fromJson(json.decode(str));

String farmerListModelToJson(FarmerListModel data) => json.encode(data.toJson());

class FarmerListModel {
    int? count;
    String? next;
    String? previous;
    List<FarmerModel>? results;

    FarmerListModel({
        this.count,
        this.next,
        this.previous,
        this.results,
    });

    factory FarmerListModel.fromJson(Map<String, dynamic> json) => FarmerListModel(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: json["results"] == null ? [] : List<FarmerModel>.from(json["results"]!.map((x) => FarmerModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": results == null ? [] : List<FarmerModel>.from(results!.map((x) => x.toJson())),
    };
}

class FarmerModel {
    int? id;
    String? name;
    String? founderName;
    String? directorName;
    String? phoneNumber;
    String? address;
    String? email;
    int? inn;
    int? establishedYear;
    int? district;
    CreatedBy? createdBy;

    FarmerModel({
        this.id,
        this.name,
        this.founderName,
        this.directorName,
        this.phoneNumber,
        this.address,
        this.email,
        this.inn,
        this.establishedYear,
        this.district,
        this.createdBy,
    });

    factory FarmerModel.fromJson(Map<String, dynamic> json) {
        CreatedBy? createdBy;
        if (json['created_by'] != null && json['created_by'] is Map<String, dynamic>) {
            createdBy = CreatedBy.fromJson(json['created_by'] as Map<String, dynamic>);
        }
        
        return FarmerModel(
            id: json["id"],
            name: json["name"],
            founderName: json["founder_name"],
            directorName: json["director_name"],
            phoneNumber: json["phone_number"],
            address: json["address"],
            email: json["email"],
            inn: json["inn"],
            establishedYear: json["established_year"],
            district: json["district"],
            createdBy: createdBy,
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "founder_name": founderName,
        "director_name": directorName,
        "phone_number": phoneNumber,
        "address": address,
        "email": email,
        "inn": inn,
        "established_year": establishedYear,
        "district": district,
        "created_by": createdBy?.toJson(),
    };
}

class CreatedBy {
    final int id;
    final String username;
    final String? firstName;
    final String? lastName;

    CreatedBy({
        required this.id,
        required this.username,
        this.firstName,
        this.lastName,
    });

    factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["id"] as int,
        username: json["username"] as String,
        firstName: json["first_name"] as String?,
        lastName: json["last_name"] as String?,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "first_name": firstName,
        "last_name": lastName,
    };

    String get fullName {
        if (firstName != null && lastName != null) {
            return "$firstName $lastName".trim();
        } else if (firstName != null) {
            return firstName!;
        } else if (lastName != null) {
            return lastName!;
        }
        return username;
    }
}
