import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 11) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    final formattedString = buffer.toString();
    int selectionIndex = newValue.selection.end;
    int addedCharacters = formattedString.length - text.length;

    if (oldValue.text.length < newValue.text.length &&
        newValue.selection.end == newValue.text.length) {
      selectionIndex = formattedString.length;
    } else {
      selectionIndex = newValue.selection.end +
          (formattedString.length - newValue.text.length);
      if (selectionIndex > formattedString.length) {
        selectionIndex = formattedString.length;
      } else if (selectionIndex < 0) {
        selectionIndex = 0;
      }
    }

    return TextEditingValue(
      text: formattedString,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
