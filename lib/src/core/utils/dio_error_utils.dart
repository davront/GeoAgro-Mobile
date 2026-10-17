import 'dart:io';

import 'package:dio/dio.dart';

/// Human-readable message for a DioException so VMs can show the backend's
/// actual error instead of a generic "server error".
class DioErrorUtils {
  const DioErrorUtils._();

  /// Best-effort message for any thrown object, falling back to a generic
  /// Uzbek-localised string. Use this from VM catch-all blocks.
  static String messageFromAny(Object error) {
    if (error is DioException) return message(error);
    if (error is SocketException) {
      return "Internet bilan bog'lanib bo'lmadi.";
    }
    if (error is FormatException) {
      return "Ma'lumot formati noto'g'ri.";
    }
    if (error is String && error.trim().isNotEmpty) return error.trim();
    return "Kutilmagan xatolik yuz berdi.";
  }

  static String message(DioException e) {
    // Network-layer problems before any HTTP status came back
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "So'rov vaqti tugadi. Internetni tekshirib qayta urinib ko'ring.";
      case DioExceptionType.connectionError:
        return "Internet bilan bog'lanib bo'lmadi.";
      case DioExceptionType.cancel:
        return "So'rov bekor qilindi.";
      case DioExceptionType.badCertificate:
        return "Server sertifikati noto'g'ri.";
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    if (e.error is SocketException) {
      return "Internet bilan bog'lanib bo'lmadi.";
    }

    final fromBody = _fromResponseBody(e.response?.data);
    if (fromBody != null && fromBody.isNotEmpty) return fromBody;

    final code = e.response?.statusCode;
    if (code != null) {
      if (code == 400) return "Yuborilgan ma'lumot noto'g'ri.";
      if (code == 401) return "Avtorizatsiya muddati tugadi.";
      if (code == 403) return "Sizga ruxsat berilmagan.";
      if (code == 404) return "Ma'lumot topilmadi.";
      if (code == 409) return "Ushbu amal ziddiyatga olib keladi.";
      if (code == 413) return "Yuklangan fayl juda katta.";
      if (code >= 500) return "Serverda xatolik yuz berdi.";
      return "Kutilmagan xatolik (HTTP $code).";
    }

    return e.message ?? "Kutilmagan xatolik yuz berdi.";
  }

  static String? _fromResponseBody(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      final trimmed = data.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (data is Map) {
      // Common DRF / custom error shapes
      for (final key in const ['detail', 'message', 'error']) {
        final v = data[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      // Field-validation errors: {"field": ["msg"], ...}
      final parts = <String>[];
      data.forEach((field, value) {
        if (value is List && value.isNotEmpty) {
          parts.add("${field.toString()}: ${value.first}");
        } else if (value is String && value.isNotEmpty) {
          parts.add("${field.toString()}: $value");
        }
      });
      if (parts.isNotEmpty) return parts.join('; ');
    }
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is String) return first;
    }
    return null;
  }
}
