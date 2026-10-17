import 'dart:convert';

/// Единый парсер сообщений об ошибках от Django REST бэкенда — раньше
/// эта логика была скопипащена в detail_vm.dart (create) и дважды в
/// edit_vm.dart (editPlantation/editPlantationWithImages), каждая копия
/// покрывала чуть разный набор форматов и ни одна не понимала Django
/// form-style `{"__all__": [...]}` (реальный формат, пришедший с бэка
/// при ошибке "Для данного типа нет подтипов").
///
/// Известные форматы ответа с ошибкой:
/// - `{"error": "текст"}` — плоский
/// - `{"error": {"non_field_errors": [...]}}` — вложенный DRF
/// - `{"error": "{\"non_field_errors\": [...]}"}` — вложенный DRF,
///   но error — JSON-строка, а не объект (сериализация задвоена на бэке)
/// - `{"non_field_errors": [...]}` — верхнеуровневый DRF ValidationError
/// - `{"__all__": [...]}` — Django ModelForm-style
/// - `{"message": "текст"}`
/// - `{"subsidies": [...]}` — специфичная для create-формы ошибка
/// - `{"field_name": ["ошибка"]}` — построчная ошибка конкретного поля
/// - просто строка (plain text, не JSON)
class ApiErrorParser {
  ApiErrorParser._();

  static const String fallbackMessage = "Xatolik yuz berdi";

  /// Разбирает `response.data` (уже распарсенный Dio JSON, либо сырая
  /// строка) и возвращает первое человекочитаемое сообщение об ошибке,
  /// либо [fallbackMessage] если формат не распознан.
  static String parse(dynamic data, {String? fallback}) {
    final resolvedFallback = fallback ?? fallbackMessage;

    dynamic value = data;
    if (value is String) {
      final decoded = _tryDecode(value);
      if (decoded == null) {
        // Не JSON — сама строка и есть сообщение об ошибке.
        return value.isNotEmpty ? value : resolvedFallback;
      }
      value = decoded;
    }

    if (value is Map) {
      final map = value.map((k, v) => MapEntry(k.toString(), v));
      final message = _fromMap(map);
      if (message != null) return message;
    }

    return resolvedFallback;
  }

  /// Ключи, не являющиеся именем поля модели — общие/служебные обёртки
  /// ошибки. Используется, чтобы отличить `{"plantation_type": [...]}`
  /// (реальное поле формы) от `{"error": ...}`/`{"message": ...}`.
  static const _nonFieldKeys = {
    'error',
    'message',
    'non_field_errors',
    '__all__',
    'subsidies',
  };

  /// Пытается извлечь имя поля модели, к которому относится ошибка
  /// (DRF field-level ValidationError вида `{"plantation_type": [...]}`),
  /// для подсветки конкретного инпута на форме. Возвращает null, если
  /// ошибка не привязана к конкретному полю (non_field_errors/__all__/
  /// error/message — общая ошибка формы).
  static String? parseFieldName(dynamic data) {
    dynamic value = data;
    if (value is String) {
      value = _tryDecode(value);
    }
    if (value is! Map) return null;

    final map = value.map((k, v) => MapEntry(k.toString(), v));

    // error может оборачивать вложенный field-level объект.
    final errorValue = map['error'];
    if (errorValue is String) {
      final decoded = _tryDecode(errorValue);
      if (decoded is Map) {
        return parseFieldName(decoded);
      }
    } else if (errorValue is Map) {
      return parseFieldName(errorValue);
    }

    for (final key in map.keys) {
      if (_nonFieldKeys.contains(key)) continue;
      final v = map[key];
      if (v is String && v.isNotEmpty) return key;
      if (v is List && v.isNotEmpty) return key;
    }

    return null;
  }

  static dynamic _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static String? _fromMap(Map<String, dynamic> map) {
    // Специфичная для create-плантации ошибка подписей — приоритет,
    // т.к. несёт более конкретный текст, чем generic non_field_errors.
    if (map['subsidies'] != null) {
      final fromList = _firstFromListOrString(map['subsidies']);
      if (fromList != null) return fromList;
    }

    if (map['message'] is String && (map['message'] as String).isNotEmpty) {
      return map['message'] as String;
    }

    // Django ModelForm-style: {"__all__": ["..."]}
    if (map['__all__'] != null) {
      final fromList = _firstFromListOrString(map['__all__']);
      if (fromList != null) return fromList;
    }

    if (map['non_field_errors'] != null) {
      final fromList = _firstFromListOrString(map['non_field_errors']);
      if (fromList != null) return fromList;
    }

    if (map['error'] != null) {
      final errorValue = map['error'];
      if (errorValue is String) {
        // error может быть JSON-строкой с вложенной структурой, либо
        // просто текстом — если не парсится, используем как есть.
        final decoded = _tryDecode(errorValue);
        if (decoded is Map) {
          final nested =
              _fromMap(decoded.map((k, v) => MapEntry(k.toString(), v)));
          if (nested != null) return nested;
        }
        return errorValue.isNotEmpty ? errorValue : null;
      }
      if (errorValue is Map) {
        final nested =
            _fromMap(errorValue.map((k, v) => MapEntry(k.toString(), v)));
        if (nested != null) return nested;
      }
    }

    // Построчная ошибка конкретного поля — берём первое непустое поле
    // с текстом или списком текстов (DRF field-level ValidationError).
    for (final entry in map.entries) {
      final v = entry.value;
      if (v is String && v.isNotEmpty) return v;
      if (v is List && v.isNotEmpty) {
        final fromList = _firstFromListOrString(v);
        if (fromList != null) return fromList;
      }
    }

    return null;
  }

  static String? _firstFromListOrString(dynamic value) {
    if (value is String) {
      return value.isNotEmpty ? value : null;
    }
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map && first['string'] is String) {
        return first['string'] as String;
      }
      return first.toString();
    }
    return null;
  }
}
