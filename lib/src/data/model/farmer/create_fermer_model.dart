class CreateFermerModel {
  final String name;
  final String founderName;
  final String directorName;
  final String phoneNumber;
  final String address;
  final String inn;
  final int establishedYear;
  final String district;

  CreateFermerModel({
    required this.name,
    required this.founderName,
    required this.directorName,
    required this.phoneNumber,
    required this.address,
    required this.inn,
    required this.establishedYear,
    required this.district,
  });

  factory CreateFermerModel.fromJson(Map<String, dynamic> json) => CreateFermerModel(
        name: json["name"],
        founderName: json["founder_name"],
        directorName: json["director_name"],
        phoneNumber: json["phone_number"],
        address: json["address"],
        inn: json["inn"],
        establishedYear: json["established_year"],
        district : json["district"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "founder_name": founderName,
        "director_name": directorName,
        "phone_number": phoneNumber,
        "address": address,
        "inn": inn,
        "established_year": establishedYear,
        "district" : district,
      };
}
