import "dart:convert";
import "dart:developer";

import "package:dio/dio.dart";
import "package:flutter/material.dart";

import "app_repository.dart";
import "../../core/server/api/api.dart";
import "../../core/utils/dio_error_utils.dart";
import "../model/response/api_response.dart";
import "../../core/server/api/api_constants.dart";
import "../model/farmer/create_fermer_model.dart";
import '../../core/storage/app_storage.dart';
import '../../core/server/api/api_service_v2.dart';
// Removed unused import: '../../core/setting/setup.dart'

class AppRepositoryImpl implements AppRepo {
  const AppRepositoryImpl._();

  static final _inner = AppRepositoryImpl._();

  factory AppRepositoryImpl() => _inner;

  /// Last error message produced by a backend call. VMs that get `null`
  /// from a method can read this to surface the real reason to the user.
  static String? lastErrorMessage;

  static void _recordError(Object e) {
    if (e is DioException) {
      lastErrorMessage = DioErrorUtils.message(e);
    } else {
      lastErrorMessage = DioErrorUtils.messageFromAny(e);
    }
  }

  static void _clearError() => lastErrorMessage = null;

  /// Login method
  @override
  Future<ApiResponse> login(
      {required String username, required String password}) async {
    try {
      final response = await ApiService.post(
          ApiConst.apiLogin, {"username": username, "password": password});

      // Persist username for later lookup
      await AppStorage.$write(key: StorageKey.username, value: username);
      return response;
    } catch (e) {
      return ApiResponse(
          statusCode: 500,
          data: {"message": "Unexpected error: ${e.toString()}"});
    }
  }

  @override
  Future<String?> getPlantationsList({int? page, String? search}) async {
    _clearError();
    try {
      return await ApiService.get(
        ApiConst.apiPlantationsForme,
        ApiParams.pageWithSearchParams(page: page ?? 1, search: search),
      );
    } catch (e) {
      _recordError(e);
      debugPrint("getPlantationsList error: $e");
      return null;
    }
  }

  /// Delete Plantation method (for unconfirmed plantations - direct DELETE)
  @override
  Future<String?> deletePlantationModel(
      {required int id, required Map<String, dynamic> model}) async {
    try {
      // Для неподтвержденных плантаций используем прямой DELETE запрос
      final data = await ApiService.delete(ApiConst.apiDeletePlantation(id));
      if (data != null) {
        final dataStr = data.toString();
        // Проверяем, не является ли ответ ошибкой
        try {
          // Пытаемся распарсить как JSON
          final jsonData = jsonDecode(dataStr) as Map<String, dynamic>;
          if (jsonData.containsKey("error")) {
            debugPrint("deletePlantationModel: Error in JSON response: $data");
            return dataStr; // Возвращаем как есть, чтобы ViewModel мог обработать ошибку
          }
          debugPrint("deletePlantationModel: Success JSON response: $data");
          return dataStr;
        } catch (e) {
          // Если не JSON, проверяем строку на наличие ошибок
          final dataLower = dataStr.toLowerCase();
          if (dataLower.contains("error") ||
              dataLower.contains("{error") ||
              dataLower.contains("no plantation") ||
              dataLower.contains("matches") ||
              dataLower.contains("query")) {
            debugPrint(
                "deletePlantationModel: Error detected in string response: $data");
            return dataStr;
          }
          debugPrint(
              "deletePlantationModel: Success response (not JSON): $data");
          return dataStr;
        }
      }
      debugPrint("deletePlantationModel: Response is null");
      return null;
    } on DioException catch (e) {
      debugPrint(
          "deletePlantationModel: DioException - Status: ${e.response?.statusCode}");
      _recordError(e);
      debugPrint(
          "deletePlantationModel: DioException - Data: ${e.response?.data ?? e.message}");

      // Обработка ошибки 403 (Forbidden)
      if (e.response?.statusCode == 403) {
        debugPrint(
            "deletePlantationModel: 403 Forbidden detected, returning FORBIDDEN_403");
        return "FORBIDDEN_403";
      }

      // Если ответ содержит данные, проверяем их на наличие информации об ошибке 403
      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map) {
            final detail = errorData["detail"]?.toString().toLowerCase() ?? "";
            if (detail.contains("forbidden") ||
                detail.contains("ruxsat") ||
                detail.contains("доступ")) {
              debugPrint("deletePlantationModel: 403 detected in error data");
              return "FORBIDDEN_403";
            }
          } else if (errorData is String) {
            final errorStr = errorData.toLowerCase();
            if (errorStr.contains("forbidden") ||
                errorStr.contains("ruxsat") ||
                errorStr.contains("доступ") ||
                errorStr.contains("403")) {
              debugPrint("deletePlantationModel: 403 detected in error string");
              return "FORBIDDEN_403";
            }
          }
        } catch (_) {
          // Игнорируем ошибки парсинга
        }
      }
    } catch (e) {
      debugPrint("deletePlantationModel: Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  /// Delete Plantation permanently (send to moderation)
  @override
  Future<String?> deletePlantation({required int id, String? reason}) async {
    try {
      final body = {
        "moderation_comment": [
          {"text": reason ?? "O'chirish so'rovi", "image": null}
        ]
      };

      final response =
          await ApiService.patch("${ApiConst.apiPlantations}$id/delete/", body);
      if (response != null) {
        debugPrint("deletePlantation: Response status: ${response.statusCode}");
        debugPrint("deletePlantation: Response data: ${response.data}");

        // Проверяем статус код
        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonEncode(response.data);
        } else {
          // Проверяем статус код 403
          if (response.statusCode == 403) {
            debugPrint(
                "deletePlantation: 403 Forbidden detected in response status");
            return "FORBIDDEN_403";
          }

          // Проверяем данные ответа на наличие информации об ошибке 403
          if (response.data != null) {
            try {
              final responseData = response.data;
              if (responseData is Map) {
                final detail =
                    responseData["detail"]?.toString().toLowerCase() ?? "";
                if (detail.contains("forbidden") ||
                    detail.contains("ruxsat") ||
                    detail.contains("доступ")) {
                  debugPrint("deletePlantation: 403 detected in response data");
                  return "FORBIDDEN_403";
                }
              } else if (responseData is String) {
                final responseStr = responseData.toLowerCase();
                if (responseStr.contains("forbidden") ||
                    responseStr.contains("ruxsat") ||
                    responseStr.contains("доступ") ||
                    responseStr.contains("403")) {
                  debugPrint(
                      "deletePlantation: 403 detected in response string");
                  return "FORBIDDEN_403";
                }
              }
            } catch (_) {
              // Игнорируем ошибки парсинга
            }
          }

          // Возвращаем данные об ошибке
          return jsonEncode(response.data);
        }
      }
      debugPrint("deletePlantation: Response is null");
      return null;
    } on DioException catch (e) {
      debugPrint(
          "deletePlantation: DioException - Status: ${e.response?.statusCode}");
      _recordError(e);
      debugPrint(
          "deletePlantation: DioException - Data: ${e.response?.data ?? e.message}");

      // Обработка ошибки 403 (Forbidden)
      if (e.response?.statusCode == 403) {
        debugPrint("deletePlantation: 403 Forbidden detected in DioException");
        return "FORBIDDEN_403";
      }

      // Если ответ содержит данные, проверяем их на наличие информации об ошибке 403
      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map) {
            final detail = errorData["detail"]?.toString().toLowerCase() ?? "";
            if (detail.contains("forbidden") ||
                detail.contains("ruxsat") ||
                detail.contains("доступ")) {
              debugPrint(
                  "deletePlantation: 403 detected in DioException error data");
              return "FORBIDDEN_403";
            }
          } else if (errorData is String) {
            final errorStr = errorData.toLowerCase();
            if (errorStr.contains("forbidden") ||
                errorStr.contains("ruxsat") ||
                errorStr.contains("доступ") ||
                errorStr.contains("403")) {
              debugPrint(
                  "deletePlantation: 403 detected in DioException error string");
              return "FORBIDDEN_403";
            }
          }
        } catch (_) {
          // Игнорируем ошибки парсинга
        }
      }

      // Возвращаем данные об ошибке для обработки в ViewModel
      if (e.response?.data != null) {
        return jsonEncode(e.response!.data);
      }
    } catch (e) {
      debugPrint("deletePlantation: Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  /// Get Plantation detail method
  @override
  Future<String?> getPlantationDetail({required int id}) async {
    try {
      final data = await ApiService.get(
          "${ApiConst.apiPlantations}$id/", ApiParams.emptyParams());
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  /// Get related plantations for map view
  @override
  Future<String?> getRelatedPlantationsMap(int plantationId) async {
    try {
      final data = await ApiService.get(
          "${ApiConst.apiPlantations}$plantationId/related-map/",
          ApiParams.emptyParams());
      if (data == null) {
        debugPrint(
            "Related plantations map response is null for id=$plantationId");
      } else {
        debugPrint(
            "Related plantations map fetched for id=$plantationId (length=${data.length})");
      }
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  /// Get nearby plantations for creating new plantation
  @override
  Future<String?> getNearbyPlantations(
      {required double latitude,
      required double longitude,
      double radius = 1000}) async {
    try {
      final params = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      };

      final data = await ApiService.get(
          "${ApiConst.apiPlantations}nearby/", ApiParams.queryParams(params));
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  /// Get user plantations for map display
  @override
  Future<String?> getUserPlantationsForMap() async {
    try {
      // Используем endpoint для получения плантаций пользователя с координатами
      final data = await ApiService.get(
          ApiConst.apiPlantationsFormeMap, ApiParams.emptyParams());

      debugPrint(
          "User plantations API response: ${data?.substring(0, data.length > 500 ? 500 : data.length)}...");

      return data;
    } on DioException catch (e) {
      debugPrint(
          "Server error in getUserPlantationsForMap: ${e.response?.statusCode} - ${e.response?.data ?? e.message}");
      _recordError(e);
      if (e.response?.statusCode == 401) {
        debugPrint("Authentication error - token may be expired");
      }
    } catch (e) {
      debugPrint("Unexpected error in getUserPlantationsForMap: $e");
      _recordError(e);
    }
    return null;
  }

  // ===== Farmers API =====
  @override
  Future<String?> getFermersList({int? page}) async {
    try {
      debugPrint("🌾 Fetching farmers list, page: ${page ?? 1}");
      final data = await ApiService.get(
        ApiConst.apiFermers,
        ApiParams.pageParams(page: page ?? 1),
      );
      if (data != null) {
        debugPrint("✅ Farmers data received: ${data.length} characters");
      } else {
        debugPrint("❌ Farmers data is null");
      }
      return data;
    } on DioException catch (e) {
      debugPrint(
          "❌ Server error in getFermersList: ${e.response?.statusCode} - ${e.response?.data ?? e.message}");
      _recordError(e);
      debugPrint("❌ Request URL: ${ApiConst.baseUrl}${ApiConst.apiFermers}");
      debugPrint("❌ Request params: ${ApiParams.pageParams(page: page ?? 1)}");
    } catch (e) {
      debugPrint("❌ Unexpected error in getFermersList: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> searchFarmers({required int inn}) async {
    try {
      final data = await ApiService.get(
        ApiConst.apiFermers,
        ApiParams.searchFarmersParam(inn: inn),
      );
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> getFarmerPlantations({required int farmerInn}) async {
    try {
      final url = ApiConst.apiFarmerPlantations(farmerInn: farmerInn);
      final fullUrl = "${ApiConst.baseUrl}$url";
      debugPrint("getFarmerPlantations: Full URL: $fullUrl");
      debugPrint("getFarmerPlantations: farmerInn=$farmerInn");

      final data = await ApiService.get(
        url,
        ApiParams.emptyParams(),
      );

      debugPrint(
          "getFarmerPlantations: Response received: ${data?.substring(0, data.length > 200 ? 200 : data.length)}");
      return data;
    } on DioException catch (e) {
      debugPrint(
          "getFarmerPlantations: Server error: ${e.response?.statusCode}");
      _recordError(e);
      debugPrint(
          "getFarmerPlantations: Error data: ${e.response?.data ?? e.message}");
      debugPrint("getFarmerPlantations: Request URL: ${e.requestOptions.uri}");

      // Обработка ошибки 403 (Forbidden)
      if (e.response?.statusCode == 403) {
        return "FORBIDDEN_403";
      }
    } catch (e) {
      debugPrint("getFarmerPlantations: Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<ApiResponse> updateFarmer(
      {required int id, required Map<String, dynamic> data}) async {
    try {
      debugPrint("UpdateFarmer: Updating farmer $id with data: $data");
      final response =
          await ApiService.putWithResponse(ApiConst.apiUpdateFarmer(id), data);
      debugPrint(
          "UpdateFarmer: Response status: ${response.statusCode}, data: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("UpdateFarmer: Error: $e");
      return ApiResponse(
        statusCode: 500,
        data: {"message": "Unexpected error: ${e.toString()}"},
      );
    }
  }

  @override
  Future<ApiResponse> postNewFermer({required CreateFermerModel fermer}) async {
    try {
      final response =
          await ApiService.post(ApiConst.apiFermers, fermer.toJson());
      return response;
    } catch (e) {
      return ApiResponse(
        statusCode: 500,
        data: {"message": "Unexpected error: ${e.toString()}"},
      );
    }
  }

  // ===== Fruits API =====
  @override
  Future<String?> getFruits() async {
    try {
      final data = await ApiService.get(
        ApiConst.apiFruits,
        ApiParams.emptyParams(),
      );
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
      return "Server error: ${e.response?.statusCode ?? 'Unknown status code'}";
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
      return "Unexpected error: $e";
    }
  }

  @override
  Future<String?> getFruitsVerity({required String verity}) async {
    try {
      final fruitId = int.tryParse(verity) ?? 0;
      final data = await ApiService.get(
        ApiConst.apiFruitsVariety(fruitId),
        ApiParams.emptyParams(),
      );
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
      return "Server error: ${e.response?.statusCode ?? 'Unknown status code'}";
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
      return "Unexpected error: $e";
    }
  }

  @override
  Future<String?> getFruitsRootstocks({required String rootstocks}) async {
    try {
      final url = "${ApiConst.apiFruitsRootstocks}/?fruit=$rootstocks";
      final data = await ApiService.get(
        url,
        ApiParams.emptyParams(),
      );
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
      return "Server error: ${e.response?.statusCode ?? 'Unknown status code'}";
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
      return "Unexpected error: $e";
    }
  }

  // ===== Plantations create/update =====
  @override
  Future<ApiResponse> postCreatePlantationWithImages(
      {required Map<String, dynamic> body, required List<String> image}) async {
    try {
      final response =
          await ApiService.multipart(ApiConst.apiCreatePlantation, body, image);
      return response;
    } catch (e) {
      log("Something went wrong at $e");
      return ApiResponse(
          statusCode: 500,
          data: {"message": "Unexpected error: ${e.toString()}"});
    }
  }

  /// Records the user's GPS point into the plantation's location history.
  ///
  /// The create endpoint is multipart and silently drops `user_location`,
  /// and `mobile-update` accepts only JSON — so the point is delivered as
  /// a separate JSON PATCH after create/edit. Best-effort: a failure must
  /// never block the main flow.
  Future<bool> sendUserLocation({
    required int plantationId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await ApiService.patch(
        ApiConst.apiUpdatePlantation(plantationId),
        {
          "user_location": {"latitude": latitude, "longitude": longitude},
        },
      );
      final ok = response?.statusCode == 200 || response?.statusCode == 201;
      debugPrint(
          "sendUserLocation($plantationId): status=${response?.statusCode}");
      return ok;
    } catch (e) {
      debugPrint("sendUserLocation($plantationId) error: $e");
      return false;
    }
  }

  @override
  Future<ApiResponse> editPlantation(
      {required int id, required Map<String, dynamic> body}) async {
    try {
      // Use V2 service to keep error bodies (e.g., 400 with validation message)
      final response = await ApiServiceV2.patch(
        ApiConst.apiUpdatePlantation(id),
        data: body,
      );
      return response;
    } catch (e) {
      log("Error: $e");
      return ApiResponse(
        statusCode: 500,
        data: {"message": "Unexpected error: ${e.toString()}"},
      );
    }
  }

  // ===== Images per-endpoint operations =====
  @override
  Future<String?> getPlantationImages({required int id}) async {
    try {
      final data = await ApiService.get(
          ApiConst.apiUpdateImage(id), ApiParams.emptyParams());
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<ApiResponse> postPlantationImage(
      {required int id, required String filePath}) async {
    try {
      final response =
          await ApiService.postFile(ApiConst.apiUpdateImage(id), filePath);
      return response;
    } catch (e) {
      return ApiResponse(statusCode: 500, data: {"message": e.toString()});
    }
  }

  /// Загружает deal_file/resolution_file через единственный endpoint,
  /// принимающий multipart для этих полей (не mobile-update — тот JSON-only).
  Future<ApiResponse> uploadPlantationDocFile({
    required int id,
    required String fieldName,
    required String filePath,
  }) async {
    try {
      final response = await ApiService.patchFile(
        ApiConst.apiPlantationFiles(id),
        fieldName,
        filePath,
      );
      return response;
    } catch (e) {
      return ApiResponse(statusCode: 500, data: {"message": e.toString()});
    }
  }

  @override
  Future<String?> deletePlantationImage(
      {required int plantationId, required int imageId}) async {
    try {
      final data = await ApiService.delete(
          ApiConst.apiDeleteImage(plantationId, imageId));
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> editImage(
      {required int id, required List<String> images}) async {
    try {
      final data = await ApiService.uploadImages(
          ApiConst.apiLegacyImagesUpdate(id), images);
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
      return "Server error: ${e.response?.statusCode ?? 'Unknown status code'}";
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
      return "Unexpected error: $e";
    }
  }

  // ===== Misc =====
  @override
  Future<String?> getUserInfo() async {
    try {
      final data = await ApiService.get(
          ApiConst.apiGetUserInfo, ApiParams.emptyParams());
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> getFarmerById(int farmerId) async {
    try {
      final data = await ApiService.get(
          "${ApiConst.apiFermers}$farmerId/", ApiParams.emptyParams());
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> getFarmersStatistics({
    int? districtId,
    int? regionId,
    String? status,
  }) async {
    try {
      final params = ApiParams.farmersStatisticsParams(
        districtId: districtId,
        regionId: regionId,
        status: status,
      );
      final data = await ApiService.get(ApiConst.apiFarmersStatistics, params);
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> getRegionDistrictsStatistics(int regionId) async {
    try {
      final data = await ApiService.get(
          ApiConst.apiRegionDistrictsStatistics(regionId),
          ApiParams.emptyParams());
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  // ===== Device Tokens API =====
  // /api/device-tokens/ существует, но нестабилен на бэкенде — часть
  // запросов 500-ит (похоже на необработанный unique constraint при
  // повторной регистрации того же device_token, не подтверждено без
  // серверных логов). Раньше эти методы были ошибочно превращены в
  // no-op, посчитав эндпоинт полностью мёртвым по нескольким ручным
  // проверкам, которые попали именно на 500 — на деле он иногда
  // отрабатывает успешно. Восстановлены реальные вызовы: try/catch уже
  // делает их best-effort, 500 просто вернёт null, не сломает login/logout.
  @override
  Future<String?> registerDeviceToken({
    required String token,
    required String platform,
    String? appVersion,
  }) async {
    try {
      final body = <String, dynamic>{
        "device_token": token,
        "platform": platform,
      };
      if (appVersion != null && appVersion.isNotEmpty) {
        body["app_version"] = appVersion;
      }

      final response = await ApiService.post(ApiConst.apiDeviceTokens, body);
      return jsonEncode(response.data);
    } on DioException catch (e) {
      debugPrint("registerDeviceToken error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("registerDeviceToken unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> getDeviceTokens() async {
    try {
      final data = await ApiService.get(ApiConst.apiDeviceTokens, {});
      return data;
    } on DioException catch (e) {
      debugPrint("getDeviceTokens error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("getDeviceTokens unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> removeDeviceToken({required String token}) async {
    try {
      final data =
          await ApiService.delete(ApiConst.apiDeviceTokenByToken(token));
      return data;
    } on DioException catch (e) {
      debugPrint("removeDeviceToken error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("removeDeviceToken unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  // ===== Notifications API =====
  @override
  Future<String?> getNotifications(
      {int limit = 20, int offset = 0, bool? unreadOnly, String? type}) async {
    try {
      final params = ApiParams.notificationsListParams(
          limit: limit, offset: offset, unreadOnly: unreadOnly, type: type);
      final data = await ApiService.get(ApiConst.apiNotifications, params);
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> getUnreadNotificationsCount() async {
    try {
      final data = await ApiService.get(
          ApiConst.apiNotificationsUnreadCount, ApiParams.emptyParams());
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> markNotificationsAsRead(
      {bool markAll = false, List<int>? ids}) async {
    try {
      final body = <String, dynamic>{};
      if (markAll) body['mark_all_as_read'] = true;
      if (ids != null && ids.isNotEmpty) body['notification_ids'] = ids;
      final response = await ApiService.patch(ApiConst.apiNotifications, body);
      return response?.toString();
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> markNotificationAsRead({required int id}) async {
    try {
      final response =
          await ApiService.patch("${ApiConst.apiNotifications}$id/", {});
      return response?.toString();
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<String?> deleteNotification({required int id}) async {
    try {
      final data = await ApiService.delete("${ApiConst.apiNotifications}$id/");
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  // ==== Comments ====
  @override
  Future<String?> getPlantationComments({required int plantationId}) async {
    try {
      final data = await ApiService.get(
        ApiConst.apiPlantationComments(plantationId),
        ApiParams.emptyParams(),
      );
      return data;
    } on DioException catch (e) {
      debugPrint("Server error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("Unexpected error: $e");
      _recordError(e);
    }
    return null;
  }

  @override
  Future<ApiResponse> addPlantationComment(
      {required int plantationId,
      required String body,
      bool isModeration = false}) async {
    try {
      final requestData = {"body": body, "is_moderation": isModeration};
      log("📤 Adding comment to plantation $plantationId:");
      log("📤 Request data: ${jsonEncode(requestData)}");
      log("📤 is_moderation value: $isModeration (type: ${isModeration.runtimeType})");

      final response = await ApiService.post(
        ApiConst.apiPlantationComments(plantationId),
        requestData,
      );

      log("📥 Comment response status: ${response.statusCode}");
      log("📥 Comment response data: ${response.data}");

      return response;
    } catch (e) {
      log("Error adding comment: $e");
      return ApiResponse(
        statusCode: 500,
        data: {"message": "Unexpected error: ${e.toString()}"},
      );
    }
  }

  // ==== Users ====
  @override
  Future<String?> getUserById({required int id}) async {
    try {
      final data = await ApiService.get(
          ApiConst.apiUserById(id), ApiParams.emptyParams());
      return data;
    } on DioException catch (e) {
      debugPrint("getUserById error: ${e.response?.data ?? e.message}");
      _recordError(e);
    } catch (e) {
      debugPrint("getUserById unexpected error: $e");
      _recordError(e);
    }
    return null;
  }
}
