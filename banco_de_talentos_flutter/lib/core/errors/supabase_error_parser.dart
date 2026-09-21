import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorParser {
  static String parse(dynamic exception) {
    if (exception is PostgrestException) {
      return _parsePostgrestException(exception);
    }
    if (exception is AuthException) {
      return _parseAuthException(exception);
    }

    final errStr = exception.toString().toLowerCase();
    if (errStr.contains('network') ||
        errStr.contains('socketexception') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('connection failed')) {
      return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
    }
    if (errStr.contains('timeout')) {
      return 'Tempo limite de resposta esgotado. Tente novamente mais tarde.';
    }

    return exception.toString().replaceAll('Exception: ', '');
  }

  static String _parsePostgrestException(PostgrestException error) {
    switch (error.code) {
      case '23505':
        final msg = error.message.toLowerCase();
        if (msg.contains('cpf') ||
            msg.contains('document_id') ||
            msg.contains('profiles_pkey')) {
          return 'Este CPF já está cadastrado no sistema.';
        }
        if (msg.contains('email')) {
          return 'Este e-mail já está cadastrado.';
        }
        return 'Registro duplicado encontrado no banco de dados.';
      case '23503':
        return 'Erro de consistência: o registro de referência associado não existe.';
      case '23514':
        return 'Validação de banco falhou: os dados inseridos contêm valores inválidos.';
      case '42501':
        return 'Acesso negado: privilégios insuficientes para realizar esta ação.';
      default:
        if (error.message.isNotEmpty) {
          return error.message;
        }
        return 'Erro no banco de dados (Código ${error.code}): ${error.message}';
    }
  }

  static String _parseAuthException(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (message.contains('email not confirmed')) {
      return 'Por favor, confirme seu e-mail na sua caixa de entrada antes de fazer login.';
    }
    if (message.contains('user already exists')) {
      return 'Este endereço de e-mail já está cadastrado.';
    }
    if (message.contains('password is too short')) {
      return 'A senha digitada deve ter pelo menos 6 caracteres.';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'Erro de conexão no login. Verifique sua internet.';
    }

    return error.message;
  }
}
