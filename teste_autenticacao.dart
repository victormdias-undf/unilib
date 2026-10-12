

import 'dart:io';
import 'autenticacao_service.dart';

void main() {
  final auth = AutenticacaoService();

  stdout.write('Digite sua matrícula: ');
  String matricula = stdin.readLineSync() ?? '';

  stdout.write('Digite sua senha: ');
  String senha = stdin.readLineSync() ?? '';

  String? nome = auth.fazerLogin(matricula, senha);

  if (nome != null) {
    print('Login realizado com sucesso!');
    print('Bem-vindo(a), $nome!');
  } else {
    print('Matrícula ou senha incorreta.');
  }
}
