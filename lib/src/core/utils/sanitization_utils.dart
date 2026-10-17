/// Утилиты для санитизации пользовательского ввода
/// Защита от XSS инъекций и других вредоносных данных
class SanitizationUtils {
  /// Санитизация текстового ввода для защиты от XSS
  /// 
  /// Удаляет:
  /// - HTML теги (<div>, <span> и т.д.)
  /// - JavaScript теги (<script>...</script>)
  /// - JavaScript протоколы (javascript:)
  /// - Обработчики событий (onclick=, onerror= и т.д.)
  /// 
  /// Примеры:
  /// ```dart
  /// sanitizeInput('<script>alert("XSS")</script>Hello') // 'Hello'
  /// sanitizeInput('Hello <div>World</div>') // 'Hello World'
  /// sanitizeInput('onclick="alert(1)"') // ''
  /// ```
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    return input
        // Удаляем script теги (многострочные)
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '')
        // Удаляем все HTML теги
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Удаляем javascript: протоколы
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        // Удаляем обработчики событий (onclick=, onerror=, onload= и т.д.)
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        // Удаляем data: протоколы (может содержать вредоносный код)
        .replaceAll(RegExp(r'data:\s*[^;]*;', caseSensitive: false), '')
        // Удаляем vbscript: протоколы
        .replaceAll(RegExp(r'vbscript:', caseSensitive: false), '')
        // Удаляем iframe теги
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true), '')
        // Удаляем object теги
        .replaceAll(RegExp(r'<object[^>]*>.*?</object>', caseSensitive: false, dotAll: true), '')
        // Удаляем embed теги
        .replaceAll(RegExp(r'<embed[^>]*>', caseSensitive: false), '')
        // Удаляем лишние пробелы
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Санитизация комментариев (более мягкая, сохраняет переносы строк)
  /// 
  /// Удаляет опасные элементы, но сохраняет:
  /// - Переносы строк
  /// - Обычные знаки препинания
  /// - Специальные символы (для поддержки разных языков)
  static String sanitizeComment(String input) {
    if (input.isEmpty) return input;
    
    // Сначала заменяем переносы строк на временный маркер
    final withMarker = input.replaceAll('\n', '{{NEWLINE}}');
    
    // Применяем стандартную санитизацию
    final sanitized = sanitizeInput(withMarker);
    
    // Восстанавливаем переносы строк
    return sanitized.replaceAll('{{NEWLINE}}', '\n');
  }

  /// Проверка на наличие потенциально опасного контента
  /// 
  /// Возвращает true, если в строке обнаружены опасные паттерны
  static bool containsDangerousContent(String input) {
    if (input.isEmpty) return false;
    
    final dangerousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
      RegExp(r'<object', caseSensitive: false),
      RegExp(r'<embed', caseSensitive: false),
      RegExp(r'data:\s*[^;]*;', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
    ];
    
    return dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }
}
