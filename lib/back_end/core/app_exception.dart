import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro com mensagem pronta para exibir ao usuário no front end.
class AppException implements Exception {
  const AppException(this.mensagem, [this.causa]);

  final String mensagem;
  final Object? causa;

  @override
  String toString() => mensagem;
}

/// Executa [acao] e converte qualquer falha do Supabase em [AppException].
Future<T> executar<T>(Future<T> Function() acao, String mensagemErro) async {
  try {
    return await acao();
  } on AppException {
    rethrow;
  } on PostgrestException catch (e) {
    throw AppException(mensagemErro, e);
  } on StorageException catch (e) {
    throw AppException(mensagemErro, e);
  } catch (e) {
    throw AppException(mensagemErro, e);
  }
}