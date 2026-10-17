import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that masks sensitive data in logs (tokens, passwords)
/// Prevents sensitive information from appearing in production logs
class SecureLoggerInterceptor extends Interceptor {
  SecureLoggerInterceptor();

  /// Mask token-like strings
  String _maskToken(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.length <= 10) return '***';
    return '${value.substring(0, 4)}***${value.substring(value.length - 4)}';
  }

  /// Mask sensitive values in JSON
  dynamic _maskSensitiveData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final masked = <String, dynamic>{};
      data.forEach((key, value) {
        final lowerKey = key.toLowerCase();
        // Mask tokens, passwords, and other sensitive fields
        if (lowerKey.contains('token') ||
            lowerKey.contains('password') ||
            lowerKey.contains('auth') ||
            lowerKey.contains('secret') ||
            lowerKey.contains('key') ||
            lowerKey == 'access' ||
            lowerKey == 'refresh') {
          if (value is String) {
            masked[key] = _maskToken(value);
          } else {
            masked[key] = '***MASKED***';
          }
        } else if (value is Map || value is List) {
          masked[key] = _maskSensitiveData(value);
        } else {
          masked[key] = value;
        }
      });
      return masked;
    } else if (data is List) {
      return data.map((item) => _maskSensitiveData(item)).toList();
    }
    return data;
  }

  /// Mask Authorization header
  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final masked = Map<String, dynamic>.from(headers);
    if (masked.containsKey('authorization') || masked.containsKey('Authorization')) {
      final authKey = masked.containsKey('authorization') ? 'authorization' : 'Authorization';
      final authValue = masked[authKey];
      if (authValue is String) {
        if (authValue.startsWith('Bearer ')) {
          masked[authKey] = 'Bearer ***MASKED***';
        } else {
          masked[authKey] = '***MASKED***';
        }
      }
    }
    return masked;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        // Mask headers
        final maskedHeaders = _maskHeaders(options.headers);
        
        // Mask request data if it contains sensitive information
        dynamic maskedData = options.data;
        if (options.data != null) {
          try {
            if (options.data is String) {
              final jsonData = jsonDecode(options.data as String);
              maskedData = _maskSensitiveData(jsonData);
              maskedData = jsonEncode(maskedData);
            } else if (options.data is Map) {
              maskedData = _maskSensitiveData(options.data);
            }
          } catch (e) {
            // If can't parse, check if it's a password field
            if (options.data.toString().toLowerCase().contains('password')) {
              maskedData = '***MASKED***';
            }
          }
        }

        developer.log(
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
          '🌐 [REQUEST] ${options.method} ${options.uri}\n'
          '📋 Headers: ${jsonEncode(maskedHeaders)}\n'
          '📦 Data: ${maskedData?.toString() ?? 'null'}\n'
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        );
      } catch (e) {
        developer.log('Error in SecureLoggerInterceptor.onRequest: $e');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        // Mask response data if it contains sensitive information
        dynamic maskedData = response.data;
        if (response.data != null) {
          try {
            if (response.data is String) {
              final jsonData = jsonDecode(response.data as String);
              maskedData = _maskSensitiveData(jsonData);
              maskedData = jsonEncode(maskedData);
            } else if (response.data is Map || response.data is List) {
              maskedData = _maskSensitiveData(response.data);
            }
          } catch (e) {
            // If can't parse, leave as is
          }
        }

        developer.log(
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
          '✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}\n'
          '📦 Data: ${maskedData?.toString() ?? 'null'}\n'
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        );
      } catch (e) {
        developer.log('Error in SecureLoggerInterceptor.onResponse: $e');
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      try {
        dynamic maskedData = err.response?.data;
        if (err.response?.data != null) {
          try {
            if (err.response!.data is String) {
              final jsonData = jsonDecode(err.response!.data as String);
              maskedData = _maskSensitiveData(jsonData);
              maskedData = jsonEncode(maskedData);
            } else if (err.response!.data is Map || err.response!.data is List) {
              maskedData = _maskSensitiveData(err.response!.data);
            }
          } catch (e) {
            // If can't parse, leave as is
          }
        }

        developer.log(
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
          '❌ [ERROR] ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.method} ${err.requestOptions.uri}\n'
          '📦 Data: ${maskedData?.toString() ?? err.message}\n'
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        );
      } catch (e) {
        developer.log('Error in SecureLoggerInterceptor.onError: $e');
      }
    }
    super.onError(err, handler);
  }
}

