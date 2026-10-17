import 'package:flutter/services.dart';

/// Форматтер для узбекских номеров телефонов в формате +998 xx xxx-xx-xx
class UzbekPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Удаляем все нецифровые символы
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Если начинается с 998, убираем его (так как +998 будет добавлен автоматически)
    if (digitsOnly.startsWith('998')) {
      digitsOnly = digitsOnly.substring(3);
    }

    // Ограничиваем до 9 цифр (после +998)
    if (digitsOnly.length > 9) {
      digitsOnly = digitsOnly.substring(0, 9);
    }

    // Формируем отформатированную строку в формате +998 xx xxx-xx-xx
    String formatted = '+998';
    
    if (digitsOnly.isNotEmpty) {
      if (digitsOnly.length <= 2) {
        // +998 xx
        formatted += ' $digitsOnly';
      } else if (digitsOnly.length <= 5) {
        // +998 xx xxx
        formatted += ' ${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2)}';
      } else if (digitsOnly.length <= 7) {
        // +998 xx xxx-xx
        formatted += ' ${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 5)}-${digitsOnly.substring(5)}';
      } else {
        // +998 xx xxx-xx-xx
        formatted += ' ${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 5)}-${digitsOnly.substring(5, 7)}-${digitsOnly.substring(7)}';
      }
    }

    // Вычисляем позицию курсора
    // Определяем, было ли добавление или удаление символов
    final isAdding = newValue.text.length > oldValue.text.length;
    
    int cursorPosition;
    
    if (isAdding) {
      // При добавлении символов курсор всегда в конце
      cursorPosition = formatted.length;
    } else {
      // При удалении сохраняем относительную позицию
      // Подсчитываем количество цифр до курсора в новом значении
      final newTextBeforeCursor = newValue.text.substring(0, newValue.selection.end);
      String newDigitsBeforeCursor = newTextBeforeCursor.replaceAll(RegExp(r'[^\d]'), '');
      
      // Убираем 998 если есть
      int digitsCount = 0;
      if (newDigitsBeforeCursor.startsWith('998')) {
        digitsCount = newDigitsBeforeCursor.length > 3 ? newDigitsBeforeCursor.length - 3 : 0;
      } else {
        digitsCount = newDigitsBeforeCursor.length;
      }
      
      // Находим позицию курсора в отформатированном тексте
      if (digitsCount == 0) {
        cursorPosition = 5; // После "+998 "
      } else if (digitsCount <= 2) {
        cursorPosition = 5 + digitsCount; // После "+998 xx"
      } else if (digitsCount <= 5) {
        cursorPosition = 8 + digitsCount; // После "+998 xx xxx"
      } else if (digitsCount <= 7) {
        cursorPosition = 12 + digitsCount; // После "+998 xx xxx-xx"
      } else {
        cursorPosition = 15 + digitsCount; // После "+998 xx xxx-xx-xx"
      }
    }
    
    cursorPosition = cursorPosition.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
