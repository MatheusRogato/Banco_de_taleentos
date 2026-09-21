import 'package:flutter/services.dart';

class AppFormatters {
  AppFormatters._();

  static final TextInputFormatter cpf = _CpfInputFormatter();
  static final TextInputFormatter cnpj = _CnpjInputFormatter();
  static final TextInputFormatter phone = _PhoneInputFormatter();
  static final TextInputFormatter cep = _CepInputFormatter();
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (newText.length > 11) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(newText[i]);
    }

    final stringValue = buffer.toString();
    return TextEditingValue(
      text: stringValue,
      selection: TextSelection.collapsed(offset: stringValue.length),
    );
  }
}

class _CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (newText.length > 14) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 2 || i == 5) {
        buffer.write('.');
      } else if (i == 8) {
        buffer.write('/');
      } else if (i == 12) {
        buffer.write('-');
      }
      buffer.write(newText[i]);
    }

    final stringValue = buffer.toString();
    return TextEditingValue(
      text: stringValue,
      selection: TextSelection.collapsed(offset: stringValue.length),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (newText.length > 11) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 0) {
        buffer.write('(');
      }
      if (i == 2) {
        buffer.write(') ');
      }
      if (newText.length == 11 && i == 7) {
        buffer.write('-');
      } else if (newText.length < 11 && i == 6) {
        buffer.write('-');
      }
      buffer.write(newText[i]);
    }

    final stringValue = buffer.toString();
    return TextEditingValue(
      text: stringValue,
      selection: TextSelection.collapsed(offset: stringValue.length),
    );
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (newText.length > 8) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 5) {
        buffer.write('-');
      }
      buffer.write(newText[i]);
    }

    final stringValue = buffer.toString();
    return TextEditingValue(
      text: stringValue,
      selection: TextSelection.collapsed(offset: stringValue.length),
    );
  }
}
