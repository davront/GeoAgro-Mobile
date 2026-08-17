import "dart:io";
import "dart:async";
import "dart:convert";
import "package:l/l.dart";
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import "package:dio/io.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";
import "package:package_info_plus/package_info_plus.dart";

import "api_constants.dart";
import "../../storage/app_storage.dart";
import "../interceptors/connectivity_interceptor.dart";
import "../interceptors/performance_interceptor.dart";
import "../interceptors/token_interceptor.dart";
import "../interceptors/secure_logger_interceptor.dart";
import "../../../data/model/response/api_response.dart";
import "../../setting/setup.dart";

@immutable
class ApiService {
  const ApiService._();

  static Future<Dio> initDio() async {
    /// Dio
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConst.baseUrl,
        headers: await ApiService.getHeaders(),
        connectTimeout: ApiConst.connectionTimeout,
        receiveTimeout: ApiConst.sendTimeout,
        sendTimeout: ApiConst.sendTimeout,
        validateStatus: (status) =>
            status != null && status < 500 && status != 401,
      ),
    );

    dio.interceptors.addAll([
      TokenInterceptor.instance,
      ConnectivityInterceptor(),
      PerformanceInterceptor(),
      // Secure logger (masks sensitive data) - always enabled in debug
      SecureLoggerInterceptor(),
      // PrettyDioLogger for detailed logs (only in debug mode, shows masked data)
      // Note: SecureLoggerInterceptor already logs, so PrettyDioLogger is optional
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: false, // Already logged by SecureLoggerInterceptor
          requestBody: false, // Already logged by SecureLoggerInterceptor
          responseHeader: false,
          responseBody: false,
          compact: true,
          enabled: false, // Disabled - using SecureLoggerInterceptor instead
        ),
    ]);

    // Deprecated bo'lgan onHttpClientCreate o'rniga createHttpClient'dan foydalanamiz
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    return dio;
  }

  static Future<Map<String, String>> getHeaders({bool isUpload = false}) async {
    final headers = <String, String>{
      "Content-type":
          isUpload ? "multipart/form-data" : "application/json; charset=UTF-8",
      // "Accept": isUpload ? "multipart/form-data" : "application/json; charset=UTF-8",
    };

    final token = accessToken ??
        await AppStorage.$read(key: StorageKey.accessToken) ??
        "";

    if (token.isNotEmpty) {
      // l.d("🔐 API: Using token (starts with): ${token.substring(0, token.length > 10 ? 10 : token.length)}...");
      headers.putIfAbsent("Authorization", () => "Bearer $token");
    } else {
      l.w("⚠️ API: No token found for headers!");
    }

    // Добавляем версию приложения в заголовки
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      headers.putIfAbsent("flutter-version", () => packageInfo.version);
      l.d("📱 API: Added flutter-version header: ${packageInfo.version}");
    } catch (e) {
      l.w("⚠️ API: Failed to get app version: $e");
      // Если не удалось получить версию, используем fallback
      headers.putIfAbsent("flutter-version", () => "4.0.0");
    }

    return headers;
  }

  static Future<String?> get(String api, Map<String, dynamic> params) async {
    try {
      final response =
          await (await initDio()).get<dynamic>(api, queryParameters: params);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonEncode(response.data);
      } else {
        return null;
      }
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      // Let the interceptor handle 401 errors
      l.e(e.response.toString());
      rethrow;
    } on Object catch (e) {
      l.e(e.toString());
      rethrow;
    }
  }

  static Future<ApiResponse> post(String api, Map<String, dynamic> data,
      [Map<String, dynamic> params = const <String, dynamic>{}]) async {
    try {
      final dio = await initDio();
      final headers = await getHeaders(isUpload: false);

      final response = await dio.post<dynamic>(
        api,
        data: jsonEncode(data),
        queryParameters: params,
        options: Options(headers: headers),
      );

      return ApiResponse(
          statusCode: response.statusCode ?? 500, data: response.data);
    } on DioException catch (e) {
      // Let the interceptor handle 401 errors
      return ApiResponse(
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {"message": e.message});
    } catch (e) {
      return ApiResponse(statusCode: 500, data: {"message": e.toString()});
    }
  }

  static Future<ApiResponse> multipart(
      String api, Map<String, dynamic> body, List<String> filePaths) async {
    try {
      final formData = FormData();

      // Add files to form data
      if (filePaths.isNotEmpty) {
        for (var i = 0; i < filePaths.length; i++) {
          formData.files.add(MapEntry("images[$i][images]",
              await MultipartFile.fromFile(filePaths[i])));
        }
      }

      // Add all other fields from body to form data
      body.forEach((key, value) {
        if (value != null) {
          // Handle nested objects like coordinates and investments
          if (value is List &&
              (key == 'coordinates' ||
                  key == 'investments' ||
                  key == 'trellises' ||
                  key == "reservoirs" ||
                  key == "subsidies")) {
            l.d("📤 API: Processing $key as array with ${value.length} items");
            for (var i = 0; i < value.length; i++) {
              if (value[i] is Map) {
                value[i].forEach((nestedKey, nestedValue) {
                  if (nestedValue != null) {
                    final fieldKey = '$key[$i][$nestedKey]';
                    final fieldValue = nestedValue.toString();
                    formData.fields.add(
                      MapEntry(fieldKey, fieldValue),
                    );
                  }
                });
              }
            }
          } else if (value is List && key == 'kontur_number') {
            // Send as indexed list fields: kontur_number[0], kontur_number[1], ...
            for (var i = 0; i < value.length; i++) {
              final v = value[i];
              if (v == null) continue;
              formData.fields.add(MapEntry('$key[$i]', v.toString()));
            }
          } else {
            // Handle simple string fields (including comments)
            final fieldValue = value.toString();
            formData.fields.add(MapEntry(key, fieldValue));
            if (key == 'comments') {
              l.d("📝 API: Adding comments field: $key = $fieldValue");
            }
          }
        } else {
          l.d("⚠️ API: Field $key is null, skipping");
        }
      });

      // Log all form data fields for debugging
      l.d("📦 API: Total form data fields: ${formData.fields.length}");
      final userLocationFields = formData.fields
          .where((field) => field.key.contains('user_location'))
          .toList();
      l.d("📦 API: user_location/user_locations fields in form data: ${userLocationFields.length}");
      for (var field in userLocationFields) {
        l.d("📦 API: Form field: ${field.key} = ${field.value}");
      }

      // Log all field keys for debugging
      l.d("📦 API: All form data field keys:");
      for (var field in formData.fields) {
        if (field.key.contains('user_location') ||
            field.key.contains('coordinates') ||
            field.key.contains('district')) {
          l.d("📦 API: Key: ${field.key}, Value: ${field.value}");
        }
      }

      final response = await (await initDio()).post<dynamic>(
        api,
        data: formData,
        options: Options(
          // headers: {
          //   'Content-Type': 'multipart/form-data',
          // },

          headers: await ApiService.getHeaders(isUpload: true),
        ),
      );

      return ApiResponse(
          statusCode: response.statusCode ?? 500, data: response.data);

      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   return jsonEncode(response.data);
      // } else {
      //   log("Respone statuscode : ${response.statusCode}");
      //   return null;
      // }
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      // Let the interceptor handle 401 errors
      l.e(e.response.toString());
      rethrow;
    } on Object catch (e) {
      l.e(e.toString());
      rethrow;
    }
  }

  static Future<String?> uploadImages(
      String api, List<String> filePaths) async {
    try {
      List<MultipartFile> files = [];

      for (var filePath in filePaths) {
        files.add(await MultipartFile.fromFile(filePath));
      }

      final formData = FormData.fromMap({
        'images': files,
      });

      final response = await (await initDio()).patch<dynamic>(
        api,
        data: formData,
        options: Options(
          headers: await ApiService.getHeaders(isUpload: true),
        ),
      );

      return jsonEncode(response.data);
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      // Let the interceptor handle 401 errors
      l.e(e.response.toString());
      rethrow;
    } on Object catch (e) {
      l.e(e.toString());
      rethrow;
    }
  }

  /// Загружает файл под произвольным именем поля через PATCH multipart.
  /// Используется для deal_file/resolution_file на
  /// `/api/plantations/{id}/` — тот endpoint (не mobile-update) единственный
  /// принимает multipart для этих полей; mobile-update — JSON-only.
  static Future<ApiResponse> patchFile(
      String api, String fieldName, String filePath,
      {Map<String, dynamic>? extraFields}) async {
    try {
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
      final type = mimeType.split('/');
      final formData = FormData.fromMap({
        if (extraFields != null) ...extraFields,
        fieldName: await MultipartFile.fromFile(
          filePath,
          contentType:
              MediaType(type.first, type.length > 1 ? type[1] : 'octet-stream'),
        ),
      });

      final response = await (await initDio()).patch<dynamic>(
        api,
        data: formData,
        options: Options(
          headers: await ApiService.getHeaders(isUpload: true),
        ),
      );

      return ApiResponse(
          statusCode: response.statusCode ?? 500, data: response.data);
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      l.e(e.response.toString());
      return ApiResponse(
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {"message": e.message});
    } on Object catch (e) {
      l.e(e.toString());
      return ApiResponse(statusCode: 500, data: {"message": e.toString()});
    }
  }

  static Future<ApiResponse> postFile(String api, String filePath) async {
    try {
      final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
      final type = mimeType.split('/');
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          contentType:
              MediaType(type.first, type.length > 1 ? type[1] : 'jpeg'),
        ),
      });

      final response = await (await initDio()).post<dynamic>(
        api,
        data: formData,
        options: Options(
          headers: await ApiService.getHeaders(isUpload: true),
        ),
      );

      return ApiResponse(
          statusCode: response.statusCode ?? 500, data: response.data);
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      return ApiResponse(
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {"message": e.message});
    } catch (e) {
      return ApiResponse(statusCode: 500, data: {"message": e.toString()});
    }
  }

  static Future<String?> put(String api, Map<String, dynamic> data) async {
    try {
      final response = await (await initDio()).put<dynamic>(api, data: data);

      return jsonEncode(response.data);
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      // Let the interceptor handle 401 errors
      l.e(e.response.toString());
      rethrow;
    } on Object catch (_) {
      rethrow;
    }
  }

  /// PUT method that returns ApiResponse
  static Future<ApiResponse> putWithResponse(
      String api, Map<String, dynamic> data) async {
    try {
      final response = await (await initDio()).put<dynamic>(api, data: data);

      return ApiResponse(
        statusCode: response.statusCode ?? 500,
        data: response.data,
      );
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      // Обрабатываем DioException и возвращаем ApiResponse с данными об ошибке
      l.e("PUT request failed: ${e.response?.statusCode}, ${e.response?.data}");
      if (e.response != null) {
        return ApiResponse(
          statusCode: e.response!.statusCode ?? 500,
          data: e.response!.data,
        );
      }
      rethrow;
    } on Object catch (e) {
      l.e(e.toString());
      rethrow;
    }
  }

  static Future<Response?> patch(String api, Map<String, dynamic> data) async {
    try {
      final response = await (await initDio()).patch<dynamic>(api, data: data);
      // Возвращаем ответ независимо от статус кода для обработки ошибок
      return response;
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      // Let the interceptor handle 401 errors
      l.e(e.response.toString());
      rethrow;
    } on Object catch (_) {
      rethrow;
    }
  }

  /// [Delete Method]
  static Future<String?> delete(String api,
      [Map<String, dynamic>? params]) async {
    try {
      final response =
          await (await initDio()).delete<dynamic>(api, queryParameters: params);
      // DELETE может вернуть 204 (No Content) или 200 с телом ответа
      if (response.statusCode == 204) {
        return "success";
      }

      // Если статус 200, проверяем содержимое ответа на наличие ошибок
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData == null) {
          return "success";
        }

        // Проверяем, не является ли ответ ошибкой
        try {
          final dataStr = responseData.toString();
          // Пытаемся распарсить как JSON
          if (dataStr.trim().startsWith('{') && dataStr.trim().endsWith('}')) {
            final jsonData = jsonDecode(dataStr) as Map<String, dynamic>;
            if (jsonData.containsKey("error")) {
              // Это ошибка, возвращаем как есть для обработки в репозитории
              return dataStr;
            }
          }
          // Если не JSON или нет ошибки, проверяем строку
          final dataLower = dataStr.toLowerCase();
          if (dataLower.contains("error") ||
              dataLower.contains("{error") ||
              dataLower.contains("no plantation") ||
              dataLower.contains("matches") ||
              dataLower.contains("query")) {
            // Это ошибка, возвращаем как есть
            return dataStr;
          }
          // Нет ошибки, возвращаем success
          return "success";
        } catch (_) {
          // Если не удалось проверить, возвращаем как есть
          return responseData.toString();
        }
      }

      return response.data?.toString() ?? "success";
    } on TimeoutException catch (_) {
      l.e("The connection has timed out, Please try again!");
      rethrow;
    } on DioException catch (e) {
      l.e(e.response.toString());
      // Если статус 204, считаем успехом
      if (e.response?.statusCode == 204) {
        return "success";
      }

      // Если статус 200, но есть данные об ошибке, возвращаем их
      if (e.response?.statusCode == 200 && e.response?.data != null) {
        return e.response!.data.toString();
      }

      rethrow;
    } on Object catch (_) {
      rethrow;
    }
  }
}

// extension ListFileToFormData on List<File> {
//   Future<FormData> mappedFormData({required bool isPickedFile}) async => FormData.fromMap(
//         <String, MultipartFile>{
//           for (var v in this) ...{
//             DateTime.now().toString(): MultipartFile.fromBytes(
//               isPickedFile ? v.readAsBytesSync() : (await rootBundle.load(v.path)).buffer.asUint8List(),
//               filename: v.path.substring(v.path.lastIndexOf("/")),
//             ),
//           },
//         },
//       );
// }
