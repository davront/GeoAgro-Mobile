import "dart:developer";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:package_info_plus/package_info_plus.dart";

import "../../storage/app_storage.dart";
import "../../routes/router_config.dart";
import "../../routes/app_route_names.dart";
import "../../setting/setup.dart";
import "../../widgets/update_required_dialog.dart";

class TokenInterceptor extends Interceptor {
  TokenInterceptor._();

  static final TokenInterceptor instance = TokenInterceptor._();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      log(
        "---------[TokenInterceptor]---------ON_REQUEST(${options.method})------------------\n\n"
        "URL: ${options.uri}\n"
        "Headers: ${options.headers}\n"
        "---------------------------------------------------------------------------\n\n",
      );
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    if (kDebugMode) {
      log(
        "---------[TokenInterceptor]---------ON_RESPONSE(${response.statusCode})------------------\n\n"
        "URL: ${response.realUri}\n"
        "Data: ${response.data}\n"
        "---------------------------------------------------------------------------\n\n",
      );
    }

    // Check for auth-related messages even in successful responses
    final responseData = response.data;
    if (responseData != null) {
      String? errorMessage;

      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['detail']?.toString() ??
            responseData['message']?.toString() ??
            responseData['error']?.toString();
      } else if (responseData is String) {
        errorMessage = responseData;
      }

      // Check if message indicates auth error (e.g., "Пароль был изменён")
      if (errorMessage != null) {
        final lower = errorMessage.toLowerCase();
        if (lower.contains('пароль был изменён') ||
            lower.contains('password was changed') ||
            lower.contains('войдите заново') ||
            lower.contains('войти заново') ||
            lower.contains('login again') ||
            lower.contains('please login')) {
          log("Auth error message detected in response. Redirecting to login...");
          await _clearSessionAndRedirectToLogin(
              "Redirected to login page from response");
          // Обязательно завершаем handler — иначе Future исходного запроса
          // никогда не резолвится/реджектится, и любой await на нём (в т.ч.
          // getUserInfo() внутри setup() на cold start) виснет навсегда,
          // App.run() не вызывается — чёрный экран без единой ошибки в
          // логах, пока юзер не убьёт процесс вручную.
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: 'Session expired',
            ),
          );
          return;
        }
      }
    }

    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    log("TokenInterceptor onError called with status: ${err.response?.statusCode}");

    if (kDebugMode) {
      log(
        "---------[TokenInterceptor]---------ON_ERROR(${err.response?.statusCode})------------------\n\n"
        "URL: ${err.response?.realUri.path}\n"
        "TYPE: ${err.type}\n"
        "Data: ${err.response?.data}\n"
        "Message: ${err.message}\n"
        "---------------------------------------------------------------------------\n\n",
      );
    }

    log("TokenInterceptor processing error: ${err.response?.statusCode} - ${err.response?.data}");

    // Skip interception for login + device-token endpoints; their
    // failures should never log the user out.
    final path = err.requestOptions.path;
    if (path.contains('/api/login/') ||
        path.contains('/api/refresh/') ||
        path.contains('/api/device-tokens')) {
      super.onError(err, handler);
      return;
    }

    final responseData = err.response?.data;
    final statusCode = err.response?.statusCode;

    // Check for version mismatch error (400 with "Мобил иловани янгилаш керак")
    if (statusCode == 400) {
      String? errorMessage;

      if (responseData is Map<String, dynamic>) {
        errorMessage = responseData['detail']?.toString() ??
            responseData['message']?.toString() ??
            responseData['error']?.toString();
      } else if (responseData is String) {
        errorMessage = responseData;
      }

      if (errorMessage != null) {
        final lower = errorMessage.toLowerCase();
        // Проверяем различные варианты сообщения об обновлении
        if (lower.contains('мобил иловани янгилаш керак') ||
            lower.contains('мобил иловани янгилаш') ||
            lower.contains('янгилаш керак') ||
            lower.contains('update required') ||
            lower.contains('version mismatch') ||
            lower.contains('app update required')) {
          log("Version mismatch detected (400): $errorMessage");

          // Показываем диалог обновления
          if (parentNavigatorKey.currentContext != null) {
            _showUpdateDialog(parentNavigatorKey.currentContext!);
          } else {
            log("Warning: parentNavigatorKey.currentContext is null, cannot show update dialog");
          }

          // Не пробрасываем ошибку дальше
          return;
        }
      }
    }

    // Check if it's an authentication error (401 or specific error messages)
    bool isAuthError = false;
    bool shouldRedirectToLogin = false;

    // Helper function to check if message indicates auth error.
    // Only matches phrases that explicitly point at re-login; avoids the
    // word "token" alone because backend success messages mention it
    // (e.g. "Device token ro'yxatga olindi").
    bool isAuthErrorMessage(String message) {
      final lower = message.toLowerCase();
      return lower.contains('пароль был изменён') ||
          lower.contains('password was changed') ||
          lower.contains('войдите заново') ||
          lower.contains('войти заново') ||
          lower.contains('login again') ||
          lower.contains('please login') ||
          lower.contains('please sign in') ||
          lower.contains('token is invalid') ||
          lower.contains('invalid token') ||
          lower.contains('token expired') ||
          lower.contains('token has expired') ||
          lower.contains('token not valid');
    }

    // Check for 401 status code
    if (statusCode == 401) {
      isAuthError = true;
      shouldRedirectToLogin = true;
      log("401 error detected in TokenInterceptor - token expired or invalid");
    }

    // Check response data for auth-related messages (even if status code is not 401)
    if (responseData != null) {
      String? errorMessage;

      if (responseData is Map<String, dynamic>) {
        // Check various fields for error messages
        errorMessage = responseData['detail']?.toString() ??
            responseData['message']?.toString() ??
            responseData['error']?.toString();

        // Also check for token error codes
        if (responseData['code'] == 'token_not_valid' ||
            responseData['code'] == 'token_expired') {
          isAuthError = true;
          shouldRedirectToLogin = true;
        }
      } else if (responseData is String) {
        errorMessage = responseData;
      }

      // Check if error message indicates auth error
      if (errorMessage != null && isAuthErrorMessage(errorMessage)) {
        isAuthError = true;
        shouldRedirectToLogin = true;
        log("Auth error detected from message: $errorMessage");
      }
    }

    // If it's an auth error, redirect to login
    if (shouldRedirectToLogin || isAuthError) {
      log("Authentication error detected. Clearing tokens and redirecting to login...");
      await _clearSessionAndRedirectToLogin("Redirected to login page");
      // Обязательно завершаем handler тем же исключением — без этого
      // Future исходного запроса виснет навсегда (см. тот же паттерн в
      // onResponse выше).
      handler.reject(err);
      return;
    }

    super.onError(err, handler);
  }

  /// Очищает токен/сессию и переводит на логин. Общая точка для обоих
  /// путей auth-ошибки (успешный ответ с "пароль изменён" и error-ответ
  /// с 401/токен-кодами) — раньше этот блок был скопирован в оба места.
  Future<void> _clearSessionAndRedirectToLogin(String successLogMessage) async {
    await AppStorage.clearAllData();
    accessToken = null;
    userId = 0;
    districtId = 1;
    username = null;

    if (parentNavigatorKey.currentContext != null) {
      parentNavigatorKey.currentContext!.go(AppRouteNames.login);
      log(successLogMessage);
    } else {
      log("Warning: parentNavigatorKey.currentContext is null, cannot navigate to login");
    }
  }

  /// Показывает диалог обновления приложения
  Future<void> _showUpdateDialog(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Пытаемся получить требуемую версию из ответа сервера или используем текущую
      // В реальности сервер может вернуть требуемую версию в ответе
      final requiredVersion =
          currentVersion; // Можно улучшить, если сервер возвращает требуемую версию

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // Нельзя закрыть диалог
          builder: (context) => UpdateRequiredDialog(
            currentVersion: currentVersion,
            requiredVersion: requiredVersion,
            downloadUrl: '',
          ),
        );
      }
    } catch (e) {
      log("Error showing update dialog: $e");
    }
  }
}
