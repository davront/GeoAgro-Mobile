import 'dart:async';
import 'dart:io';
import 'package:l/l.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../interceptors/token_interceptor.dart';
import '../interceptors/secure_logger_interceptor.dart';
import '../../constants/app_constants.dart';

import '../../storage/app_storage.dart';
import 'api_constants.dart';
import '../../../data/model/response/api_response.dart';

class ApiServiceV2 {
  static Dio? _dio;
  static bool _isInitialized = false;

  static Future<Dio> initDio() async {
    if (_dio != null && _isInitialized) return _dio!;

    _dio = Dio();

    _dio!.options = BaseOptions(
      baseUrl: ApiConst.baseUrl,
      connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      sendTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      validateStatus: (status) =>
          status != null && status < 500 && status != 401,
    );

    _dio!.interceptors.addAll([
      TokenInterceptor.instance,
      SecureLoggerInterceptor(),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: false, // Already logged by SecureLoggerInterceptor
          requestBody: false,
          responseBody: false,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          enabled: false,
        ),
    ]);

    _isInitialized = true;
    return _dio!;
  }

  static Future<ApiResponse> _makeRequest(
    Future<Response> Function() requestFunction, {
    int maxRetries = AppConstants.apiRetryAttempts,
  }) async {
    int attempts = 0;

    l.i("_makeRequest: Starting with maxRetries: $maxRetries");

    while (attempts < maxRetries) {
      try {
        l.i("_makeRequest: Attempt ${attempts + 1}");

        final response = await requestFunction();
        l.i("_makeRequest: Response received: ${response.statusCode}");

        return ApiResponse(
          statusCode: response.statusCode ?? 500,
          data: response.data,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          l.w("_makeRequest: 401 error detected - interceptor should handle this");
          return ApiResponse(
            statusCode: 401,
            data: {"message": "Authentication required"},
          );
        }

        attempts++;
        l.e("API Error (attempt $attempts): ${e.message}");
        l.e("DioException type: ${e.type}");
        l.e("DioException response: ${e.response?.data}");

        if (attempts >= maxRetries) {
          l.e("_makeRequest: Max retries reached");
          return ApiResponse(
            statusCode: e.response?.statusCode ?? 500,
            data: e.response?.data ?? {"message": e.message},
          );
        }

        l.i("_makeRequest: Waiting $attempts seconds before retry");
        await Future.delayed(Duration(seconds: attempts));
      } catch (e) {
        l.e("Unexpected error: $e");
        return ApiResponse(
          statusCode: 500,
          data: {"message": "Күтмаган хатолик юз берди"},
        );
      }
    }

    l.e("_makeRequest: All retries exhausted");
    return ApiResponse(
      statusCode: 500,
      data: {"message": "Максимал қайта уринишлар"},
    );
  }

  static Future<ApiResponse> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    return _makeRequest(() async {
      final dio = await initDio();
      final token = await AppStorage.$read(key: StorageKey.accessToken);

      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      return await dio.get(endpoint, queryParameters: queryParameters);
    });
  }

  static Future<ApiResponse> post(String endpoint, {dynamic data}) async {
    return _makeRequest(() async {
      final dio = await initDio();
      final token = await AppStorage.$read(key: StorageKey.accessToken);

      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      return await dio.post(endpoint, data: data);
    });
  }

  // PUT request
  static Future<ApiResponse> put(String endpoint, {dynamic data}) async {
    return _makeRequest(() async {
      final dio = await initDio();
      final token = await AppStorage.$read(key: StorageKey.accessToken);

      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      return await dio.put(endpoint, data: data);
    });
  }

  // PATCH request
  static Future<ApiResponse> patch(String endpoint, {dynamic data}) async {
    l.i("PATCH request to: $endpoint");
    l.i("PATCH data: $data");

    return _makeRequest(() async {
      final dio = await initDio();
      final token = await AppStorage.$read(key: StorageKey.accessToken);

      l.i("PATCH token: ${token != null ? 'present' : 'missing'}");

      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      l.i("PATCH headers: ${dio.options.headers}");

      final response = await dio.patch(endpoint, data: data);
      l.i("PATCH response: ${response.statusCode}");
      return response;
    });
  }

  // DELETE request
  static Future<ApiResponse> delete(String endpoint) async {
    return _makeRequest(() async {
      final dio = await initDio();
      final token = await AppStorage.$read(key: StorageKey.accessToken);

      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      return await dio.delete(endpoint);
    });
  }

  static Future<ApiResponse> multipart(
    String endpoint, {
    required Map<String, String> fields,
    required List<MapEntry<String, File>> files,
  }) async {
    return _makeRequest(() async {
      final dio = await initDio();
      final token = await AppStorage.$read(key: StorageKey.accessToken);

      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      FormData formData = FormData.fromMap(fields);

      for (var fileEntry in files) {
        formData.files.add(MapEntry(
          fileEntry.key,
          await MultipartFile.fromFile(fileEntry.value.path),
        ));
      }

      return await dio.post(endpoint, data: formData);
    });
  }

  static Future<ApiResponse> uploadImages(
      String endpoint, List<File> images) async {
    return _makeRequest(() async {
      final dio = await initDio();
      final token = await AppStorage.$read(key: StorageKey.accessToken);

      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      FormData formData = FormData();

      for (int i = 0; i < images.length; i++) {
        formData.files.add(MapEntry(
          'images[$i]',
          await MultipartFile.fromFile(images[i].path),
        ));
      }

      return await dio.post(endpoint, data: formData);
    });
  }

  static void clearCache() {
    _dio = null;
    _isInitialized = false;
  }
}
