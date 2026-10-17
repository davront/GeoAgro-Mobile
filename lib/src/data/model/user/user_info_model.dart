class UserInfoModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String lastLogin;
  final int district;
  final int districtId;
  final String districtName;
  final int regionId;
  final String phoneNumber;
  final bool isHeadofRegion;
  final bool isSuperuser;
  final String? flutterVersion; // Версия приложения с сервера
  final bool
      isSpecialUser; // Специальный пользователь (может загружать фото с галереи)
  final double? limitKm; // Лимит координат в км (null = дефолт 1 км)

  UserInfoModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.lastLogin,
    required this.district,
    required this.districtId,
    required this.districtName,
    required this.regionId,
    required this.phoneNumber,
    required this.isHeadofRegion,
    required this.isSuperuser,
    this.flutterVersion,
    this.isSpecialUser = false, // По умолчанию false
    this.limitKm, // Nullable - если null, используется дефолт 1 км
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      lastLogin: json['last_login'] ?? '',
      district: json['district'] ?? 0,
      districtId: json['district_id'] ?? 0,
      districtName: json['district_name'] ?? '',
      regionId: json['region_id'] ?? 0,
      phoneNumber: json['phone_number'] ?? '',
      isHeadofRegion: json['is_headof_region'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      flutterVersion: json['flutter_version']?.toString(),
      isSpecialUser: json['is_specialuser'] ?? false,
      limitKm: json['limit_km']?.toDouble(),
    );
  }

  // Получить отображаемое имя пользователя
  String get displayName {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '${firstName.trim()} ${lastName.trim()}'.trim();
    }
    return username;
  }
}
