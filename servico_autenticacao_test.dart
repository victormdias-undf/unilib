
import 'package:flutter_test/flutter_test.dart';

import 'package:unilib/servico_autenticacao.dart';

void main() {
  // CPF de exemplo para testes.
  const cpfTeste = '52998224725';

  // TESTE 1: VALIDAÇÃO DO CPF
  test('CPF deve ser válido', () {
    expect(
      ServicoAutenticacao.cpfValido(cpfTeste),
      isTrue,
    );

    expect(
      ServicoAutenticacao.cpfValido('11111111111'),
      isFalse,
    );
  });

  // TESTE 2: E-MAIL OBRIGATÓRIO
  test('E-mail é obrigatório', () async {
    final servico = ServicoAutenticacao();

    final resultado = await servico.cadastrar(
      cpf: cpfTeste,
      email: '',
      senha: '1234',
    );

    expect(
      resultado,
      ResultadoCadastro.emailInvalido,
    );
  });

  // TESTE 3: SENHA CURTA
  test('Senha de 3 caracteres é recusada', () async {
    final servico = ServicoAutenticacao();

    final resultado = await servico.cadastrar(
      cpf: cpfTeste,
      email: 'teste@exemplo.com',
      senha: '123',
    );

    expect(
      resultado,
      ResultadoCadastro.senhaCurta,
    );
  });

  // TESTE 4: CADASTRO E LOGIN
  test('Senha de 4 caracteres é aceita', () async {
    final servico = ServicoAutenticacao();

    final resultado = await servico.cadastrar(
      cpf: cpfTeste,
      email: 'teste@exemplo.com',
      senha: '1234',
    );

    expect(
      resultado,
      ResultadoCadastro.sucesso,
    );

    // Login com senha correta.
    final usuario = await servico.entrar(
      cpf: cpfTeste,
      senha: '1234',
    );

    expect(
      usuario?.email,
      'teste@exemplo.com',
    );

    // Login com senha incorreta.
    final senhaErrada = await servico.entrar(
      cpf: cpfTeste,
      senha: '4321',
    );

    expect(
      senhaErrada,
      isNull,
    );
  });

  // TESTE 5: CPF DUPLICADO
  test('CPF não pode ser cadastrado duas vezes', () async {
    final servico = ServicoAutenticacao();

    await servico.cadastrar(
      cpf: cpfTeste,
      email: 'teste@exemplo.com',
      senha: '1234',
    );

    final novamente = await servico.cadastrar(
      cpf: cpfTeste,
      email: 'outro@exemplo.com',
      senha: '1234',
    );

    expect(
      novamente,
      ResultadoCadastro.cpfJaCadastrado,
    );
  });
}
