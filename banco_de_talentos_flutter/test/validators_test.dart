import 'package:flutter_test/flutter_test.dart';
import 'package:banco_de_talentos_flutter/core/utils/validators.dart';

void main() {
  group('Validators Test', () {
    test('validateEmail should return error for invalid emails', () {
      expect(Validators.validateEmail(''), 'E-mail é obrigatório');
      expect(Validators.validateEmail('invalid'), 'Insira um e-mail válido');
      expect(Validators.validateEmail('invalid@'), 'Insira um e-mail válido');
      expect(Validators.validateEmail('invalid@domain'),
          'Insira um e-mail válido');
      expect(Validators.validateEmail('valid@domain.com'), isNull);
    });

    test('validatePassword should return error for short passwords', () {
      expect(Validators.validatePassword(''), 'Senha é obrigatória');
      expect(Validators.validatePassword('123'),
          'A senha deve ter pelo menos 6 caracteres');
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('validateCPF should return error for invalid CPFs', () {
      expect(Validators.validateCPF(''), 'CPF é obrigatório');
      expect(Validators.validateCPF('123'), 'CPF deve conter 11 dígitos');
      expect(Validators.validateCPF('11111111111'), 'CPF inválido');
      expect(Validators.validateCPF('12345678909'), isNull);
      expect(Validators.validateCPF('123.456.789-09'), isNull);
      expect(Validators.validateCPF('12345678900'), 'CPF inválido');
    });
  });
}
