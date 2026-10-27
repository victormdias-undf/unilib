
import 'dart:io';

import 'autenticacao_service.dart';

void main() {
  final servico = ServicoDeAutenticacao();

  int aprovados = 0;
  int reprovados = 0;

  void testar(String descricao, bool Function() verificar) {
    try {
      if (verificar()) {
        print('[OK] $descricao');
        aprovados++;
      } else {
        print('[FALHOU] $descricao');
        reprovados++;
      }
    } catch (erro) {
      print('[ERRO] $descricao: $erro');
      reprovados++;
    }
  }

  // TESTE 1: Verificar matrícula existente
  testar(
    'Matricula existente',
    () => servico.matriculaExiste('0001'),
  );

  // TESTE 2: Verificar matrícula inexistente
  testar(
    'Matricula inexistente',
    () => !servico.matriculaExiste('0003'),
  );

  // TESTE 3: Login correto
  testar(
    'Login com dados corretos',
    () => servico.fazerLogin('0001', '1234') == 'Maria Silva',
  );

  // TESTE 4: Senha incorreta
  testar(
    'Login com senha incorreta',
    () => servico.fazerLogin('0001', '9999') == null,
  );

  // TESTE 5: Matrícula incorreta
  testar(
    'Login com matricula inexistente',
    () => servico.fazerLogin('9999', '1234') == null,
  );

  // TESTE 6: Cadastrar novo aluno
  testar(
    'Cadastrar novo aluno',
    () => servico.cadastrarAluno('0003', 'Ana Costa', 'abc123'),
  );

  // TESTE 7: Verificar novo cadastro
  testar(
    'Verificar aluno cadastrado',
    () => servico.matriculaExiste('0003'),
  );

  // TESTE 8: Login do novo aluno
  testar(
    'Login do novo aluno',
    () => servico.fazerLogin('0003', 'abc123') == 'Ana Costa',
  );

  // TESTE 9: Impedir matrícula duplicada
  testar(
    'Impedir matricula duplicada',
    () => !servico.cadastrarAluno('0003', 'Pedro', '4567'),
  );

  // TESTE 10: Preservar senha original
  testar(
    'Preservar senha original',
    () => servico.fazerLogin('0003', 'abc123') == 'Ana Costa',
  );

  // TESTE 11: Matrícula vazia
  testar(
    'Impedir matricula vazia',
    () => !servico.cadastrarAluno('', 'Pedro', '1234'),
  );

  // TESTE 12: Nome vazio
  testar(
    'Impedir nome vazio',
    () => !servico.cadastrarAluno('0004', '', '1234'),
  );

  // TESTE 13: Senha vazia
  testar(
    'Impedir senha vazia',
    () => !servico.cadastrarAluno('0004', 'Pedro', ''),
  );

  // TESTE 14: Espaços na matrícula
  testar(
    'Ignorar espacos na matricula',
    () => servico.fazerLogin(' 0001 ', '1234') == 'Maria Silva',
  );

  // RESULTADO FINAL
  print('\n------------------------------');
  print('RESULTADO DOS TESTES');
  print('Aprovados: $aprovados');
  print('Reprovados: $reprovados');
  print('------------------------------');

  if (reprovados > 0) {
    exitCode = 1;
  }
}
