import '../model/response/api_response.dart';
import '../model/farmer/create_fermer_model.dart';

abstract class AppRepo {
  // AppRepo._();

  Future<ApiResponse> login(
      {required String username, required String password});

  Future<String?> getPlantationsList({int? page, String? search});

  Future<String?> deletePlantationModel(
      {required int id, required Map<String, dynamic> model});

  Future<String?> deletePlantation({required int id, String? reason});

  Future<String?> getPlantationDetail({required int id});

  Future<String?> getRelatedPlantationsMap(int plantationId);

  Future<String?> getNearbyPlantations(
      {required double latitude,
      required double longitude,
      double radius = 1000});

  Future<String?> getUserPlantationsForMap();

  Future<String?> getFermersList({int? page});

  Future<String?> searchFarmers({required int inn});

  Future<String?> getFarmerPlantations({required int farmerInn});

  Future<ApiResponse> postNewFermer({required CreateFermerModel fermer});

  Future<ApiResponse> updateFarmer(
      {required int id, required Map<String, dynamic> data});

  Future<String?> getFruits();

  Future<String?> getFruitsVerity({required String verity});

  Future<String?> getFruitsRootstocks({required String rootstocks});

  Future<ApiResponse> postCreatePlantationWithImages(
      {required Map<String, dynamic> body,
      required List<String> image,
      Map<String, String>? namedFiles});

  Future<ApiResponse> editPlantation(
      {required int id, required Map<String, dynamic> body});

  Future<String?> editImage({required int id, required List<String> images});

  // Images per-endpoint operations
  Future<String?> getPlantationImages({required int id});
  Future<ApiResponse> postPlantationImage(
      {required int id, required String filePath});
  Future<String?> deletePlantationImage(
      {required int plantationId, required int imageId});

  Future<String?> getUserInfo();

  Future<String?> getFarmerById(int farmerId);

  Future<String?> getFarmersStatistics({
    int? districtId,
    int? regionId,
    String? status,
  });

  Future<String?> getRegionDistrictsStatistics(int regionId);

  // ==== Device tokens (FCM) ====
  Future<String?> registerDeviceToken({
    required String token,
    required String platform,
    String? appVersion,
  });
  Future<String?> removeDeviceToken({required String token});
  Future<String?> getDeviceTokens();

  // ==== Notifications ====
  Future<String?> getNotifications(
      {int limit = 20, int offset = 0, bool? unreadOnly, String? type});
  Future<String?> getUnreadNotificationsCount();
  Future<String?> markNotificationsAsRead(
      {bool markAll = false, List<int>? ids});
  Future<String?> markNotificationAsRead({required int id});
  Future<String?> deleteNotification({required int id});

  // ==== Comments ====
  Future<String?> getPlantationComments({required int plantationId});
  Future<ApiResponse> addPlantationComment(
      {required int plantationId,
      required String body,
      bool isModeration = false});

  // ==== Users ====
  Future<String?> getUserById({required int id});
}
