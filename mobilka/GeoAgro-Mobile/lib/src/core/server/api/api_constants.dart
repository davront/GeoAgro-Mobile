final class ApiConst {
  const ApiConst._();

  static const Duration connectionTimeout = Duration(minutes: 2);
  static const Duration sendTimeout = Duration(minutes: 2);
  static const Duration receiveTimeout = Duration(minutes: 2);

  static const String baseUrl = "https://api.geoagro.uz";

  static String apiUpdatePlantation(int id) =>
      '/api/plantations/$id/mobile-update/';
  static String apiUpdateImage(int id) => '/api/plantations/$id/images/';
  static String apiLegacyImagesUpdate(int id) =>
      '/api/plantations/$id/images/update/';
  static String apiDeleteImage(int plantationId, int imageId) =>
      '/api/plantations/$plantationId/images/$imageId/';
  static String apiDeletePlantation(int id) => '/api/plantations/$id/';
  // Тот же URL, что apiDeletePlantation — RetrieveDestroyAPIView, единственный
  // endpoint, принимающий multipart для deal_file/resolution_file. Отдельное
  // имя для ясности на call site (upload, не delete).
  static String apiPlantationFiles(int id) => '/api/plantations/$id/';

  static const String apiLogin = "/api/login/";
  static const String apiPlantations = "/api/plantations/";
  static const String apiPlantationsForme = "/api/plantations/forme/";
  static const String apiPlantationsFormeMap = "/api/plantations/forme/map/";
  static const String apiPlantationsFormeRejected =
      "/api/plantations/forme/rejected/";
  static const String apiPlantationsFormeApproved =
      "/api/plantations/forme/approved/";
  static const String apiPlantationsPending = "/api/plantations/forme/pending/";
  static const String apiCreatePlantation = "/api/plantations/create/";
  static const String apiGetRegions = "/api/regions/";
  static const String apiGetUserInfo = "/api/users/profile/";
  static const String apiGetDistrcts = "/api/common/districts/";
  static const String apiFermers = "/api/farmers/";
  static String apiUpdateFarmer(int id) => "/api/farmers/$id/";
  static String apiFarmerPlantations({required int farmerInn}) =>
      "/api/mymap/plantations/?farmer_inn=$farmerInn";
  static const String apiFruits = "/api/common/fruits/";
  static String apiFruitsVariety(int fruitId) =>
      "/api/common/fruits/$fruitId/varieties/";
  static const String apiFruitsRootstocks = "/api/common/rootstocks/";
  static const String apiPlantationsUpdate = "/api/plantations/1/";
  static const String apiFarmersStatistics = "/api/statistics/farmers";
  static const String apiNotifications = "/api/notifications/";
  static const String apiNotificationsUnreadCount =
      "/api/notifications/unread-count/";
  static const String apiDeviceTokens = "/api/device-tokens/";
  static String apiDeviceTokenByToken(String token) =>
      "/api/device-tokens/$token/";

  // Comments
  static String apiPlantationComments(int plantationId) =>
      '/api/plantations/$plantationId/comments/';

  // Users
  static const String apiUsers = "/api/users/";
  static String apiUserById(int id) => "/api/users/$id/";

  // Districts breakdown within a region (used to surface only the
  // caller's own district, not the whole region).
  static String apiRegionDistrictsStatistics(int regionId) =>
      "/api/statistics/regions/$regionId/pending/";
}

final class ApiParams {
  const ApiParams._();

  static Map<String, dynamic> cabinetSmsCheckParams(
          {required String phone, required String code}) =>
      <String, dynamic>{"phone": phone, "code": code};

  static Map<String, dynamic> pageParams({required int page}) =>
      <String, dynamic>{"page": page};

  static Map<String, dynamic> searchFarmersParam({required int inn}) =>
      <String, dynamic>{"inn": inn};

  static Map<String, dynamic> emptyParams() => <String, dynamic>{};

  static Map<String, dynamic> farmersStatisticsParams({
    int? districtId,
    int? regionId,
    String? status,
  }) {
    final params = <String, dynamic>{};
    if (districtId != null && districtId > 0)
      params["district_id"] = districtId;
    if (regionId != null && regionId > 0) params["region_id"] = regionId;
    if (status != null && status.isNotEmpty && status != "all") {
      params["status"] = status;
    }
    return params;
  }

  static Map<String, dynamic> pageWithSearchParams(
      {required int page, String? search}) {
    // If search query is provided, DO NOT send page param
    // Backend will return all matches or handle pagination internally for search
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      params["search"] = search;
    } else {
      params["page"] = page;
    }
    return params;
  }

  static Map<String, dynamic> queryParams(Map<String, String> params) =>
      Map<String, dynamic>.from(params);

  // Notifications
  static Map<String, dynamic> notificationsListParams(
      {int limit = 20, int offset = 0, bool? unreadOnly, String? type}) {
    final params = <String, dynamic>{
      "limit": limit,
      "offset": offset,
    };
    if (unreadOnly != null) params["unread_only"] = unreadOnly;
    if (type != null && type.isNotEmpty) params["type"] = type;
    return params;
  }
}
