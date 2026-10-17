class ValidationUtils {
  /// Латиница + кириллица + узбекская расширенная кириллица (ў Ў қ Қ ғ Ғ
  /// ҳ Ҳ) + цифры + пробел + кавычки/апострофы (включая backtick — так
  /// orginfo.uz кодирует oʻ/gʻ) + слэш + дефис. Используется для полей
  /// названия/ФИО (Tashkilot nomi, Asoschi, Rahbar) — как InputFormatter,
  /// так и в валидаторах VM, должны совпадать.
  static const String nameCharsetPattern =
      "a-zA-Zа-яА-ЯёЁўЎқҚғҒҳҲ0-9\\s'\"`‘’“”«»ʻʼ/\\-";

  /// То же самое плюс запятая и точка — для полей адреса.
  static const String addressCharsetPattern =
      "a-zA-Zа-яА-ЯёЁўЎқҚғҒҳҲ0-9\\s'\"`‘’“”«»ʻʼ/,.\\-";

  /// Готовый RegExp для InputFormatter.allow (без якорей ^/$).
  static final RegExp nameCharsetFormatter = RegExp("[$nameCharsetPattern]");
  static final RegExp addressCharsetFormatter =
      RegExp("[$addressCharsetPattern]");

  /// Готовый RegExp для валидации всей строки (с якорями).
  static final RegExp nameCharsetValidator =
      RegExp("^[$nameCharsetPattern]+\$");
  static final RegExp addressCharsetValidator =
      RegExp("^[$addressCharsetPattern]+\$");

  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Phone validation for Uzbekistan
  static bool isValidPhone(String phone) {
    // Remove all non-digit characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Uzbekistan phone number
    // +998 90 123 45 67 or 998901234567
    if (cleanPhone.startsWith('998')) {
      return cleanPhone.length == 12;
    }

    // 90 123 45 67
    if (cleanPhone.startsWith('90')) {
      return cleanPhone.length == 9;
    }

    return false;
  }

  // Text validation
  static bool isValidText(String text,
      {int minLength = 2, int maxLength = 100}) {
    return text.trim().length >= minLength && text.trim().length <= maxLength;
  }

  // Number validation
  static bool isValidNumber(String number) {
    return double.tryParse(number) != null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName мажбурий';
    }
    return null;
  }

  // Contract number validation
  static String? validateContractNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Шартнома рақами мажбурий';
    }

    if (value.trim().length < 3) {
      return 'Шартнома рақами камда 3 та харф бўлиши керак';
    }

    return null;
  }

  // Amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Сумма мажбурий';
    }

    if (double.tryParse(value) == null) {
      return 'Сумма рақам бўлиши керак';
    }

    if (double.parse(value) <= 0) {
      return 'Сумма 0 дан катта бўлиши керак';
    }

    return null;
  }

  // Area validation
  static String? validateArea(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Майдон мажбурий';
    }

    if (double.tryParse(value) == null) {
      return 'Майдон рақам бўлиши керак';
    }

    if (double.parse(value) <= 0) {
      return 'Майдон 0 дан катта бўлиши керак';
    }

    return null;
  }
}
