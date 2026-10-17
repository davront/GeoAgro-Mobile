import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final String separator;

  ThousandsSeparatorInputFormatter({this.separator = ' '});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only digits so we can reformat every time
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    // Format manually to avoid int.parse overflow on long inputs
    final String formatted = _groupDigits(digitsOnly, separator);

    // Calculate new cursor position from the right to reduce caret jumps
    final int selectionFromRight = newValue.text.length - newValue.selection.end;
    final int newOffset = formatted.length - selectionFromRight;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, formatted.length)),
    );
  }

  static String _groupDigits(String digits, String sep) {
    final buffer = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(sep);
      }
    }
    return buffer.toString().split('').reversed.join();
  }

  // Helper to format any numeric string by grouping digits. Non-digits are removed first.
  static String formatDigits(String value, {String separator = ' '}) {
    final onlyDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) return '';
    return _groupDigits(onlyDigits, separator);
  }
}

/// Форматтер для ввода десятичных чисел с поддержкой разделителя тысяч
class DecimalInputFormatter extends TextInputFormatter {
  final String thousandsSeparator;
  final String decimalSeparator;
  final int maxDecimalPlaces;

  DecimalInputFormatter({
    this.thousandsSeparator = ' ',
    this.decimalSeparator = '.',
    this.maxDecimalPlaces = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Разрешаем только цифры, точку и запятую
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9.,]'), '');
    
    if (filtered.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    // Заменяем запятую на точку для единообразия
    String normalized = filtered.replaceAll(',', '.');
    
    // Проверяем, что точка только одна
    final dotCount = '.'.allMatches(normalized).length;
    if (dotCount > 1) {
      // Если больше одной точки, оставляем только первую
      final firstDotIndex = normalized.indexOf('.');
      final beforeDot = normalized.substring(0, firstDotIndex + 1);
      final afterDot = normalized.substring(firstDotIndex + 1).replaceAll('.', '');
      normalized = beforeDot + afterDot;
    }

    // Разделяем на целую и дробную части
    final parts = normalized.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Ограничиваем количество знаков после запятой
    if (decimalPart.length > maxDecimalPlaces) {
      decimalPart = decimalPart.substring(0, maxDecimalPlaces);
    }

    // Форматируем целую часть с разделителем тысяч только если число достаточно большое
    if (integerPart.isNotEmpty && integerPart.length > 3) {
      integerPart = _groupDigits(integerPart, thousandsSeparator);
    }

    // Собираем результат
    String result = integerPart;
    if (decimalPart.isNotEmpty && decimalPart != "0") {
      result += decimalSeparator + decimalPart;
    }

    // Вычисляем новую позицию курсора
    final int selectionFromRight = newValue.text.length - newValue.selection.end;
    final int newOffset = result.length - selectionFromRight;

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, result.length)),
    );
  }

  static String _groupDigits(String digits, String sep) {
    final buffer = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(sep);
      }
    }
    return buffer.toString().split('').reversed.join();
  }

  /// Форматирует строку с десятичным числом, добавляя разделители тысяч
  static String formatDecimal(String value, {
    String thousandsSeparator = ' ',
    String decimalSeparator = '.',
  }) {
    if (value.isEmpty) return '';
    
    // Нормализуем ввод
    String normalized = value.replaceAll(',', '.');
    final parts = normalized.split('.');
    
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Форматируем целую часть только если число достаточно большое
    if (integerPart.isNotEmpty && integerPart.length > 3) {
      integerPart = _groupDigits(integerPart, thousandsSeparator);
    }

    // Собираем результат - добавляем десятичную часть только если она не пустая и не равна "0"
    String result = integerPart;
    if (decimalPart.isNotEmpty && decimalPart != "0") {
      result += decimalSeparator + decimalPart;
    }

    return result;
  }

  /// Форматирует число, пришедшее с бэка, правильно обрабатывая десятичные числа
  static String formatBackendNumber(dynamic value, {
    String thousandsSeparator = ' ',
    String decimalSeparator = '.',
  }) {
    if (value == null) return '';
    
    String stringValue = value.toString();
    
    // Если это целое число или число с нулевой дробной частью, убираем .0
    if (stringValue.endsWith('.0')) {
      stringValue = stringValue.substring(0, stringValue.length - 2);
    }
    
    // Нормализуем ввод
    String normalized = stringValue.replaceAll(',', '.');
    final parts = normalized.split('.');
    
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Форматируем целую часть только если число достаточно большое
    if (integerPart.isNotEmpty && integerPart.length > 3) {
      integerPart = _groupDigits(integerPart, thousandsSeparator);
    }

    // Собираем результат - добавляем десятичную часть только если она не пустая и не равна "0"
    String result = integerPart;
    if (decimalPart.isNotEmpty && decimalPart != "0") {
      result += decimalSeparator + decimalPart;
    }

    return result;
  }
}


