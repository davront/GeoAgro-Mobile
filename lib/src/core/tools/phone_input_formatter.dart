import 'package:flutter/services.dart';

class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(' ', ''); // Bo'shliqlarni olib tashlaymiz

    // Agar raqamlar soni 9 tadan ortiq bo'lsa, eski qiymatni qaytaring
    if (text.length > 9) {
      return oldValue;
    }

    // Raqamlarni formatlash
    if (text.length >= 3) {
      text = '${text.substring(0, 2)} ${text.substring(2)}'; // 94 864...
    }
    if (text.length >= 7) {
      text = '${text.substring(0, 6)} ${text.substring(6)}'; // 94 864 24...
    }
    if (text.length >= 10) {
      text = '${text.substring(0, 9)} ${text.substring(9)}'; // 94 864 24 24
    }

    // Kursor pozitsiyasini yangilash
    int selectionIndex = newValue.selection.end;
    selectionIndex += text.length > oldValue.text.length ? 1 : 0;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionIndex.clamp(0, text.length)),
    );
  }
}
